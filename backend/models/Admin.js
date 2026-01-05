const mongoose = require('mongoose');

const AdminSchema = new mongoose.Schema({
  admin_name: { type: String, required: true },
  department: { type: String },
  permissionsLevel: { type: String },
}, { timestamps: true });

module.exports = mongoose.model('Admin', AdminSchema);
