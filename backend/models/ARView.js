const mongoose = require('mongoose');

const ARViewSchema = new mongoose.Schema({
  content_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Content', required: true },
  model_3d_file: { type: String },
  ARdescription: { type: String },
  date_created: { type: Date, default: Date.now }
});
module.exports = mongoose.model('ARView', ARViewSchema);
