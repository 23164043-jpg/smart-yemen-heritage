const mongoose = require('mongoose');

const BannerSchema = new mongoose.Schema({
  admin_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Admin' },
  content_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Content' },
  banner_name: { type: String },
  banner_image: { type: String },
  start_date: { type: Date },
  price: { type: Number }
}, { timestamps: true });
module.exports = mongoose.model('Banner', BannerSchema);
