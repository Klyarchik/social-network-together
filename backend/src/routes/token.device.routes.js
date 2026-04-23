const express = require("express");
const router = express.Router();
const { authMiddleware } = require("../middlewares/auth.middleware");
const { registerDeviceToken } = require('../controllers/token.device.controller');

router.post(
  "/token-device",
  authMiddleware,
  /* #swagger.tags = ['token'] #swagger.summary = 'Регистрация токена устройства' */
  registerDeviceToken,
);

module.exports = router;
