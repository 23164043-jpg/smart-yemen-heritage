const ARView = require('../models/ARView');
exports.create = async (req, res) => { try { const item = await ARView.create(req.body); res.status(201).json(item); } catch (err) { res.status(400).json({ message: err.message }); } };
exports.getAll = async (req, res) => { try { const list = await ARView.find().populate('content_id'); res.json(list); } catch (err) { res.status(500).json({ message: err.message }); } };
exports.remove = async (req, res) => { try { await ARView.findByIdAndDelete(req.params.id); res.json({ message: 'Deleted' }); } catch (err) { res.status(500).json({ message: err.message }); } };
