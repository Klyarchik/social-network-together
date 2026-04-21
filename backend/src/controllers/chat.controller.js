const prisma = require('../client');

const getMessagesWithChooseUser = async (req, res) => {
  try {
    const idChooseUser = req.query.idChooseUser;

    if(!idChooseUser) {
      return res.status(404).json({ error: "id второго пользователя обязателен" })
    }

    const allMessages = await prisma.chat_messages.findMany({
      where: {
        OR: [
          { user_from: req.user.userId, user_to: Number(idChooseUser) },
          { user_from: Number(idChooseUser), user_to: req.user.userId }
        ]
      },
      orderBy: { created_at: 'asc' }
    });

    res.status(200).json({ allMessages: allMessages })
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

module.exports = {
  getMessagesWithChooseUser
}