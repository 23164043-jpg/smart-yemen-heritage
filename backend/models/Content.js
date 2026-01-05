const mongoose = require('mongoose');

const ContentSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String },

  address: { type: String },
  lat: { type: String },
  lng: { type: String },

  type_id: { type: mongoose.Schema.Types.ObjectId, ref: 'ContentType' },
  admin_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Admin' },
}, { timestamps: true });

module.exports = mongoose.model('Content', ContentSchema);
