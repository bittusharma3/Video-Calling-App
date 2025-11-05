// server/index.js
const express = require('express');
const http = require('http');
const WebSocket = require('ws');
const crypto = require('crypto');

const app = express();
app.use(express.json());

const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

const PORT = process.env.PORT || 8080;

const rooms = new Map(); // roomId => [ws, ws]
const clientMeta = new Map(); // ws => { room }
const waitingQueue = []; // for random pairing

function send(ws, obj) {
  try { ws.send(JSON.stringify(obj)); } catch (e) { /* ignore */ }
}

function randomRoomId() {
  return crypto.randomBytes(3).toString('hex'); // 6 hex chars
}

function addToRoom(room, ws) {
  if (!rooms.has(room)) rooms.set(room, []);
  const arr = rooms.get(room);
  if (!arr.includes(ws)) arr.push(ws);
  clientMeta.set(ws, { room });
  console.log('Added client to room', room, 'members:', arr.length);
  if (arr.length === 2) {
    arr.forEach(client => send(client, { type: 'joined', room }));
  } else {
    send(ws, { type: 'joined', room });
  }
}

function removeClient(ws) {
  const meta = clientMeta.get(ws);
  if (!meta) return;
  const room = meta.room;
  const arr = rooms.get(room) || [];
  const idx = arr.indexOf(ws);
  if (idx !== -1) arr.splice(idx, 1);
  if (arr.length === 0) rooms.delete(room);
  else rooms.set(room, arr);
  clientMeta.delete(ws);
  const qi = waitingQueue.indexOf(ws);
  if (qi !== -1) waitingQueue.splice(qi, 1);
  console.log('Client removed from room', room);
}

wss.on('connection', (ws) => {
  console.log('WS connected');

  ws.on('message', (message) => {
    let data;
    try { data = JSON.parse(message); } catch (e) { return; }
    const type = data.type;
    if (type === 'join') {
      const room = String(data.room || '').trim();
      if (!room) { send(ws, { type: 'error', message: 'no room provided' }); return; }
      addToRoom(room, ws);
    } else if (type === 'find') {
      if (waitingQueue.length > 0) {
        const other = waitingQueue.shift();
        const room = randomRoomId();
        addToRoom(room, other);
        addToRoom(room, ws);
        send(other, { type: 'match', room, role: 'callee' });
        send(ws, { type: 'match', room, role: 'caller' });
        console.log('Paired random:', room);
      } else {
        waitingQueue.push(ws);
        send(ws, { type: 'waiting' });
      }
    } else if (type === 'offer' || type === 'answer' || type === 'candidate' || type === 'leave') {
      const meta = clientMeta.get(ws);
      if (!meta || !meta.room) return;
      const arr = rooms.get(meta.room) || [];
      arr.forEach(client => {
        if (client !== ws) {
          send(client, data);
        }
      });
      if (type === 'leave') removeClient(ws);
    }
  });

  ws.on('close', () => {
    removeClient(ws);
    console.log('WS closed');
  });

  ws.on('error', () => {
    removeClient(ws);
  });
});

app.get('/health', (req, res) => res.json({ ok: true }));

server.listen(PORT, () => console.log(`Signaling server running on port ${PORT}`));
