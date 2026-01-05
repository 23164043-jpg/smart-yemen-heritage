const express = require('express');
const router = express.Router();
const { register, login } = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');

// Route للتحقق من أن API يعمل
router.get('/', (req, res) => {
  res.json({ message: 'Users API is working' });
});

router.post('/register', register);

router.post('/login', login);

router.get('/me', protect, (req, res) => res.json(req.user));

module.exports = router;
