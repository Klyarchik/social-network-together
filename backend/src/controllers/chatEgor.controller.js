const { text } = require('express');
const prisma = require('../client');
const WebSocket = require('ws');

// Сервер
const wss = new WebSocket.Server({ port: 8080, path: '/ws1' });

const connections = {}

wss.on('connection', (ws, req) => {
  console.log('Клиент подключился');
  console.log(req.headers['id']);
  connections[req.headers['id']] = ws;
  ws.on('message', (data) => {
    const info1 = JSON.parse(data.toString());
    connections[info.to].send({ text: info1.text , from: req.headers['id']});
  });
});
