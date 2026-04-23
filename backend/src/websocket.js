const WebSocket = require("ws");
const jwt = require("jsonwebtoken");
const prisma = require("./client");
const { sendNotification } = require("./services/firebase.notifications");

const connections = {};

const initWebSocket = (server) => {
  const wss = new WebSocket.Server({ server: server, path: "/chat" });

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

        //отправка уведомления получателю
        try {
          const senderUser = await prisma.users.findUnique({
            where: { id: id },
          });

          if (!senderUser) {
            return console.error(
              `Ошибка: отправитель сообщения не найден в БД`,
            );
          }

          const recipientUser = await prisma.users.findUnique({
            where: { id: to },
          });

          if (!recipientUser) {
            return console.error(`Ошибка: получатель сообщения не найден в БД`);
          }

          const title = senderUser.username;
          const token_devices = recipientUser.token_device;

          if (!token_devices || token_devices.length === 0) {
            return console.error(
              `У пользователя нет ни одного токена устройства`,
            );
          }

          for (const token_device of token_devices) {
            try {
              await sendNotification(token_device, title, text);
            } catch (error) {
              console.error(`Ошибка при отправке на токен устройства ${token_device}:`, error.message);
            }
          }
        } catch (error) {
          console.error(
            `Произошла ошибка при отправке увеломления из ws: ${error.message}`,
          );
        }
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
