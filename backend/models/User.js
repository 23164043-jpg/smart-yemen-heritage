const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  user_name: { type: String, required: true },
  user_email: { type: String, required: true, unique: true },
  user_password: { type: String, required: true },
  user_image: { type: String },
  profileImage: { type: String, default: null }, // رابط صورة البروفايل
}, { timestamps: true });

module.exports = mongoose.model('User', UserSchema);
