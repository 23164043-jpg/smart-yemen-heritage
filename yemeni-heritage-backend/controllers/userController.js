const User = require('../models/User');

// تسجيل مستخدم جديد
exports.registerUser = async (req, res) => {
  try {
    const { name, email, password, role } = req.body;

    // التحقق من وجود المستخدم
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'البريد الإلكتروني مستخدم مسبقاً' });
    }

    const user = new User({ name, email, password, role });
    await user.save();

    const token = user.generateJWT();
    res.status(201).json({ user: { id: user._id, name: user.name, email: user.email, role: user.role }, token });
  } catch (error) {
    res.status(500).json({ message: 'حدث خطأ أثناء تسجيل المستخدم', error: error.message });
  }
};

// تسجيل الدخول
exports.loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ message: 'المستخدم غير موجود' });

    const isMatch = await user.comparePassword(password);
    if (!isMatch) return res.status(400).json({ message: 'كلمة المرور غير صحيحة' });

    const token = user.generateJWT();
    res.json({ user: { id: user._id, name: user.name, email: user.email, role: user.role }, token });
  } catch (error) {
    res.status(500).json({ message: 'حدث خطأ أثناء تسجيل الدخول', error: error.message });
  }
};

// جلب بيانات المستخدم الحالية
exports.getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    if (!user) return res.status(404).json({ message: 'المستخدم غير موجود' });
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: 'حدث خطأ أثناء جلب بيانات المستخدم', error: error.message });
  }
};
