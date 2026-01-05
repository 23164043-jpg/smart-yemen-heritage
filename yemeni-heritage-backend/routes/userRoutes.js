const express = require('express');
const router = express.Router();
const { registerUser, loginUser, getMe } = require('../controllers/userController');
const { protect } = require('../middleware/authMiddleware.js');

// تسجيل مستخدم جديد
router.post('/auth/register', registerUser);

// تسجيل الدخول
router.post('/auth/login', loginUser);

// جلب بيانات المستخدم الحالية (محمي بالـ JWT)
router.get('/users/me', protect, getMe);

module.exports = router;
