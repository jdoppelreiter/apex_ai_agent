/* ============================================================
   Progress Tracker - Oracle APEX Template Component
   ------------------------------------------------------------
   - Reads data-* attributes from the .progress-container root
   - Connects to a WebSocket (?user=APP_USER)
   - Upserts / removes rows on update, remove messages
     (initial rows come from APEX - no snapshot from server)
   - Clones new rows from the .progress-item-tpl <template>
   - Hides rows beyond MAX_VISIBLE and inserts a "Show all" row
   - No HTML strings in JS - everything comes from <template>s
   - WS handlers re-resolve the live container on every message,
     so an APEX partial refresh can't leave them writing to a
     detached DOM node.

   Why event delegation:
   APEX renders .progress-container as a Template Component
   (Template Report). After our region's JS first runs, APEX's
   TableModelView re-renders the rows, REPLACING the .progress-items
   children (and sometimes the wrapper itself) in the DOM. Listeners
   attached directly to those elements would end up on detached nodes.
   We attach a single set of delegated handlers to `document` that
   walk up to the closest .progress-container on every event - this
   survives any number of APEX partial refreshes. The two events that
   don't bubble (mouseenter / mouseleave) are bound per-container in
   prime(), which is idempotent and re-runs on apexafterrefresh.
   ============================================================ */

(function () {
   'use strict';

   // The tracker has TWO valid root forms:
   //   - .progress-container                 (standalone)
   //   - .fab-container.has-progress         (merged into FAB by progress_fab_bridge.js)
   // In bridged mode, the FAB owns the open/close state, hover, the
   // .is-open class, the [inert] toggle, and the keyboard menu nav. We
   // skip those parts and limit ourselves to row rendering, layout,
   // badge updates, and the WebSocket. The bridged standalone
   // container is hidden via .is-merged - we exclude it so we don't
   // double-init.
   var CONTAINER_SEL = '.progress-container:not(.is-merged), .fab-container.has-progress';

   // -------- helpers --------
   function toInt(v, def) {
      var n = parseInt(v, 10);
      return isNaN(n) ? def : n;
   }

   function rootFromDescendant(el) {
      return el.closest ? el.closest(CONTAINER_SEL) : null;
   }
   function isInsideContainer(node, container) {
      return !!(node && container && container.contains(node));
   }
   // Returns true when the root is the FAB carrying merged progress
   // entries. In that mode, FAB.js owns the open/close state and the
   // hover bindings, so we must not duplicate them here.
   function isBridged(root) {
      return !!(root && root.classList && root.classList.contains('fab-container'));
   }

   // The .progress-items wrapper can end up in one of three places:
   //   - inside .progress-container         (standalone)
   //   - inside .fab-container .sub-buttons (bridged - moved by progress_fab_bridge.js)
   //   - briefly inside a freshly-rendered .progress-container after an
   //     APEX region refresh, before the bridge has had a chance to
   //     re-marshall it into the FAB. (APEX's TableModelView re-renders
   //     .progress-container and may replace the wrapper there.)
   // findItemsWrap walks the candidate roots in priority order so that
   // applyUpdate / layout / etc. always operate on the wrapper that is
   // currently in the DOM, even if it's not where we expected. Without
   // this fallback, a row update arriving in the gap between the APEX
   // re-render and the bridge re-run logs:
   //   "applyUpdate() - .progress-items wrapper not found"
   // and silently drops the update.
   function findItemsWrap(root) {
      var w = root && root.querySelector ? root.querySelector('.progress-items') : null;
      if (w) return w;
      // Try same appUser elsewhere in the document.
      var appUser = root && root.getAttribute ? root.getAttribute('data-app-user') : null;
      if (appUser) {
         var u = CSS.escape(appUser);
         var candidates = document.querySelectorAll(
            '.fab-container.has-progress[data-app-user="' + u + '"], ' +
            '.progress-container[data-app-user="' + u + '"]'
         );
         for (var i = 0; i < candidates.length; i++) {
            if (candidates[i] === root) continue;
            w = candidates[i].querySelector('.progress-items');
            if (w) return w;
         }
      }
      // Last-resort: any wrapper at all.
      return document.querySelector('.progress-items');
   }

   // A "real" progress row is a direct child of .progress-items
   // that is neither the synthetic show-all overflow row nor an
   // APEX-rendered placeholder (render="false"). The placeholder
   // exists purely so APEX renders #REPORT_BODY# when the data
   // source is empty - it must be invisible to badge counting,
   // layout, focus order, and findRow.
   var ROW_SEL       = ':scope > .progress-item:not(.progress-item--show-all):not([render="false"])';
   var FOCUSABLE_SEL = ':scope > .progress-item:not([hidden]):not([render="false"])';

   function visibleRows(root) {
      var wrap = findItemsWrap(root);
      if (!wrap) return [];
      return Array.prototype.slice.call(wrap.querySelectorAll(ROW_SEL));
   }

   // -------- row rendering (from templates) --------
   function updateRowContent(row, data) {
      if (data.state) {
         row.setAttribute('data-state', data.state);
         row.classList.remove('state-running', 'state-success', 'state-error');
         row.classList.add('state-' + data.state);
      }
      if (data.name !== undefined) {
         var nameEl = row.querySelector('.progress-item__name');
         if (nameEl) nameEl.textContent = data.name;
      }
      if (data.message !== undefined) {
         var statusEl = row.querySelector('.progress-item__status');
         if (statusEl) statusEl.textContent = data.message || '';
      }
      // Keep aria-label in sync so screen readers announce the current state
      var nameNow    = (row.querySelector('.progress-item__name')   || {}).textContent || '';
      var statusNow  = (row.querySelector('.progress-item__status') || {}).textContent || '';
      var stateNow   = row.getAttribute('data-state') || '';
      row.setAttribute(
         'aria-label',
         nameNow + (statusNow ? ' - ' + statusNow : '') + (stateNow ? ' (' + stateNow + ')' : '')
      );
   }

   // -------- live region announcement --------
   function announce(root, text) {
      var live = root.querySelector('[data-progress-live]');
      if (live) live.textContent = text;
   }

   // -------- expanded / collapsed state (a11y) --------
   // In bridged mode the FAB drives open/close, so this is a no-op:
   // there is no .progress-main, and toggling .is-open / inert here
   // would fight with FAB.js.
   function setExpanded(root, expanded) {
      if (isBridged(root)) return;
      var main  = root.querySelector('.progress-main');
      var items = findItemsWrap(root);
      if (!main || !items) return;
      root.classList.toggle('is-open', expanded);
      main.setAttribute('aria-expanded', expanded ? 'true' : 'false');
      // [inert] removes the subtree from AT tree + tab order entirely
      if (expanded) items.removeAttribute('inert');
      else          items.setAttribute('inert', '');
   }

   // -------- focusable rows (roving tabindex) --------
   function focusableRows(root) {
      var wrap = findItemsWrap(root);
      if (!wrap) return [];
      return Array.prototype.slice.call(wrap.querySelectorAll(FOCUSABLE_SEL));
   }
   function ensureRovingTabindex(root) {
      // In bridged mode, progress rows are informational and live inside
      // the FAB's role="menu" sub-buttons. They have no action of their
      // own (only show-all has an <a>, which is naturally focusable), so
      // we keep them out of the tab order and let FAB.js drive nav.
      if (isBridged(root)) {
         var rowsB = focusableRows(root);
         rowsB.forEach(function (r) { r.removeAttribute('tabindex'); });
         return;
      }
      var rows = focusableRows(root);
      if (!rows.length) return;
      rows.forEach(function (r, i) {
         // Make the row itself keyboard-focusable for Arrow key navigation.
         r.setAttribute('tabindex', i === 0 ? '0' : '-1');
      });
   }
   function focusRow(rows, idx) {
      rows.forEach(function (r) { r.setAttribute('tabindex', '-1'); });
      var target = rows[idx];
      if (target) {
         target.setAttribute('tabindex', '0');
         target.focus();
      }
   }

   function newRow(root, data) {
      var tpl = root.querySelector('template.progress-item-tpl');
      if (!tpl) return null;
      var frag = tpl.content.cloneNode(true);
      var row = frag.querySelector('.progress-item');
      row.setAttribute('data-process-id', data.process_id);
      row.classList.add('state-' + (data.state || 'running'));
      updateRowContent(row, data);
      return row;
   }

   function findRow(root, processId) {
      var wrap = findItemsWrap(root);
      if (!wrap) return null;
      return wrap.querySelector(
         ':scope > .progress-item[data-process-id="' + CSS.escape(String(processId)) +
         '"]:not([render="false"])'
      );
   }

   // -------- layout: hide overflow + show-all row --------
   function layout(root) {
      var maxVisible = toInt(root.getAttribute('data-max-visible'), 3);
      var showAllUrl = root.getAttribute('data-show-all-url') || '';
      var itemsWrap = findItemsWrap(root);
      if (!itemsWrap) {
         apex.debug.warn('progress-tracker: layout() - .progress-items wrapper not found');
         return;
      }

      var rows = visibleRows(root);
      var hiddenCount = 0;
      rows.forEach(function (row, idx) {
         if (idx < maxVisible) {
            row.removeAttribute('hidden');
         } else {
            row.setAttribute('hidden', '');
            hiddenCount++;
         }
      });
      apex.debug.info('progress-tracker: layout() total=' + rows.length + ', visible=' + Math.min(rows.length, maxVisible) + ', hidden=' + hiddenCount + ', maxVisible=' + maxVisible);

      // show-all row: present when overflow exists
      var existingShowAll = itemsWrap.querySelector('.progress-item--show-all');
      if (rows.length > maxVisible) {
         if (!existingShowAll) {
            var tpl = root.querySelector('template.progress-showall-tpl');
            if (tpl) {
               var frag = tpl.content.cloneNode(true);
               var showAll = frag.querySelector('.progress-item');
               var link = showAll.querySelector('.progress-item__link');
               if (link && showAllUrl) link.setAttribute('href', showAllUrl);
               itemsWrap.appendChild(showAll);
               apex.debug.info('progress-tracker: layout() inserted "Show all" row, href=' + (showAllUrl || '(none)'));
            } else {
               apex.debug.warn('progress-tracker: layout() overflow exists but progress-showall-tpl not found');
            }
         } else if (showAllUrl) {
            var link2 = existingShowAll.querySelector('.progress-item__link');
            if (link2) link2.setAttribute('href', showAllUrl);
         }
      } else if (existingShowAll) {
         existingShowAll.parentNode.removeChild(existingShowAll);
         apex.debug.info('progress-tracker: layout() removed "Show all" row (no more overflow)');
      }

      updateBadge(root);
   }

   // -------- badge --------
   function updateBadge(root) {
      var badge = root.querySelector('.progress-badge');
      var count = visibleRows(root).length;
      if (badge) {
         badge.textContent = count > 99 ? '99+' : String(count);
         if (count > 0) badge.classList.add('is-visible');
         else badge.classList.remove('is-visible');
      }
      // Mirror the count into the sr-only label so the main button's
      // accessible name reflects the current number of processes.
      var srCount = root.querySelector('[data-progress-count]');
      if (srCount) {
         srCount.textContent = count === 0
            ? 'No active processes'
            : (count === 1 ? '1 active process' : count + ' active processes');
      }
   }

   // -------- live-container lookup (self-healing against APEX re-renders) --------
   // Look for either a standalone .progress-container OR a bridged
   // .fab-container.has-progress that carries the same data-app-user.
   // The standalone version is excluded once .is-merged is set, so we
   // never return a hidden, gutted container after bridging.
   function liveRootFor(appUser) {
      var u = CSS.escape(appUser || '');
      return document.querySelector(
         '.progress-container:not(.is-merged)[data-app-user="' + u + '"], ' +
         '.fab-container.has-progress[data-app-user="' + u + '"]'
      );
   }

   // -------- WebSocket ops --------
   function applyUpdate(root, data) {
      if (!data || !data.process_id) {
         apex.debug.warn('progress-tracker: applyUpdate() - message missing process_id', data);
         return;
      }
      var itemsWrap = findItemsWrap(root);
      if (!itemsWrap) {
         apex.debug.warn('progress-tracker: applyUpdate() - .progress-items wrapper not found');
         return;
      }
      var row = findRow(root, data.process_id);
      var wasNew = false;
      if (!row) {
         row = newRow(root, data);
         if (row) {
            // Insert newest first (flex column-reverse places it nearest the button)
            itemsWrap.insertBefore(row, itemsWrap.firstChild);
            wasNew = true;
            apex.debug.info('progress-tracker: applyUpdate() inserted new row process_id=' + data.process_id + ', state=' + (data.state || 'running') + ', name=' + (data.name || ''));
         }
      } else {
         updateRowContent(row, data);
         apex.debug.info('progress-tracker: applyUpdate() updated row process_id=' + data.process_id + ', state=' + (data.state || '(unchanged)') + ', message=' + (data.message || ''));
      }
      layout(root);
      ensureRovingTabindex(root);

      // Announce to assistive tech (polite live region)
      var label = (data.name || ('Process ' + data.process_id));
      var detail = data.message || data.state || '';
      announce(root,
         (wasNew ? 'New: ' : 'Updated: ') + label + (detail ? ' - ' + detail : '')
      );
   }

   function applyRemove(root, processId) {
      var row = findRow(root, processId);
      var removedLabel = '';
      if (row) {
         removedLabel = (row.querySelector('.progress-item__name') || {}).textContent || ('Process ' + processId);
         row.parentNode.removeChild(row);
         apex.debug.info('progress-tracker: applyRemove() removed row process_id=' + processId);
      } else {
         apex.debug.info('progress-tracker: applyRemove() no row found for process_id=' + processId);
      }
      layout(root);
      ensureRovingTabindex(root);
      if (removedLabel) {
         announce(root, 'Removed: ' + removedLabel);
      }
   }

   // -------- open a WS per container --------
   function connect(root) {
      var wsUrl = root.getAttribute('data-ws-url');
      var appUser = root.getAttribute('data-app-user') || '';
      if (!wsUrl) {
         apex.debug.warn('progress-tracker: connect() data-ws-url is empty, skipping WebSocket connect');
         return;
      }
      var url = wsUrl + (wsUrl.indexOf('?') === -1 ? '?' : '&') + 'user=' + encodeURIComponent(appUser);

      var ws;
      var retry = 0;
      function open() {
         apex.debug.info('progress-tracker: connect() opening WebSocket url=' + url + (retry > 0 ? ', attempt=' + (retry + 1) : ''));
         try {
            ws = new WebSocket(url);
         } catch (e) {
            apex.debug.error('progress-tracker: connect() WebSocket constructor threw', e);
            schedule();
            return;
         }
         ws.addEventListener('open', function () {
            apex.debug.info('progress-tracker: ws:open - connected to ' + url);
            retry = 0;
         });
         ws.addEventListener('message', function (ev) {
            var msg;
            try { msg = JSON.parse(ev.data); }
            catch (e) {
               apex.debug.warn('progress-tracker: ws:message - failed to parse payload', ev.data);
               return;
            }
            if (!msg || !msg.type) {
               apex.debug.warn('progress-tracker: ws:message - missing type', msg);
               return;
            }

            // Re-resolve the live container on every message. APEX may have
            // replaced the region since init(), so the original `root` in
            // this closure could be detached.
            var target = liveRootFor(appUser);
            if (!target) {
               apex.debug.warn('progress-tracker: ws:message - no live container for user=' + appUser + ', closing stale socket');
               try { ws.close(); } catch (e) {}
               return;
            }
            if (target !== root) {
               apex.debug.info('progress-tracker: ws:message - original root was detached, switched to live container');
               root = target;
            }

            apex.debug.info('progress-tracker: ws:message type=' + msg.type);
            if (msg.type === 'update')      applyUpdate(root, msg.item || msg);
            else if (msg.type === 'remove') applyRemove(root, msg.process_id);
            else apex.debug.warn('progress-tracker: ws:message unknown type=' + msg.type, msg);
         });
         ws.addEventListener('close', function (ev) {
            apex.debug.info('progress-tracker: ws:close code=' + ev.code + ', reason=' + (ev.reason || '(none)') + ', wasClean=' + ev.wasClean);
            schedule();
         });
         ws.addEventListener('error', function (ev) {
            apex.debug.error('progress-tracker: ws:error - connection error, will close and retry', ev);
            try { ws.close(); } catch (e) {}
         });
      }
      function schedule() {
         retry = Math.min(retry + 1, 6);
         var delay = Math.min(1000 * Math.pow(2, retry), 30000);
         apex.debug.info('progress-tracker: schedule() reconnecting in ' + delay + 'ms (retry #' + retry + ')');
         setTimeout(open, delay);
      }
      open();
   }

   // -------- per-container priming (idempotent) --------
   // Sets the initial collapsed state and binds mouseenter/mouseleave
   // (which don't bubble, so they're per-element). Safe to call again
   // after APEX re-renders the region; if .progress-container itself
   // was replaced, the new element has no __progressHoverBound flag,
   // and prime() will rebind on it.
   function prime(root) {
      // Bridged mode: FAB.js is the single source of truth for open
      // state, [inert], and hover. Skip everything here so we don't
      // double-bind or fight FAB.js for the .is-open class.
      if (isBridged(root)) return;

      var main  = root.querySelector('.progress-main');
      var items = findItemsWrap(root);
      if (!main || !items) return;

      if (!root.classList.contains('is-open')) {
         items.setAttribute('inert', '');
         main.setAttribute('aria-expanded', 'false');
      }

      if (!root.__progressHoverBound) {
         root.__progressHoverBound = true;

         root.addEventListener('mouseenter', function () {
            setExpanded(root, true);
         });

         root.addEventListener('mouseleave', function () {
            // Don't close while a keyboard user has focus inside (a
            // row is focused, or focus is on the trigger after Escape).
            if (isInsideContainer(document.activeElement, root)) return;
            setExpanded(root, false);
         });
      }
   }

   function primeAll(scope) {
      var containers = (scope || document).querySelectorAll(CONTAINER_SEL);
      apex.debug.info('progress-tracker: primeAll() containers=' + containers.length);
      Array.prototype.forEach.call(containers, prime);
   }

   // -------- delegated handlers (bound once on document) --------
   function bindDelegated() {
      if (document.__progressDelegated) return;
      document.__progressDelegated = true;

      // ---- click: toggle on trigger; close on outside click ----
      // Both the trigger and the outside-click logic only apply in
      // standalone mode. In bridged mode there is no .progress-main
      // and FAB.js owns the outside-click close.
      document.addEventListener('click', function (ev) {
         var trigger = ev.target && ev.target.closest && ev.target.closest('.progress-main');
         if (trigger) {
            var root = trigger.closest('.progress-container:not(.is-merged)');
            if (!root) return;
            ev.stopPropagation();
            var willOpen = !root.classList.contains('is-open');
            setExpanded(root, willOpen);
            announce(root, willOpen ? 'Process list opened' : 'Process list closed');
            if (willOpen) {
               // Move keyboard focus into the first row, if any.
               ensureRovingTabindex(root);
               var rows = focusableRows(root);
               if (rows.length) rows[0].focus();
            }
            return;
         }
         // Outside-click: close any open standalone container the click
         // is outside of. (Bridged FAB containers are managed by FAB.js.)
         var openOnes = document.querySelectorAll(
            '.progress-container:not(.is-merged).is-open'
         );
         Array.prototype.forEach.call(openOnes, function (c) {
            if (!c.contains(ev.target)) setExpanded(c, false);
         });
      });

      // ---- keydown: Escape + Arrow / Home / End navigation ----
      // We query rows lazily on each keypress because APEX re-renders
      // them; cached NodeLists would point at detached nodes.
      // In bridged mode FAB.js handles all keyboard navigation, so we
      // exit early on .fab-container roots.
      document.addEventListener('keydown', function (ev) {
         var root = ev.target && ev.target.closest && ev.target.closest('.progress-container:not(.is-merged)');
         if (!root) return;

         var key  = ev.key;
         var main = root.querySelector('.progress-main');

         // Escape closes + returns focus to trigger (WCAG 3.2.1)
         if (key === 'Escape' && root.classList.contains('is-open')) {
            ev.preventDefault();
            setExpanded(root, false);
            if (main) main.focus();
            return;
         }

         if (key !== 'ArrowUp' && key !== 'ArrowDown' &&
             key !== 'Home'    && key !== 'End') {
            return;
         }

         var onMain = (document.activeElement === main);

         // ArrowUp / ArrowDown on the trigger: open + move into menu.
         if (onMain && (key === 'ArrowUp' || key === 'ArrowDown')) {
            ev.preventDefault();
            setExpanded(root, true);
            ensureRovingTabindex(root);
            var triggerRows = focusableRows(root);
            if (triggerRows.length) {
               focusRow(triggerRows, key === 'ArrowUp' ? triggerRows.length - 1 : 0);
            }
            return;
         }
         if (onMain) return;   // Home / End on the trigger does nothing

         // Otherwise, navigate within rows.
         // .progress-items uses flex-direction: column-reverse, so DOM[0]
         // is the row nearest the trigger (visually bottom) and DOM[last]
         // is the row farthest from the trigger (visually top). Keys are
         // mapped to VISUAL order so they match what the user sees:
         //   ArrowUp   -> idx + 1 (visually higher = later in DOM)
         //   ArrowDown -> idx - 1 (visually lower  = earlier in DOM)
         //   Home      -> last DOM index (visually first / top)
         //   End       -> 0           (visually last  / bottom, nearest trigger)
         var rows = focusableRows(root);
         if (!rows.length) return;
         var idx = rows.indexOf(document.activeElement);
         if (idx === -1) {
            var ancestor = document.activeElement &&
                           document.activeElement.closest &&
                           document.activeElement.closest('.progress-item');
            idx = ancestor ? rows.indexOf(ancestor) : -1;
         }
         var len  = rows.length;
         var last = len - 1;
         var next = -1;
         if      (key === 'ArrowUp')   next = (idx + 1) % len;
         else if (key === 'ArrowDown') next = (idx - 1 + len) % len;
         else if (key === 'Home')      next = last;
         else if (key === 'End')       next = 0;

         if (next < 0) return;
         ev.preventDefault();
         focusRow(rows, next);
      });
   }

   // -------- init + APEX refresh hook --------
   function init(root) {
      if (!root || root.__progressInit) return;
      root.__progressInit = true;
      apex.debug.info('progress-tracker: init() user=' + (root.getAttribute('data-app-user') || '(none)') +
         ', wsUrl=' + (root.getAttribute('data-ws-url') || '(none)') +
         ', maxVisible=' + (root.getAttribute('data-max-visible') || '(default)'));

      // Reveal a standalone container. progress_tracker.css hides
      // .progress-container by default to avoid a brief flash of the
      // big floating button before progress_fab_bridge.js can merge
      // it into a FAB. The bridge normally adds .is-ready on FAB-less
      // pages, but if the bridge isn't loaded at all we still need to
      // reveal the standalone here. Bridged FAB roots aren't affected
      // (they're not .progress-container) and merged standalones have
      // .is-merged -> display:none which overrides this.
      if (!isBridged(root) && !root.classList.contains('is-merged')) {
         root.classList.add('is-ready');
      }

      prime(root);                 // initial collapsed state + hover bind (no-op when bridged)
      layout(root);
      ensureRovingTabindex(root);
      connect(root);               // open WebSocket (once per container)
   }

   function initAll(scope) {
      var containers = (scope || document).querySelectorAll(CONTAINER_SEL);
      apex.debug.info('progress-tracker: initAll() found ' + containers.length + ' container(s) matching ' + CONTAINER_SEL);
      Array.prototype.forEach.call(containers, init);
   }

   // -------- bootstrap --------
   function boot() {
      bindDelegated();             // once globally
      primeAll(document);          // per-container initial state + hover bind
      initAll(document);           // open WS for each container
   }

   if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', boot);
   } else {
      boot();
   }

   // Re-prime + re-init + re-layout on every APEX render event. We
   // listen to apexreadyend (fired after APEX init - catches
   // containers rendered post-DOMContentLoaded) AND apexafterrefresh
   // (fired when a region refreshes - catches replaced containers).
   // primeAll/initAll always run on every container regardless of
   // event target, because:
   //   1. The event target may be a parent region (rootFromDescendant
   //      walks UP - it can't find a .progress-container that's a
   //      descendant of ev.target).
   //   2. Multiple containers may have been replaced in one refresh.
   //   3. Re-priming is idempotent (the __progressHoverBound flag
   //      short-circuits already-bound containers); initAll is also
   //      idempotent via __progressInit, so already-connected
   //      containers don't re-open their WebSocket.
   //
   // Why we DO call initAll on APEX events (and not only at boot):
   // When the progress region's underlying data starts empty, APEX
   // may not render the .progress-container at all (Template
   // Component report with no rows). At boot() we'd find 0
   // containers and never open a WebSocket - so when data arrives
   // and the region refreshes, the new container would be primed
   // and laid out but stay disconnected. Calling initAll here
   // ensures the WS opens as soon as the container appears.
   if (window.apex && window.apex.jQuery) {
      window.apex.jQuery(document).on('apexafterrefresh apexreadyend', function (ev) {
         primeAll(document);
         initAll(document);

         var el = ev && ev.target ? ev.target : null;
         var root = el ? (el.matches && el.matches(CONTAINER_SEL) ? el : rootFromDescendant(el)) : null;
         if (root) {
            apex.debug.info('progress-tracker: apex event - re-laying out targeted container');
            layout(root);
            ensureRovingTabindex(root);
         } else {
            apex.debug.info('progress-tracker: apex event - re-laying out all containers');
            var containers = document.querySelectorAll(CONTAINER_SEL);
            Array.prototype.forEach.call(containers, function (c) {
               layout(c);
               ensureRovingTabindex(c);
            });
         }
      });
   }

   if (location.hostname === 'localhost' || apex.debug.getLevel() >= apex.debug.LOG_LEVEL.INFO) {
      // -------- optional debug API --------
      window.__progressTracker = {
         layout:      function (root) { layout(root); },
         applyUpdate: function (root, data) { applyUpdate(root, data); },
         applyRemove: function (root, id)   { applyRemove(root, id); },
         init:        function (root)       { init(root); },
         initAll:     function ()           { initAll(document); },
         liveRoot:    function (appUser)    { return liveRootFor(appUser); }
      };
   }

})();
