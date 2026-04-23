// dotenv
require("dotenv").config();

// библиотеки
const express = require("express");
const cors = require("cors");

// призма
const prisma = require("./client");

// swagger
const swaggerUi = require("swagger-ui-express");
const swaggerDocument = require("./json/swagger-output.json");

// маршруты
const routes = require("./routes/index");

// WebSocket
const { initWebSocket } = require('./websocket')

// http для WebSocket
const http = require('http');

const app = express();

const server = http.createServer(app);

initWebSocket(server);

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