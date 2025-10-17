import { WebSocketServer } from 'ws';
const wss = new WebSocketServer({ port: 8080 });

let rooms = {};

wss.on('connection', (ws) => {
  ws.on('message', (msg) => {
    const data = JSON.parse(msg);
    const roomId = data.room || 'default';

    if (!rooms[roomId]) rooms[roomId] = [];
    if (!rooms[roomId].includes(ws)) rooms[roomId].push(ws);

    rooms[roomId].forEach(client => {
      if (client !== ws && client.readyState === 1) {
        client.send(msg);
      }
    });
  });

  ws.on('close', () => {
    Object.keys(rooms).forEach(room => {
      rooms[room] = rooms[room].filter(client => client !== ws);
    });
  });
});

console.log('WebSocket Signaling server running on ws://localhost:8080');
