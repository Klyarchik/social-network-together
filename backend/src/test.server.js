const express = require("express");
const http = require("http");
const WebSocket = require("ws");

// создаём express приложение
const app = express();

// простой HTTP маршрут
app.get("/", (req, res) => {
  res.send("Hello from Express + WebSocket server");
});

// создаём HTTP сервер (важно для ws)
const server = http.createServer(app);

// создаём WebSocket сервер поверх HTTP
const wss = new WebSocket.Server({ server, path: "/ws" });

// обработка подключений
wss.on("connection", (ws) => {
  console.log("🔌 Client connected");

  // отправим приветствие
  ws.send("Welcome! You are connected to WebSocket server");

  // обработка сообщений от клиента
  ws.on("message", (message) => {
    const text = message.toString();
    console.log("📩 Recheived:", text);

    // пример 1: echo (отправить обратно)
    ws.send(`Echo: ${text}`);

    // пример 2: broadcast всем клиентам
    wss.clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(`Broadcast: ${text}`);
      }
    });
  });

  ws.on("close", () => {
    console.log("❌ Client disconnected");
  });
});

// запускаем сервер
const PORT = 3000;
server.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});