const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: '30d' });
};

exports.register = async (req, res) => {
  const { user_name, user_email, user_password } = req.body;
  try {
    const exists = await User.findOne({ user_email });
    if (exists) return res.status(400).json({ message: 'Email already used' });
    const salt = await bcrypt.genSalt(10);
    const hashed = await bcrypt.hash(user_password, salt);
    const user = await User.create({ user_name, user_email, user_password: hashed });
    res.status(201).json({
      user: { id: user._id, user_name: user.user_name, user_email: user.user_email },
      token: generateToken(user._id)
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.login = async (req, res) => {
  const { user_email, user_password } = req.body;
  console.log('Login attempt:', { user_email, password_length: user_password?.length });
  try {
    const user = await User.findOne({ user_email });
    if (!user) {
      console.log('User not found:', user_email);
      return res.status(400).json({ message: 'Invalid credentials' });
    }
    const match = await bcrypt.compare(user_password, user.user_password);
    if (!match) {
      console.log('Password mismatch for:', user_email);
      return res.status(400).json({ message: 'Invalid credentials' });
    }
    console.log('Login successful:', user_email);
    res.json({ token: generateToken(user._id), user: { id: user._id, user_name: user.user_name } });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ message: err.message });
  }
};
