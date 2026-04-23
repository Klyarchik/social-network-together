const admin = require("firebase-admin");
const serviceAccount = require("../json/social-network-together-firebase-adminsdk-fbsvc-66ea60f196.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const sendNotification = async (token_device, title, text) => {
  const message = {
    notification: {
      title: title,
      body: text,
    },
    token: token_device,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log(`Уведомление успешно отправлено: ${response}`);
  } catch (error) {
    console.error(
      `Произошла ошибка при отправке уведомления из firebase.notifications: ${error.message}`,
    );
    throw error;
  }
};


module.exports = { sendNotification };
