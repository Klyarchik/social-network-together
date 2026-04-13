const express = require("express");
const router = express.Router();
const { register, entrance, getCurrentUserData, updateCurrentUserData } = require("../controllers/user.controller");

const {authMiddleware} = require("../middlewares/auth.middleware");

router.post("/register",
  /* #swagger.tags = ['Users'] #swagger.summary = 'Регистрация пользователя' */ 
  register
)

router.post("/entrance",
  /* #swagger.tags = ['Users'] #swagger.summary = 'Авторизация пользователя' */ 
  entrance
)

router.put("/change", authMiddleware, 
  /* #swagger.tags = ['Users'] #swagger.summary = 'Изменение данных текущего пользователя' */
  updateCurrentUserData
);

router.get("/me", authMiddleware,
  /* #swagger.tags = ['Users'] #swagger.summary = 'Получение данных текущего пользователя' */ 
  getCurrentUserData
)

module.exports = router;