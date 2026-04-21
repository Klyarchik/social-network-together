const WebSocket = require('ws');
const jwt = require('jsonwebtoken');
const prisma = require('./client');

const connections = {};

const initWebSocket = (server) => {
  const wss = new WebSocket.Server({ server, path: '/chat' });

  wss.on('connection', (ws, req) => {
    const fullUrl = new URL(req.url, `http://${req.headers.host}`);
    const token = fullUrl.searchParams.get('token');

    if (!token) {
      ws.send(JSON.stringify({ type: 'error', message: 'Отсутствует "token" в query' }));
      ws.close(1008, 'Token missing');
      return;
    }

    let userId;
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret');
      if (!decoded.userId) throw new Error('No userId');
      userId = decoded.userId;
      console.log(`🔐 Аутентифицирован пользователь: ${userId}`);
    } catch (err) {
      ws.send(JSON.stringify({ type: 'error', message: 'Неверный токен' }));
      ws.close(1008, 'Invalid token');
      return;
    }

    const from = Number(userId);
    connections[from] = ws;
    console.log(`✅ Клиент ${userId} подключился`);
    ws.send(JSON.stringify({ type: 'connected', userId }));

    ws.on('message', async (message) => {
      try {
        const data = JSON.parse(message.toString());
        const to = Number(data.to);
        const text = data.text;

        if (!to || !text) {
          ws.send(JSON.stringify({ type: 'error', message: 'Missing "to" or "text"' }));
          return;
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
          type: 'message',
          message: {
            id: chatMessage.id,
            from: chatMessage.user_from,
            to: chatMessage.user_to,
            text: chatMessage.text,
            createdAt: chatMessage.created_at,
          },
        };

        // Отправляем получателю, если он онлайн
        const recipientWs = connections[to];
        if (recipientWs && recipientWs.readyState === WebSocket.OPEN) {
          recipientWs.send(JSON.stringify(messageData));
        } else {
          console.warn(`⚠️ Получатель ${to} не в сети, сообщение сохранено в БД`);
        }

        // Отправляем отправителю подтверждение (не дублируем само сообщение)
        ws.send(JSON.stringify({ type: 'Отправлено', messageId: chatMessage.id }));
      } catch (err) {
        console.error('Ошибка при обработке сообщения:', err);
        ws.send(JSON.stringify({ type: 'error', message: 'Internal server error' }));
      }
    });

    ws.on('close', () => {
      delete connections[from];
      console.log(`❌ Клиент ${userId} отключился`);
    });
  });

  console.log('🔌 WebSocket сервер привязан к пути /chat');
}

module.exports = { initWebSocket };