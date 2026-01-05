const express = require('express');
const router = express.Router();
const notifCtrl = require('../controllers/notificationController');
const { protect } = require('../middleware/authMiddleware');

router.post('/', protect, notifCtrl.create);
router.get('/', notifCtrl.getAll);

module.exports = router;
