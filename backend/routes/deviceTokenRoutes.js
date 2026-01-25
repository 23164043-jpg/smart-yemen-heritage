const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const ctrl = require('../controllers/deviceTokenController');

router.post('/', protect, ctrl.saveToken);

module.exports = router;
