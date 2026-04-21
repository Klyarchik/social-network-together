const WebSocket = require("ws");
const jwt = require("jsonwebtoken");
const prisma = require("./client");

const connections = {};

const initWebSocket = (server) => {
  const wss = new WebSocket.Server({ server: server, path: "/chat" });

  const connections = {};

  wss.on("connection", (ws, req) => {
    const fullUrl = new URL(`http://localhost${req.url}`);
    const token = fullUrl.searchParams.get("token");

    if (!token) {
      ws.send(
        JSON.stringify({
          type: "error",
          message: 'Отсутствует "token" в query',
        }),
      );
      return ws.close();
    }

    let id;

    try {
      const decodedToken = jwt.verify(
        token,
        process.env.JWT_SECRET || "secret",
      );
      if (decodedToken.userId) {
        id = decodedToken.userId;
        console.log(`id пользователя: ${id}`);
      } else {
        ws.send(
          JSON.stringify({ type: "error", message: "Неверный token в query" }),
        );
        return ws.close();
      }
    } catch (error) {
      ws.send(
        JSON.stringify({ type: "error", message: "Неверный token в query" }),
      );
      return ws.close();
    }

    const from = parseInt(id);
    connections[from] = ws;

    console.log("Клиент подключился: ", id);
    ws.send(JSON.stringify({ message: "Подключение успешно установлено" }));

    ws.on("message", async (message) => {
      try {
        const data = JSON.parse(message.toString());
        const to = parseInt(data.to);
        const text = data.text;

        if (!to || !text) {
          return ws.send(
            JSON.stringify({
              type: "error",
              message: 'Missing "to" or "text" field',
            }),
          );
        }

        const chatMessage = await prisma.chat_messages.create({
          data: {
            user_from: from,
            user_to: to,
            text: text,
            created_at: new Date(),
          },
        });

        const messageData = {
          type: "message",
          message: {
            id_message: chatMessage.id_message,
            user_from: chatMessage.user_from,
            user_to: chatMessage.user_to,
            text: chatMessage.text,
            createdAt: chatMessage.created_at,
          },
        };

        const recipientWs = connections[to];
        if (recipientWs && recipientWs.readyState === WebSocket.OPEN) {
          recipientWs.send(JSON.stringify(messageData));
        } else {
          console.warn(
            "Получатель не подключен или соединение закрыто: ",
            to,
            "\n Сообщение сохранено в базе данных",
          );
        }

        ws.send(JSON.stringify(messageData));
      } catch (error) {
        console.error("Ошибка при обработке сообщения: ", error);
        ws.send(
          JSON.stringify({ type: "error", message: "Internal server error" }),
        );
      }
    });

    ws.on("close", () => {
      delete connections[from];
      console.log("Клиент отключился: ", from);
    });
  });

  console.log("🔌 WebSocket сервер привязан к пути /chat");
};

module.exports = { initWebSocket };
