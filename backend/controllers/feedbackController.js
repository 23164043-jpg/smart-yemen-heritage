const Feedback = require('../models/Feedback');
exports.create = async (req, res) => { try { const f = await Feedback.create(req.body); res.status(201).json(f); } catch (err) { res.status(400).json({ message: err.message }); } };
exports.getAll = async (req, res) => { try { const list = await Feedback.find().populate('user_id').populate('content_id'); res.json(list); } catch (err) { res.status(500).json({ message: err.message }); } };
