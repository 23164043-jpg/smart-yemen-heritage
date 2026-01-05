const mongoose = require('mongoose');

const ServiceSchema = new mongoose.Schema({
  content_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Content', required: true },
  service_name: { type: String },
  description: { type: String },
  service_images: [{ type: String }],
  service_latitude: { type: String },
  service_longitude: { type: String }
}, { timestamps: true });
module.exports = mongoose.model('Service', ServiceSchema);
