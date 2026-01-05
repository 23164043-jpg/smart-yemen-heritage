const express = require('express');
const multer = require('multer');
const router = express.Router();
const path = require('path');

// إعداد التخزين
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/'); // المجلد الذي تُرفع إليه الصور
  },
  filename: function (req, file, cb) {
    cb(
      null,
      Date.now() + '-' + Math.round(Math.random() * 1e9) + path.extname(file.originalname)
    );
  }
});

// السماح برفع الصور فقط
function fileFilter(req, file, cb) {
  const allowedTypes = /jpeg|jpg|png|gif/;
  const mimeType = allowedTypes.test(file.mimetype);
  const ext = allowedTypes.test(path.extname(file.originalname).toLowerCase());

  if (mimeType && ext) cb(null, true);
  else cb(new Error('Only images are allowed'));
}

const upload = multer({ storage, fileFilter });

// ✅ Endpoint: رفع صورة واحدة
router.post('/', upload.single('image'), (req, res) => {
  try {
    const fileUrl = `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`;
    res.json({
      message: "Upload successful",
      url: fileUrl
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
