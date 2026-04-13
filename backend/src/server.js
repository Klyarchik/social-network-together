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

const app = express();

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

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT} http://localhost:${PORT}/api-docs`);
});