const mongoose = require('mongoose');

const NotificationSchema = new mongoose.Schema({
  admin_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Admin' },
  title: { type: String },
  description: { type: String },
  image_url: { type: String }
}, { timestamps: true });
module.exports = mongoose.model('Notification', NotificationSchema);
