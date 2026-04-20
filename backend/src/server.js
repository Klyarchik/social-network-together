// dotenv
require("dotenv").config();

// библиотеки
const express = require("express");
const cors = require("cors");

// призма
const prisma = require("./client");

// swagger
const swaggerUi = require("swagger-ui-express");
const swaggerDocument = require("./swagger-output.json");

// маршруты
const routes = require("./routes/index");

// WebSocket
const WebSocket = require('ws');

// http для WebSocket
const http = require('http');

const app = express();

const server = http.createServer(app);

// WebSocket слушатель
const wss = new WebSocket.Server({ server: server, path: '/chat' });

const connections = {};

wss.on('connection', (ws, req) => {

  if (!req.headers['id']) {
    ws.send(JSON.stringify({ type: 'error', message: 'Отсутствует "id" в header' }));
    return ws.close();
  }

  const from = parseInt(req.headers['id']);
  connections[from] = ws;

  console.log('Клиент подключился: ', req.headers['id']);
  ws.send(JSON.stringify({ message: 'Подключение успешно установлено' }));

  ws.on('message', async (message) => {
    try {
      const data = JSON.parse(message.toString());
      const to = parseInt(data.to);
      const text = data.text;

      if (!to || !text) {
        return ws.send(JSON.stringify({ type: 'error', message: 'Missing "to" or "text" field' }));
      }

      const chatMessage = await prisma.chat_messages.create({
        data: {
          user_from: from,
          user_to: to,
          text: text,
          created_at: new Date()
        },
      });

      const messageData = {
        type: 'message',
        message: {
          id: chatMessage.id,
          from: chatMessage.user_from,
          to: chatMessage.user_to,
          text: chatMessage.text,
          createdAt: chatMessage.created_at,
        },
      };

      const recipientWs = connections[to];
      if (recipientWs && recipientWs.readyState === WebSocket.OPEN) {
        recipientWs.send(JSON.stringify(messageData));
      } else {
        console.warn('Получатель не подключен или соединение закрыто: ', to, '\n Сообщение сохранено в базе данных');
      }

      ws.send(JSON.stringify(messageData));
    } catch (error) {
      console.error('Ошибка при обработке сообщения: ', error);
      ws.send(JSON.stringify({ type: 'error', message: 'Internal server error' }));
    }
  })

  ws.on('close', () => {
    delete connections[from];
    console.log('Клиент отключился: ', from);
  });
});

app.use(cors({
  origin: '*',
  methods: '*',
  allowedHeaders: '*',
  credentials: true
}));

app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerDocument));

app.use(express.json());

app.use("/api", routes);

const PORT = process.env.PORT || 3000;

server.listen(PORT, () => {
  console.log(`📚 Swagger документация: http://localhost:${PORT}/api-docs`);
});