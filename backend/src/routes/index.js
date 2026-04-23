const express = require('express');
const router = express.Router();

const userRoutes = require('./user.routes');
const chatRoutes = require('./chat.routes')
const tokenDeviceRoutes = require('./token.device.routes');

router.use('/user', userRoutes);
router.use('/chat', chatRoutes);
router.use('/token', tokenDeviceRoutes);

module.exports = router;