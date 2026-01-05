const mongoose = require('mongoose');

const ContentTypeSchema = new mongoose.Schema({
  type_name: { type: String, required: true }
}, { timestamps: true });
module.exports = mongoose.model('ContentType', ContentTypeSchema);
