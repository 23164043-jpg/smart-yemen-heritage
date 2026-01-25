const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { register, login } = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');
const User = require('../models/User');

// ============ إعداد Multer لرفع صور البروفايل ============
const profileStorage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadPath = 'uploads/profiles';
    // إنشاء المجلد إذا لم يكن موجوداً
    if (!fs.existsSync(uploadPath)) {
      fs.mkdirSync(uploadPath, { recursive: true });
    }
    cb(null, uploadPath);
  },
  filename: function (req, file, cb) {
    // اسم فريد للملف: userId-timestamp.extension
    const userId = req.user ? req.user._id : 'unknown';
    const uniqueName = `${userId}-${Date.now()}${path.extname(file.originalname)}`;
    cb(null, uniqueName);
  }
});

// فلتر للسماح بالصور فقط
const imageFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|gif|webp/;
  const mimeType = allowedTypes.test(file.mimetype);
  const extName = allowedTypes.test(path.extname(file.originalname).toLowerCase());

  if (mimeType && extName) {
    cb(null, true);
  } else {
    cb(new Error('يُسمح فقط برفع الصور (jpeg, jpg, png, gif, webp)'), false);
  }
};

const uploadProfile = multer({
  storage: profileStorage,
  fileFilter: imageFilter,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5 ميجابايت كحد أقصى
  }
});

// ============ Routes ============

// Route للتحقق من أن API يعمل
router.get('/', (req, res) => {
  res.json({ message: 'Users API is working' });
});

router.post('/register', register);

router.post('/login', login);

router.get('/me', protect, (req, res) => {
  res.json({
    id: req.user._id,
    user_name: req.user.user_name,
    user_email: req.user.user_email,
    profileImage: req.user.profileImage
  });
});

// ============ رفع صورة البروفايل ============
router.post('/profile/avatar', protect, uploadProfile.single('avatar'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'لم يتم رفع أي صورة' });
    }

    // إنشاء رابط الصورة
    const imageUrl = `${req.protocol}://${req.get('host')}/uploads/profiles/${req.file.filename}`;

    // حذف الصورة القديمة إذا كانت موجودة
    const user = await User.findById(req.user._id);
    if (user.profileImage) {
      const oldImagePath = user.profileImage.replace(`${req.protocol}://${req.get('host')}/`, '');
      if (fs.existsSync(oldImagePath)) {
        fs.unlinkSync(oldImagePath);
        console.log('🗑️ تم حذف الصورة القديمة:', oldImagePath);
      }
    }

    // تحديث رابط الصورة في قاعدة البيانات
    await User.findByIdAndUpdate(req.user._id, { profileImage: imageUrl });

    console.log('✅ تم رفع صورة البروفايل بنجاح:', imageUrl);

    res.json({
      message: 'تم رفع صورة البروفايل بنجاح',
      imageUrl: imageUrl
    });

  } catch (error) {
    console.error('❌ خطأ في رفع صورة البروفايل:', error);
    res.status(500).json({ message: error.message });
  }
});

// ============ حذف صورة البروفايل ============
router.delete('/profile/avatar', protect, async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    
    if (user.profileImage) {
      // حذف الملف من السيرفر
      const imagePath = user.profileImage.replace(`${req.protocol}://${req.get('host')}/`, '');
      if (fs.existsSync(imagePath)) {
        fs.unlinkSync(imagePath);
      }
      
      // إزالة الرابط من قاعدة البيانات
      await User.findByIdAndUpdate(req.user._id, { profileImage: null });
      
      console.log('🗑️ تم حذف صورة البروفايل');
      res.json({ message: 'تم حذف صورة البروفايل بنجاح' });
    } else {
      res.status(404).json({ message: 'لا توجد صورة للحذف' });
    }
  } catch (error) {
    console.error('❌ خطأ في حذف صورة البروفايل:', error);
    res.status(500).json({ message: error.message });
  }
});

// ============ تحديث معلومات المستخدم ============
router.put('/profile', protect, async (req, res) => {
  try {
    const { user_name, user_email } = req.body;
    
    const updatedUser = await User.findByIdAndUpdate(
      req.user._id,
      { user_name, user_email },
      { new: true }
    ).select('-user_password');

    res.json({
      message: 'تم تحديث المعلومات بنجاح',
      user: updatedUser
    });
  } catch (error) {
    console.error('❌ خطأ في تحديث المعلومات:', error);
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
