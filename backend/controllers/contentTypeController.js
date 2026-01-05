const ContentType = require('../models/ContentType');
exports.create = async (req, res) => { try { const t = await ContentType.create(req.body); res.status(201).json(t); } catch (err) { res.status(400).json({ message: err.message }); } };
exports.getAll = async (req, res) => { try { const list = await ContentType.find(); res.json(list); } catch (err) { res.status(500).json({ message: err.message }); } };
