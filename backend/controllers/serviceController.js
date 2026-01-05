const Service = require('../models/Service');
exports.create = async (req, res) => {try { const s = await Service.create(req.body); res.status(201).json(s); } catch (err) { res.status(400).json({ message: err.message }); }};
exports.getAll = async (req, res) => { try { const list = await Service.find().populate('content_id'); res.json(list); } catch (err) { res.status(500).json({ message: err.message }); } };
exports.getOne = async (req, res) => { try { const item = await Service.findById(req.params.id); if (!item) return res.status(404).json({ message: 'Not found' }); res.json(item); } catch (err) { res.status(500).json({ message: err.message }); } };
exports.update = async (req, res) => { try { const updated = await Service.findByIdAndUpdate(req.params.id, req.body, { new: true }); res.json(updated); } catch (err) { res.status(400).json({ message: err.message }); } };
exports.remove = async (req, res) => { try { await Service.findByIdAndDelete(req.params.id); res.json({ message: 'Deleted' }); } catch (err) { res.status(500).json({ message: err.message }); } };
