/* ============================================================
   Process Tracker - browser-console smoke test
   ------------------------------------------------------------
   Paste this whole file into the DevTools console of any page
   (APEX, a blank tab, whatever) while the Node server is running
   on localhost:8090.

   It exposes window.tracker with helpers:

      tracker.connect()              // open WS
      tracker.disconnect()           // close WS
      tracker.start(id, name)        // POST /ingest  state=running
      tracker.update(id, msg)        // POST /ingest  running + new message
      tracker.finish(id, 'success')  // POST /ingest  state=success/error
      tracker.health()               // GET  /health
      tracker.demo()                 // runs a full start->update->finish
                                     // sequence and logs what the WS sees

   All messages received on the WS are logged to the console.
   ============================================================ */

(() => {
   const BASE = 'http://localhost:8090';
   const WS   = 'ws://localhost:8090/ws';
   const USER = 'TESTUSER';

   let socket = null;

   const sleep = (ms) => new Promise(r => setTimeout(r, ms));

   function nowIso () {
      return new Date().toISOString().replace(/\.\d+Z$/, '');
   }

   function connect () {
      if (socket && socket.readyState <= 1) {
         console.log('[tracker] already connected / connecting');
         return socket;
      }
      const url = `${WS}?user=${encodeURIComponent(USER)}`;
      console.log('[tracker] connecting to', url);
      socket = new WebSocket(url);

      socket.addEventListener('open',    () => console.log('[tracker] WS open'));
      socket.addEventListener('close',   (e) => console.log('[tracker] WS close', e.code, e.reason));
      socket.addEventListener('error',   (e) => console.warn('[tracker] WS error', e));
      socket.addEventListener('message', (e) => {
         try {
            const m = JSON.parse(e.data);
            console.log('[tracker] ◄', m.type, m);
         } catch {
            console.log('[tracker] ◄ (raw)', e.data);
         }
      });
      return socket;
   }

   function disconnect () {
      if (socket) { socket.close(); socket = null; }
   }

   async function ingest (payload) {
      const body = {
         app_user:            USER,
         name:                payload.name || 'Demo process',
         last_status_message: payload.message || '',
         state:               payload.state   || 'running',
         started_at:          payload.started_at || nowIso(),
         updated_at:          nowIso(),
         ...payload
      };
      const r = await fetch(`${BASE}/ingest`, {
         method:  'POST',
         headers: { 'Content-Type': 'application/json' },
         body:    JSON.stringify(body)
      });
      const j = await r.json().catch(() => ({}));
      console.log('[tracker] ► POST /ingest', body, '→', r.status, j);
      return j;
   }

   function start  (id, name)            { return ingest({ process_id: id, name, state: 'running', message: 'started' }); }
   function update (id, message)         { return ingest({ process_id: id, state: 'running', message }); }
   function finish (id, state, message)  { return ingest({ process_id: id, state: state || 'success', message: message || state || 'done' }); }

   async function health () {
      const r = await fetch(`${BASE}/health`);
      const j = await r.json();
      console.log('[tracker] health', j);
      return j;
   }

   async function demo () {
      if (!socket) connect();
      // Give the WS a moment to open / receive the snapshot
      await sleep(300);

      const id = 'DEMO_' + Date.now();
      console.log('%c[tracker] --- DEMO SEQUENCE ---', 'color:#2b5fd9;font-weight:bold');

      await start(id, 'Browser demo');
      await sleep(600);
      await update(id, 'Processing batch 1 of 3');
      await sleep(600);
      await update(id, 'Processing batch 2 of 3');
      await sleep(600);
      await update(id, 'Processing batch 3 of 3');
      await sleep(600);
      await finish(id, 'success', 'All done');
      console.log('%c[tracker] --- DEMO DONE ---', 'color:#1d8a4e;font-weight:bold');
      console.log('Node will send a "remove" message for', id, 'in ~30s.');
   }

   window.tracker = { connect, disconnect, start, update, finish, health, demo };

   console.log(
      '%c[tracker] loaded. Try:  tracker.health()   tracker.connect()   tracker.demo()',
      'color:#2b5fd9;font-weight:bold'
   );
})();
