const prisma = require('../client');

// регистрация токена устройства
const registerDeviceToken = async (req, res) => {
  try {
    const token_device = req.body.token_device;
    const userId = req.user.userId;

    if (!token_device) {
      return res.status(400).json({ error: "Токен устройства обязателен" });
    }

    if (!userId) {
      return res.status(400).json({ error: "id пользователя обязателен" });
    }

    const user = await prisma.users.findUnique({
      where: { id: userId },
    });

    if (!user) {
      return res.status(404).json({ error: "Пользователь не найден" });
    }

    const tokens = user.token_device || [];

    if (!tokens.includes(token_device)) {
      tokens.push(token_device);

      await prisma.users.update({
        where: { id: userId },
        data: { token_device: tokens },
      });
    }

    res.status(200).json({ message: "success" });
  } catch (error) {
    console.error(
      `Произошла ошибка при регистрации токена устройства: ${error.message}`,
    );
    res.status(500).json({ error: "Internal server error" });
  }
};

module.exports = { registerDeviceToken };