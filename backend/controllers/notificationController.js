const Notification = require('../models/Notification');
exports.create = async (req, res) => { try { const n = await Notification.create(req.body); res.status(201).json(n); } catch (err) { res.status(400).json({ message: err.message }); } };
exports.getAll = async (req, res) => { try { const list = await Notification.find().populate('admin_id'); res.json(list); } catch (err) { res.status(500).json({ message: err.message }); } };
