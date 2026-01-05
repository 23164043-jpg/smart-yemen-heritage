const express = require('express');
const router = express.Router();
const bannerCtrl = require('../controllers/bannerController');
const { protect } = require('../middleware/authMiddleware');

router.post('/', protect, bannerCtrl.create);
router.get('/', bannerCtrl.getAll);
router.delete('/:id', protect, bannerCtrl.remove);

module.exports = router;
