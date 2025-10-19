// server/signaling-server.js
const WebSocket = require("ws");
const port = process.env.PORT || 8080;
const wss = new WebSocket.Server({ port });

console.log("🚀 Signaling server running on ws://localhost:" + port);

const rooms = new Map();
let waitingUser = null; // queue for one user

wss.on("connection", (ws) => {
  ws.room = null;

  ws.on("message", (raw) => {
    let msg;
    try {
      msg = JSON.parse(raw.toString());
    } catch {
      return;
    }

    // === Handle Find Stranger ===
    if (msg.type === "find_stranger") {
      if (waitingUser && waitingUser.readyState === WebSocket.OPEN) {
        const roomId = Math.random().toString().substring(2, 8);
        ws.room = roomId;
        waitingUser.room = roomId;

        if (!rooms.has(roomId)) rooms.set(roomId, new Set());
        rooms.get(roomId).add(ws);
        rooms.get(roomId).add(waitingUser);

        ws.send(JSON.stringify({ type: "match_found", room: roomId, role: "caller" }));
        waitingUser.send(JSON.stringify({ type: "match_found", room: roomId, role: "callee" }));

        console.log(`✅ Matched users in room ${roomId}`);
        waitingUser = null;
      } else {
        waitingUser = ws;
        ws.send(JSON.stringify({ type: "waiting" }));
        console.log("👤 User waiting for partner...");
      }
      return;
    }

    // === Handle Leave ===
    if (msg.type === "leave") {
      if (ws.room && rooms.has(ws.room)) {
        const set = rooms.get(ws.room);
        set.forEach((client) => {
          if (client !== ws && client.readyState === WebSocket.OPEN) {
            client.send(JSON.stringify({ type: "peer_left" }));
          }
        });
        rooms.delete(ws.room);
      }
      ws.room = null;
      return;
    }

    // === Forward Offer/Answer/ICE ===
    if (ws.room && rooms.has(ws.room)) {
      const set = rooms.get(ws.room);
      for (const client of set) {
        if (client !== ws && client.readyState === WebSocket.OPEN) {
          client.send(JSON.stringify(msg));
        }
      }
    }
  });

  ws.on("close", () => {
    if (ws === waitingUser) waitingUser = null;
    if (ws.room && rooms.has(ws.room)) {
      const set = rooms.get(ws.room);
      set.delete(ws);
      if (!set.size) rooms.delete(ws.room);
    }
  });
});
