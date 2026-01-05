const express = require('express');
const router = express.Router();
const feedbackCtrl = require('../controllers/feedbackController');
const { protect } = require('../middleware/authMiddleware');

router.post('/', protect, feedbackCtrl.create);
router.get('/', feedbackCtrl.getAll);

module.exports = router;
