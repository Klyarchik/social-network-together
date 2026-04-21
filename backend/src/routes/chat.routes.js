const express = require("express");
const router = express.Router();
const { getMessagesWithChooseUser } = require('../controllers/chat.controller');
const { authMiddleware } = require("../middlewares/auth.middleware");

router.post(
  "/all-mesagges",
  authMiddleware,
  /* #swagger.tags = ['Chat'] #swagger.summary = 'Получение сообщений с выбранным польозователем' */
  getMessagesWithChooseUser,
);

module.exports = router;