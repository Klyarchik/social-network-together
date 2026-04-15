const prisma = require("../client");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");
const { minioClient, BUCKET_NAME } = require('../configs/minio');



// Регистрация пользователя
const register = async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ error: "username и password обязательны" });
    }

    const existingUser = await prisma.users.findUnique({ where: { username } });

    if (existingUser) {
      return res.status(400).json({ error: "Пользователь с таким username уже существует" });
    }

    if(password.length < 6 || password.length > 25) {
      return res.status(400).json({ error: "Пароль должен быть не менее 6 символов и не более 25 символов" });
    }

    const hashPassword = await bcrypt.hash(password, 10);

    const user = await prisma.users.create({
      data: {
        username,
        password: hashPassword,
        avatar: `http://localhost:9000/${BUCKET_NAME}/default-avatar.jpg`
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
    const { username } = req.body;
    
    const user = await prisma.users.findUnique({ where: { id: userId } });
    if (!user) {
      return res.status(404).json({ error: "Пользователь не найден" });
    }

    // Обновляем username
    if (username) {
      const existingUser = await prisma.users.findUnique({ where: { username } });
      if (existingUser && existingUser.id !== userId) {
        return res.status(400).json({ error: "Пользователь с таким username уже существует" });
      }
      user.username = username;
    }

    // Загружаем аватар в MinIO (если передан)
    let avatarUrl = user.avatar;
    if (req.file) {
      const fileName = `user-${userId}-${Date.now()}.jpg`;
      await minioClient.putObject(
        BUCKET_NAME,
        fileName,
        req.file.buffer,
        req.file.size,
        { 'Content-Type': req.file.mimetype }
      );
      avatarUrl = `http://localhost:9000/${BUCKET_NAME}/${fileName}`;
    }

    await prisma.users.update({
      where: { id: userId },
      data: {
        username: user.username,
        avatar: avatarUrl
      }
    });

    res.status(200).json({ message: "Данные пользователя обновлены" });
  } catch (error) {
    res.status(500).json({ error: "Internal server error" });
    console.error(error);
  }
}



// Изменение пароля пользователя
const changePassword = async (req, res) => {
  try {
    const userId = req.user.userId;

    const { oldPassword, newPassword } = req.body;
    
    if (!oldPassword || !newPassword) {
      return res.status(400).json({ error: "старый и новый пароли обязательны" });
    }

    const user = await prisma.users.findUnique({ where: { id: userId } });
    if (!user) {
      return res.status(404).json({ error: "Пользователь не найден" });
    }

    const isOldPasswordValid = await bcrypt.compare(oldPassword, user.password);
    if (!isOldPasswordValid) {
      return res.status(400).json({ error: "Неверный старый пароль" });
    }

    if (newPassword.length < 6 || newPassword.length > 25) {
      return res.status(400).json({ error: "Новый пароль должен быть не менее 6 символов и не более 25 символов" });
    }

    const newHashedPassword = await bcrypt.hash(newPassword, 10);

    await prisma.users.update({
      where: { id: userId },
      data: {
        password: newHashedPassword
      }
    });

    res.status(200).json({ message: "Пароль успешно изменен" });
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
      select: { 
        id: true,
        username: true,
        avatar: true
      }
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
  updateCurrentUserData,
  changePassword
};