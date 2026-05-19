(() => {
    'use strict';

    // -------- Helpers --------
    const getContainer = (el) => el?.closest?.('.fab-container');
    const getFab = (container) => container.querySelector('.fab');
    const getMenu = (container) => container.querySelector('.sub-buttons');

    const setExpanded = (container, expanded) => {
        const fab = getFab(container);
        const menu = getMenu(container);

        if (!fab || !menu) return;
        if (container.classList.contains('is-open') === expanded) return;

        container.classList.toggle('is-open', expanded);
        fab.setAttribute('aria-expanded', expanded);
        
        if (expanded) {
            menu.removeAttribute('inert');
        } else {
            menu.setAttribute('inert', '');
        }
    };

    /**
     * Sets initial state and non-bubbling hover events.
     * Idempotent: can be called multiple times.
     */
    const prime = (container) => {
        const fab = getFab(container);
        const menu = getMenu(container);
        if (!fab || !menu || container.__fabHoverBound) return;

        if (!container.classList.contains('is-open')) {
            menu.setAttribute('inert', '');
            fab.setAttribute('aria-expanded', 'false');
        }

        container.__fabHoverBound = true;

        container.addEventListener('mouseenter', () => {
            container.__fabSuppressAutoOpen = false;
            setExpanded(container, true);
        });

        container.addEventListener('mouseleave', () => {
            // Only close if keyboard focus isn't inside
            if (!container.contains(document.activeElement)) {
                setExpanded(container, false);
            }
        });
    };

    const primeAll = (scope = document) => {
        const containers = scope.querySelectorAll('.fab-container');
        containers.forEach(prime);
    };

    // -------- Global Delegated Event Handlers --------
    const bindDelegated = () => {
        if (document.__fabDelegated) return;
        document.__fabDelegated = true;

        // Auto-open on focus
        document.addEventListener('focusin', (ev) => {
            const container = getContainer(ev.target);
            if (container && !container.__fabSuppressAutoOpen) {
                setExpanded(container, true);
            }
        });

        // Auto-close when focus leaves container
        document.addEventListener('focusout', (ev) => {
            const container = getContainer(ev.target);
            if (!container) return;

            // Wait for focus to settle
            setTimeout(() => {
                if (!container.contains(document.activeElement)) {
                    setExpanded(container, false);
                    container.__fabSuppressAutoOpen = false;
                }
            }, 0);
        });

        // Close on outside click
        document.addEventListener('click', (ev) => {
            if (getContainer(ev.target)) return;
            document.querySelectorAll('.fab-container.is-open')
                    .forEach(c => setExpanded(c, false));
        });

        // Accessibility Keyboard Navigation
        document.addEventListener('keydown', (ev) => {
            const container = getContainer(ev.target);
            if (!container) return;

            const { key } = ev;

            if (key === 'Escape') {
                ev.preventDefault();
                container.__fabSuppressAutoOpen = true;
                setExpanded(container, false);
                getFab(container)?.focus();
                return;
            }

            const navKeys = ['ArrowUp', 'ArrowDown', 'Home', 'End'];
            if (!navKeys.includes(key)) return;

            const menu = getMenu(container);
            const items = Array.from(menu?.querySelectorAll('[role="menuitem"]') || []);
            if (!items.length) return;

            setExpanded(container, true);

            const active = document.activeElement;
            const isFabActive = (active === getFab(container));
            const idx = items.indexOf(active);
            const lastIdx = items.length - 1;
            let target = null;

            // Handle column-reverse: Visual Top = Last in DOM, Visual Bottom = First in DOM
            switch (key) {
                case 'ArrowUp':
                    target = (isFabActive || idx < 0) ? items[lastIdx] : items[Math.min(lastIdx, idx + 1)];
                    break;
                case 'ArrowDown':
                    target = (isFabActive || idx < 0) ? items[0] : items[Math.max(0, idx - 1)];
                    break;
                case 'Home':
                    target = items[lastIdx];
                    break;
                case 'End':
                    target = items[0];
                    break;
            }

            if (target) {
                ev.preventDefault();
                target.focus();
            }
        });
    };

    // -------- Initialization --------
    const boot = () => {
        bindDelegated();
        primeAll();
    };

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', boot);
    } else {
        boot();
    }

    // APEX Lifecycle Integration
    if (window.apex?.jQuery) {
        apex.jQuery(document).on('apexafterrefresh apexreadyend', () => primeAll());
    }
})();
