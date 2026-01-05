const mongoose = require('mongoose');

const ContentDetailsSchema = new mongoose.Schema({
  content_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Content', required: true },
  title: { type: String },
  description: { type: String },
  language_code: { type: String },
  image_url: { type: String },
  latitude: { type: String },
  longitude: { type: String }
}, { timestamps: true });
module.exports = mongoose.model('ContentDetails', ContentDetailsSchema);
