// server/server.js
import http from "http";
import { WebSocketServer } from "ws";

// Create an HTTP server (common entry point)
const server = http.createServer();
const port = process.env.PORT || 8080;

// WebSocket server handling multiple paths
const wss = new WebSocketServer({ noServer: true });

// Manage room-based and stranger-matching sessions
const rooms = {};
const waitingUsers = new Map(); // key: category (e.g., "default")

// Function: handle room-based signaling
function handleRoom(ws, data) {
  const roomId = data.room || "default";

  if (!rooms[roomId]) rooms[roomId] = [];
  if (!rooms[roomId].includes(ws)) rooms[roomId].push(ws);

  rooms[roomId].forEach((client) => {
    if (client !== ws && client.readyState === 1) {
      client.send(JSON.stringify(data));
    }
  });

  ws.on("close", () => {
    rooms[roomId] = rooms[roomId].filter((client) => client !== ws);
  });
}

// Function: handle stranger-matching logic
function handleStranger(ws, data) {
  const key = "default"; // you can separate by interests later

  if (data.type === "find_stranger") {
    const waiting = waitingUsers.get(key);

    if (waiting && waiting.readyState === ws.OPEN) {
      const room = `${Math.random().toString(36).slice(2, 8)}`;
      ws.room = room;
      waiting.room = room;

      rooms[room] = [ws, waiting];

      ws.send(JSON.stringify({ type: "match_found", room, role: "caller" }));
      waiting.send(
        JSON.stringify({ type: "match_found", room, role: "callee" })
      );

      waitingUsers.delete(key);
      console.log(`✅ Matched users in room ${room}`);
    } else {
      waitingUsers.set(key, ws);
      ws.send(JSON.stringify({ type: "waiting" }));
      console.log("👤 Waiting for a partner...");
    }
  } else if (data.type === "leave" && ws.room) {
    const set = rooms[ws.room];
    if (set) {
      set.forEach((client) => {
        if (client !== ws && client.readyState === ws.OPEN) {
          client.send(JSON.stringify({ type: "peer_left" }));
        }
      });
      delete rooms[ws.room];
    }
    ws.room = null;
  } else if (ws.room && rooms[ws.room]) {
    rooms[ws.room].forEach((client) => {
      if (client !== ws && client.readyState === ws.OPEN) {
        client.send(JSON.stringify(data));
      }
    });
  }
}

// Handle WebSocket Upgrades (different endpoints)
server.on("upgrade", (req, socket, head) => {
  const { url } = req;
  wss.handleUpgrade(req, socket, head, (ws) => {
    ws.path = url;
    wss.emit("connection", ws, req);
  });
});

// Connection handler
wss.on("connection", (ws, req) => {
  ws.on("message", (message) => {
    let data;
    try {
      data = JSON.parse(message);
    } catch (e) {
      return;
    }

    if (ws.path === "/rooms") handleRoom(ws, data);
    else if (ws.path === "/strangers") handleStranger(ws, data);
  });

  ws.on("close", () => {
    // Cleanup on disconnect
    Object.keys(rooms).forEach((id) => {
      rooms[id] = rooms[id].filter((client) => client !== ws);
      if (!rooms[id].length) delete rooms[id];
    });
  });
});

server.listen(port, () => {
  console.log(`🚀 Server ready on ws://0.0.0.0:${port}`);
});
