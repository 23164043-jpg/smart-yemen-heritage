const express = require('express');
const router = express.Router();
const Admin = require('../models/Admin');
const { protect } = require('../middleware/authMiddleware');

router.post('/', protect, async (req, res) => { try { const a = await Admin.create(req.body); res.status(201).json(a); } catch (err) { res.status(400).json({ message: err.message }); } });
router.get('/', protect, async (req, res) => { try { const list = await Admin.find(); res.json(list); } catch (err) { res.status(500).json({ message: err.message }); } });

module.exports = router;
