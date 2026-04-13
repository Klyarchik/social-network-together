const prisma = require("../client");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");

// Регистрация пользователя
const register = async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ error: "username и password обязательны" });
    }

    if(password.length < 6 || password.length > 25) {
      return res.status(400).json({ error: "Пароль должен быть не менее 6 символов и не более 25 символов" });
    }

    const existingUser = await prisma.users.findUnique({ where: { username } });

    if (existingUser) {
      return res.status(400).json({ error: "Пользователь с таким username уже существует" });
    }

    const hashPassword = await bcrypt.hash(password, 10);

    const user = await prisma.users.create({
      data: {
        username,
        password: hashPassword
      }
    });

    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET || "secret");
    
    res.status(201).json({ token: token });
  } catch (error) {
    res.status(500).json({ error: "Internal server error" });
    console.error(error);
  }
}


// Авторизация пользователя
const entrance = async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ error: "username и password обязательны" });
    }

    const user = await prisma.users.findUnique({ where: { username } });

    if (!user) {
      return res.status(400).json({ error: "Неверный username или password" });
    } 

    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      return res.status(400).json({ error: "Неверный username или password" });
    }

    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET || "secret");

    res.status(200).json({ token: token });
  } catch (error) {
    res.status(500).json({ error: "Internal server error" });
    console.error(error);
  }
}



// Изменение данных текущего пользователя
const updateCurrentUserData = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { username, password } = req.body;

    const user = await prisma.users.findUnique({ where: { id: userId } });

    if (!user) {
      return res.status(404).json({ error: "Пользователь не найден" });
    }

    const existingUser = await prisma.users.findUnique({ where: { username } });
    if (existingUser && existingUser.id !== userId) {
      return res.status(400).json({ error: "Пользователь с таким username уже существует" });
    }
    user.username = username;
    

    if (password) {
      if (password.length < 6 || password.length > 25) {
        return res.status(400).json({ error: "Пароль должен быть не менее 6 символов и не более 25 символов" });
      }
      user.password = await bcrypt.hash(password, 10);
    }

    await prisma.users.update({
      where: { id: userId },
      data: user
    });

    res.status(200).json({ message: "Данные пользователя обновлены" });
  } catch (error) {
    res.status(500).json({ error: "Internal server error" });
    console.error(error);
  }
}



// Получение всех данных текущего пользователя
const getCurrentUserData = async (req, res) => {
  try {
    const userId = req.user.userId;
    
    const user = await prisma.users.findUnique({
      where: { id: userId },
      select: { id: true, username: true }
    });

    if (!user) {
      return res.status(404).json({ error: "Пользователь не найден" });
    }

    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ error: "Internal server error" });
    console.error(error);
  }
}

module.exports = {
  register,
  entrance,
  getCurrentUserData,
  updateCurrentUserData
};