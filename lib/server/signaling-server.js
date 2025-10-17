// server/signaling-server.js
const WebSocket = require("ws");
const port = process.env.PORT || 8080;
const wss = new WebSocket.Server({ port });
console.log("Signaling server running on ws://localhost:" + port);

const rooms = new Map();
wss.on("connection", (ws) => {
  ws.room = null;
  ws.on("message", (raw) => {
    let msg;
    try { msg = JSON.parse(raw.toString()); } catch { return; }
    if (msg.type === 'join') {
      const room = msg.room;
      ws.room = room;
      if (!rooms.has(room)) rooms.set(room, new Set());
      rooms.get(room).add(ws);
      console.log(`Client joined ${room}`);
      return;
    }
    // forward to other peers in room
    const set = rooms.get(ws.room) || new Set();
    for (const client of set) {
      if (client !== ws && client.readyState === WebSocket.OPEN) {
        client.send(JSON.stringify(msg));
      }
    }
  });

  ws.on('close', () => {
    if (ws.room && rooms.has(ws.room)) {
      const set = rooms.get(ws.room);
      set.delete(ws);
      if (!set.size) rooms.delete(ws.room);
    }
  });
});
