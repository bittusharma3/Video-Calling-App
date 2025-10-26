// server/server.js
import http from "http";
import { WebSocketServer } from "ws";

// HTTP server (Render expects an HTTP listener)
const port = process.env.PORT || 8080;
const server = http.createServer((req, res) => {
  // Respond to HTTP and Render's port scanning requests
  if (req.method === "GET" || req.method === "HEAD") {
    res.writeHead(200, { "Content-Type": "text/plain" });
    res.end("WebSocket server is running");
  } else {
    res.writeHead(405);
    res.end();
  }
});

// WebSocket server
const wss = new WebSocketServer({ noServer: true });

// Manage rooms and waiting users
const rooms = {};
const waitingUsers = new Map();

// Room handler
function handleRoom(ws, data) {
  const roomId = data.room || "default";
  rooms[roomId] = rooms[roomId] || [];
  if (!rooms[roomId].includes(ws)) rooms[roomId].push(ws);

  rooms[roomId].forEach((client) => {
    if (client !== ws && client.readyState === ws.OPEN) {
      client.send(JSON.stringify(data));
    }
  });

  ws.on("close", () => {
    rooms[roomId] = rooms[roomId].filter((c) => c !== ws);
    if (rooms[roomId].length === 0) delete rooms[roomId];
  });
}

// Stranger match handler
function handleStranger(ws, data) {
  const key = "default";
  if (data.type === "find_stranger") {
    const waiting = waitingUsers.get(key);
    if (waiting && waiting.readyState === ws.OPEN) {
      const room = Math.random().toString(36).slice(2, 8);
      ws.room = waiting.room = room;
      rooms[room] = [ws, waiting];
      ws.send(JSON.stringify({ type: "match_found", room, role: "caller" }));
      waiting.send(JSON.stringify({ type: "match_found", room, role: "callee" }));
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

// Handle WebSocket connections and upgrades
server.on("upgrade", (req, socket, head) => {
  const { url } = req;
  wss.handleUpgrade(req, socket, head, (ws) => {
    ws.path = url;
    wss.emit("connection", ws, req);
  });
});

// On connection
wss.on("connection", (ws, req) => {
  ws.on("message", (message) => {
    let data;
    try {
      data = JSON.parse(message);
    } catch {
      return;
    }

    if (ws.path === "/rooms") handleRoom(ws, data);
    else if (ws.path === "/strangers") handleStranger(ws, data);
  });

  ws.on("close", () => {
    Object.keys(rooms).forEach((id) => {
      rooms[id] = rooms[id].filter((c) => c !== ws);
      if (rooms[id].length === 0) delete rooms[id];
    });
  });
});

server.listen(port, "0.0.0.0", () => {
  console.log(`🚀 Server running on http://0.0.0.0:${port}`);
});
