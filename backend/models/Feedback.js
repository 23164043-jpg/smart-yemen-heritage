const mongoose = require('mongoose');

const FeedbackSchema = new mongoose.Schema({
  user_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  content_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Content', required: true },
  rating: { type: Number, min: 1, max: 5 },
  comment: { type: String }
}, { timestamps: true });
module.exports = mongoose.model('Feedback', FeedbackSchema);
