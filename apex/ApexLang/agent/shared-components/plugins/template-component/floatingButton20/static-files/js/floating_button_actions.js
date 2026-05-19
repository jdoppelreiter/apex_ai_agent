(() => {
   'use strict';

   const WRAP_CLASS = 'fab-action-wrap';
   const LISTENER_CLASS =  document.querySelector('.fab-container .fab')?.getAttribute('add-to-actions-class') ?? 'fab-add-to-actions';
;

   const getKey = (btn) => btn.id || 
      btn.querySelector('.t-Button-label')?.textContent || 
      btn.textContent?.trim() || 
      'fab-action';

   const getLabel = (btn) => btn.querySelector('.t-Button-label')?.textContent.trim() || 
      btn.getAttribute('aria-label') || 
      btn.textContent?.trim() || 
      'Action';

   const extractIconClass = (btn) => {
      const el = btn.querySelector('.t-Icon--left.fa, .t-Icon--left .fa, .t-Icon--right.fa, .t-Icon--right .fa, .fa');
      const match = el?.className?.match(/\bfa-[\w-]+/);
      return match ? match[0] : '';
   };

   const buildClone = (orig) => {
      const wrap = document.createElement('div');
      wrap.className = `sub-button shadow ${WRAP_CLASS}`;
      wrap.setAttribute('role', 'none');
      wrap.dataset.fabActionKey = getKey(orig);
      if (orig.id) wrap.dataset.fabActionTargetId = orig.id;

      const btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'fab-action-button';
      btn.setAttribute('role', 'menuitem');
      
      const label = getLabel(orig);
      btn.setAttribute('aria-label', label);
      btn.setAttribute('title', label);
      btn.setAttribute('cloned', true);

      const icon = extractIconClass(orig);
      if (icon) {
         const span = document.createElement('span');
         span.className = `fa ${icon}`;
         span.setAttribute('aria-hidden', 'true');
         btn.appendChild(span);
      }

      btn.addEventListener('click', (ev) => {
         const target = wrap.dataset.fabActionTargetId && document.getElementById(wrap.dataset.fabActionTargetId);
         if (!target || target === btn) return;
         ev.preventDefault();
         ev.stopPropagation();
         target.click();
      });

      wrap.appendChild(btn);
      return wrap;
   };

   const insertAt = (subButtons, wrap) => {
      const ref = [...subButtons.children].find(c => c.classList.contains('sub-button') && !c.classList.contains(WRAP_CLASS));
      ref ? subButtons.insertBefore(wrap, ref) : subButtons.appendChild(wrap);
   };

   const relocate = () => {
      const fab = document.querySelector('.fab-container');
      const subButtons = fab?.querySelector('.sub-buttons');
      if (!subButtons) return;

      const existing = {};
      subButtons.querySelectorAll(`.${WRAP_CLASS}`).forEach(w => {
         existing[w.dataset.fabActionKey] = w;
      });

      const seen = {};
      document.querySelectorAll(`button.${LISTENER_CLASS}`).forEach(btn => {
         if (fab.contains(btn)) return;
         const key = getKey(btn);
         seen[key] = true;
         if (!existing[key]) insertAt(subButtons, buildClone(btn));
      });

      Object.keys(existing).forEach(k => {
         if (!seen[k]) existing[k].remove();
      });
   };

   if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', relocate);
   } else {
      relocate();
   }

   if (window.apex?.jQuery) {
      window.apex.jQuery(document).on('apexafterrefresh apexreadyend', relocate);
   }
})();
