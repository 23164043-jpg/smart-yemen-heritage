const mongoose = require('mongoose');

const DeviceTokenSchema = new mongoose.Schema({
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  token: {
    type: String,
    required: true,
  },
}, { timestamps: true });

module.exports = mongoose.model('DeviceToken', DeviceTokenSchema);
