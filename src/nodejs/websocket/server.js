// ============================================================
// APEX Process Tracker - WebSocket bridge (LOCAL DEV - no auth)
//
// Stateless forwarder. The server holds no process data.
//
//  POST /ingest        (called by PL/SQL on every status change)
//                      body: { process_id, app_user, name,
//                              message, state, started_at, updated_at }
//                      -> broadcast { type:'update', item: <body> }
//                         to every open WS for that app_user
//
//  WS  /ws?user=JOERG  (opened by the browser; app_user passed
//                       directly, no token validation)
//                      -> no snapshot; initial rows come from APEX
//                         which loads them from the DB on page load.
// ============================================================

// ============================================================
// APEX Process Tracker - WebSocket bridge (LOCAL DEV)
// ATTENTION: NO AUTH ! (for local dev)

import express from 'express';
import { WebSocketServer } from 'ws';
import http from 'node:http';

// -------------------- config --------------------
const PORT = process.env.PORT || 8090;

// -------------------- logging --------------------
function ts () {
   return new Date().toISOString();
}
function log (...args) {
   console.log(`[${ts()}]`, ...args);
}
function logWarn (...args) {
   console.warn(`[${ts()}] WARN`, ...args);
}
function logErr (...args) {
   console.error(`[${ts()}] ERROR`, ...args);
}

// -------------------- in-memory sockets --------------------
// app_user -> Set<WebSocket>
const socketsByUser = new Map();

function getUserSockets (user) {
   if (!socketsByUser.has(user)) socketsByUser.set(user, new Set());
   return socketsByUser.get(user);
}

function broadcast (user, message) {
   const sockets = getUserSockets(user);
   const payload = JSON.stringify(message);
   let sent = 0;
   for (const ws of sockets) {
      if (ws.readyState === ws.OPEN) {
         ws.send(payload);
         sent++;
      }
   }
   log(`broadcast -> user="${user}" type=${message.type} clients=${sent}/${sockets.size}`);
   return sent;
}

// -------------------- HTTP side (ingest) --------------------
const app = express();

// Access log - every incoming request
app.use((req, res, next) => {
   const start = Date.now();
   const ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress;
   log(`HTTP  ${req.method} ${req.url}  from ${ip}`);
   res.on('finish', () => {
      const dur = Date.now() - start;
      log(`HTTP  ${req.method} ${req.url} -> ${res.statusCode} (${dur}ms)`);
   });
   next();
});

// Permissive CORS for local dev / browser-console testing.
app.use((req, res, next) => {
   res.header('Access-Control-Allow-Origin',  '*');
   res.header('Access-Control-Allow-Headers', 'Content-Type');
   res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
   if (req.method === 'OPTIONS') return res.sendStatus(204);
   next();
});

app.use(express.json({ limit: '1mb' }));

app.get('/health', (_req, res) => res.json({ ok: true }));

app.post('/ingest', (req, res) => {
   const p = req.body;
   log('ingest body:', JSON.stringify(p));

   if (!p?.process_id || !p?.app_user || !p?.state) {
      logWarn('ingest rejected: missing fields (need process_id, app_user, state)');
      return res.status(400).json({ error: 'missing fields' });
   }

   log(`ingest FORWARD user="${p.app_user}" process_id="${p.process_id}" state=${p.state} name="${p.name || ''}" msg="${p.message || ''}"`);

   // Stateless forward. Client decides how to render/remove/filter.
   broadcast(p.app_user, { type: 'update', item: p });

   res.json({ ok: true });
});

app.use((err, _req, res, _next) => {
   logErr('express error:', err.stack || err);
   res.status(500).json({ error: 'server error' });
});

// -------------------- WebSocket side --------------------
const server = http.createServer(app);
const wss = new WebSocketServer({ noServer: true });

server.on('upgrade', (req, socket, head) => {
   const ip = req.headers['x-forwarded-for'] || socket.remoteAddress;
   const url = new URL(req.url, `http://${req.headers.host}`);
   log(`WS    upgrade ${req.url} from ${ip}`);
   if (url.pathname !== '/ws') {
      logWarn(`WS    upgrade rejected: wrong path "${url.pathname}"`);
      socket.destroy();
      return;
   }
   const user = url.searchParams.get('user');
   if (!user) {
      logWarn('WS    upgrade rejected: missing ?user= query param');
      socket.write('HTTP/1.1 400 Bad Request\r\n\r\n');
      socket.destroy();
      return;
   }
   wss.handleUpgrade(req, socket, head, (ws) => {
      ws.appUser = user;
      wss.emit('connection', ws, req);
   });
});

wss.on('connection', (ws) => {
   const user = ws.appUser;
   getUserSockets(user).add(ws);
   log(`WS    connect   user="${user}" clients_for_user=${getUserSockets(user).size}`);

   // No snapshot. Initial rows come from APEX's SQL query at page load.

   ws.on('close', (code, reason) => {
      getUserSockets(user).delete(ws);
      log(`WS    close     user="${user}" code=${code} reason="${reason || ''}" clients_for_user=${getUserSockets(user).size}`);
   });

   ws.on('error', (err) => {
      logErr(`WS    error     user="${user}"`, err.message || err);
   });

   ws.on('message', (msg) => {
      try {
         const m = JSON.parse(msg.toString());
         if (m.type === 'ping') {
            ws.send(JSON.stringify({ type: 'pong' }));
         } else {
            log(`WS    message   user="${user}" type=${m.type}`);
         }
      } catch {
         logWarn(`WS    message   user="${user}" unparseable payload`);
      }
   });
});

// -------------------- start --------------------
server.listen(PORT, () => {
   log(`process-tracker listening on http://localhost:${PORT}`);
   log(`   POST  /ingest   - PL/SQL posts status updates here`);
   log(`   WS    /ws?user= - browser opens this per user`);
   log(`   GET   /health   - liveness probe`);
   log(`   (stateless forwarder - no snapshots, no TTL, no caching)`);
});

// Graceful shutdown logging
process.on('SIGINT',  () => { log('SIGINT received, exiting');  process.exit(0); });
process.on('SIGTERM', () => { log('SIGTERM received, exiting'); process.exit(0); });
process.on('uncaughtException',  (err) => { logErr('uncaughtException:',  err.stack || err); });
process.on('unhandledRejection', (err) => { logErr('unhandledRejection:', err?.stack || err); });
