/* ============================================================
   Progress Tracker <-> FAB bridge
   ------------------------------------------------------------
   Activated when BOTH a .fab-container and a .progress-container
   exist on the page. Performs DOM surgery so progress entries
   appear seamlessly inside the FAB menu, while progress_tracker.js
   continues to own row rendering, layout, badge updates, and the
   WebSocket.

   Layout contract (visual, top -> bottom when the FAB is open):
     1. Existing FAB icon sub-buttons      (top of menu)
     2. "Show all processes" overflow row  (visually above the
                                            progress entries, just
                                            beneath the FAB icons)
     3. Up to MAX_VISIBLE progress rows    (newest nearest the trigger)
     4. The FAB main button                (always at the bottom)

   How that maps to the DOM:
     - .sub-buttons is `flex-direction: column-reverse`. We insert
       .progress-items as the FIRST child of .sub-buttons, so it is
       visually at the BOTTOM of the menu (closest to the FAB), with
       the existing FAB icon sub-buttons stacking above it.
     - Inside .progress-items (also column-reverse), DOM[0] is the
       newest row (visually nearest the FAB) and the show-all row is
       appended at DOM[end] so it sits visually at the top of the
       progress group, just under the FAB icons.

   Re-bridging on APEX refresh:
     APEX renders .progress-container as a Template Component. On
     region refresh, APEX rewrites the entire region body, which
     means a brand-new .progress-container appears in the DOM with
     fresh data-* attrs, a fresh .progress-items wrapper, and fresh
     rows. We have to:
       a) move the new .progress-items into .sub-buttons (replacing
          the stale wrapper from a previous bridge)
       b) refresh the badge / sr-only / live / template references
       c) refresh the data-* attributes on the FAB
       d) mark the new .progress-container with .is-merged so
          progress_tracker.js doesn't try to init a second container.
     The WebSocket opened on the FAB at first init is preserved and
     self-heals via liveRootFor() inside progress_tracker.js.
   ============================================================ */
(function () {
   'use strict';

   var ATTRS = ['wsUrl', 'appUser', 'showAllUrl', 'maxVisible'];

   function syncAttrs(from, to) {
      ATTRS.forEach(function (k) {
         if (from.dataset[k] != null) {
            to.dataset[k] = from.dataset[k];
         }
      });
   }

   /**
    * Move `node` from its current parent to `target`, replacing any
    * existing element matching `selector` inside `target` first.
    */
   function replaceChildBySelector(target, selector, node) {
      if (!node) return;
      var existing = target.querySelector(selector);
      if (existing && existing !== node) {
         existing.parentNode.removeChild(existing);
      }
      if (node.parentNode !== target) {
         target.appendChild(node);
      }
   }

   /**
    * Reveal any standalone .progress-container that the bridge has
    * decided NOT to merge (because there is no FAB on the page, or
    * because it's already merged but a fresh duplicate slipped in).
    * progress_tracker.css hides .progress-container by default until
    * either .is-merged or .is-ready is set; this is the "no, actually
    * stay standalone" signal that flips it visible.
    */
   function markStandaloneReady() {
      var pending = document.querySelectorAll(
         '.progress-container:not(.is-merged):not(.is-ready)'
      );
      Array.prototype.forEach.call(pending, function (p) {
         p.classList.add('is-ready');
      });
   }

   function run () {
      var fab = document.querySelector('.fab-container');
      if (!fab) {
         // No FAB on this page - the progress tracker stays standalone.
         // Reveal it so the CSS visibility:hidden default no longer
         // applies. Without this the big button stays invisible
         // forever on FAB-less pages.
         markStandaloneReady();
         return;
      }
      // Only bridge an UN-merged .progress-container. After the
      // first bridge, the standalone container is .is-merged; APEX
      // refresh will produce a fresh, un-merged one.
      var progress = document.querySelector('.progress-container:not(.is-merged)');
      if (!progress) {
         // Nothing to bridge - any leftover containers (shouldn't
         // happen, but be safe) get revealed as standalone.
         markStandaloneReady();
         return;
      }

      var subButtons = fab.querySelector('.sub-buttons');
      var fabBtn     = fab.querySelector('.fab');
      if (!subButtons || !fabBtn) {
         // FAB element exists but its inner pieces aren't ready yet.
         // Reveal the standalone so the user isn't staring at a blank
         // corner. The next apex event run will retry the bridge.
         markStandaloneReady();
         return;
      }

      // 1) Carry the WebSocket / config attributes onto .fab-container
      //    so progress_tracker.js uses the FAB as its root. On a
      //    re-bridge, this also picks up any changed values.
      syncAttrs(progress, fab);

      // 2) Badge -> on the FAB main button (replace any prior badge).
      replaceChildBySelector(
         fabBtn, '.progress-badge',
         progress.querySelector('.progress-badge')
      );

      // 3) sr-only count -> inside the FAB main button so it joins
      //    the button's accessible name.
      replaceChildBySelector(
         fabBtn, '[data-progress-count]',
         progress.querySelector('[data-progress-count]')
      );

      // 4) Polite live region -> on the FAB so updates announce
      //    while the user interacts with the FAB.
      replaceChildBySelector(
         fab, '[data-progress-live]',
         progress.querySelector('[data-progress-live]')
      );

      // 5) .progress-items wrapper -> first child of .sub-buttons.
      //    With .sub-buttons being column-reverse, DOM[0] is the
      //    visual BOTTOM of the menu, so progress entries sit just
      //    above the FAB main button and the icon sub-buttons stack
      //    on top.
      var newItems = progress.querySelector('.progress-items');
      if (newItems) {
         var oldItems = subButtons.querySelector('.progress-items');
         if (oldItems && oldItems !== newItems) {
            oldItems.parentNode.removeChild(oldItems);
         }
         if (newItems.parentNode !== subButtons) {
            subButtons.insertBefore(newItems, subButtons.firstChild);
         } else if (newItems !== subButtons.firstChild) {
            // re-pin to DOM[0] (visual bottom) in case other code shifted it
            subButtons.insertBefore(newItems, subButtons.firstChild);
         }
      }

      // 6) Templates -> on the FAB so progress_tracker.js can clone
      //    new rows via root.querySelector() with root = .fab-container.
      replaceChildBySelector(
         fab, 'template.progress-item-tpl',
         progress.querySelector('template.progress-item-tpl')
      );
      replaceChildBySelector(
         fab, 'template.progress-showall-tpl',
         progress.querySelector('template.progress-showall-tpl')
      );

      // 7) Tag the FAB so:
      //      - progress_tracker.js bootstraps on it (CONTAINER_SEL match)
      //      - progress_fab_bridge.css can size the menu wider / taller
      fab.classList.add('has-progress');
      fab.dataset.progressBridged = '1';

      // 8) Hide the now-empty standalone .progress-container. The
      //    .is-merged class makes it `display: none` AND excludes it
      //    from progress_tracker.js's CONTAINER_SEL, so we don't
      //    double-init or write rows into a detached subtree.
      progress.classList.add('is-merged');

      // 9) On a re-bridge (APEX refresh), the badge count / show-all
      //    overflow row need to be recomputed against the freshly
      //    moved rows. progress_tracker.js exposes layout() via the
      //    debug API; if it isn't available yet (first init - the
      //    tracker hasn't booted), tracker's own boot() runs layout()
      //    so we don't need to.
      if (window.__progressTracker && typeof window.__progressTracker.layout === 'function') {
         try { window.__progressTracker.layout(fab); }
         catch (e) { /* tracker may not be ready - safe to ignore */ }
      }
   }

   if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', run);
   } else {
      run();
   }

   // Re-bridge on APEX refresh: when the .progress-container Template
   // Component is refreshed, APEX rewrites the entire region body and
   // a fresh, un-merged .progress-container appears. We replay the
   // bridge so the FAB takes ownership of the new wrapper / badge /
   // templates, the stale ones are discarded, and the new container
   // gets .is-merged so progress_tracker.js doesn't double-init.
   if (window.apex && window.apex.jQuery) {
      window.apex.jQuery(document).on('apexafterrefresh apexreadyend', run);
   }
})();
