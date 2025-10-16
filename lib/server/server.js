const express = require('express');
const http = require('http');
const socketIO = require('socket.io');

const app = express();

app.get('/', (req, res) => {
  res.send('Signaling server is running');
});


const server = http.createServer(app);
const io = socketIO(server, {
  cors: {
    origin: "*"
  }
});

const PORT = 3000;

io.on('connection', (socket) => {
  console.log(`New client connected: ${socket.id}`);

  // Relay offeres u send offer to other clients in the room 
  socket.on('offer', (data) => {
    socket.broadcast.emit('offer', data);
  });

  // Relay answerss to the other clients
  socket.on('answer', (data) => {
    socket.broadcast.emit('answer', data);
  });

  // Relay ICE candidatess for making the connection 
  socket.on('ice-candidate', (data) => {
    socket.broadcast.emit('ice-candidate', data);
  });

  socket.on('disconnect', () => {
    console.log(`Client disconnected: ${socket.id}`);
  });
});

server.listen(PORT, () => {
  console.log(`Signaling server is running on http://localhost:${PORT}`);
});
