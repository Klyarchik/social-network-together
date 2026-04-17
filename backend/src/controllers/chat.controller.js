const prisma = require('../client');
const WebSocket = require('ws');

// const wss = new WebSocket.Server({ port: 3000, path: '/chat' });

// const connections = {};

// wss.on('connection', (ws) => {
//   connections[ws] = { userId: null };

//   ws.on('message', async (message) => {
//     try {
//       const data = JSON.parse(message);
//       if (data.type === 'auth') {
//         connections[ws].userId = data.userId;
//         ws.send(JSON.stringify({ type: 'auth', success: true }));
//       } else if (data.type === 'message') {
//         const { userId } = connections[ws];
//         if (!userId) {
//           return ws.send(JSON.stringify({ type: 'error', message: 'Unauthorized' }));
//         }
//         const { content } = data;
//         const chatMessage = await prisma.chatMessages.create({
//           data: {
//             userId,
//             content,
//           },
//         });
//         const messageData = {
//           type: 'message',
//           message: {
//             id: chatMessage.id,
//             userId,
//             content,
//             createdAt: chatMessage.createdAt,
//           },
//         };
//         Object.keys(connections).forEach((client) => {
//           if (connections[client].userId) {
//             client.send(JSON.stringify(messageData));
//           }
//         });
//       }
//     } catch (error) {
//       console.error('Error processing message:', error);
//       ws.send(JSON.stringify({ type: 'error', message: 'Internal server error' }));
//     }
//   });

//   ws.on('close', () => {
//     delete connections[ws];
//   });
// });


const wss = new WebSocket.Server({ port: 3000, path: '/chat' });

const connections = {};

wss.on('connection', (ws) => {
  connections[ws] = { userId: null };

  ws.on('message', async (message) => {
    try {

      console.log('Получено сообщение: ', message);
      const data = JSON.parse(message);

    } catch (error) {
      console.error('Ошибка при обработке сообщения: ', error);
      ws.send(JSON.stringify({ type: 'error', message: 'Internal server error' }));
    }
  })
})