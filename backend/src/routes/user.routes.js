const express = require("express");
const router = express.Router();
const {
  register,
  entrance,
  getCurrentUserData,
  updateCurrentUserData,
} = require("../controllers/user.controller");
const multer = require("multer");

const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

const { authMiddleware } = require("../middlewares/auth.middleware");

router.post(
  "/register",
  /* #swagger.tags = ['Users'] #swagger.summary = 'Регистрация пользователя' */
  register,
);

router.post(
  "/entrance",
  /* #swagger.tags = ['Users'] #swagger.summary = 'Авторизация пользователя' */
  entrance,
);

router.put(
  "/change",
  authMiddleware,
  upload.single("avatar"),
  /* #swagger.tags = ['Users'] */
  /* #swagger.summary = 'Изменение данных текущего пользователя' */
  /* #swagger.consumes = ['multipart/form-data'] */
  /* #swagger.parameters['username'] = {
    in: 'formData',
    type: 'string',
    required: true,
    description: 'Имя пользователя'
  } */
  /* #swagger.parameters['password'] = {
    in: 'formData',
    type: 'string',
    required: true,
    description: 'Пароль пользователя'
  } */
  /* #swagger.parameters['avatar'] = {
    in: 'formData',
    type: 'file',
    required: false,
    description: 'Аватар пользователя'
  } */
  /* #swagger.responses[201] = {
    description: 'Данные пользователя успешно обновлены',
    schema: { type: 'object', properties: { message: { type: 'string', example: 'Данные пользователя успешно обновлены' } } }
  } */
  /* #swagger.responses[400] = {
      description: 'Ошибка валидации',
      schema: { type: 'object', properties: { error: { type: 'string', message: 'Пароль должен быть не менее 6 символов' } } }
    } */
  /* #swagger.responses[401] = {
      description: 'Unauthorized',
      schema: { type: 'object', properties: { error: { type: 'string', message: 'Токен не предоставлен' } } }
    } */
  /* #swagger.responses[500] = {
      description: 'Internal Server Error',
      schema: { type: 'object', properties: { error: { type: 'string', message: 'Internal server error' } } }
  } */
  updateCurrentUserData,
);

router.get(
  "/me",
  authMiddleware,
  /* #swagger.tags = ['Users'] #swagger.summary = 'Получение данных текущего пользователя' */
  getCurrentUserData,
);

module.exports = router;
