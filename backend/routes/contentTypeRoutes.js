const express = require('express');
const router = express.Router();
const ctCtrl = require('../controllers/contentTypeController');
const { protect } = require('../middleware/authMiddleware');

router.post('/', protect, ctCtrl.create);
router.get('/', ctCtrl.getAll);

module.exports = router;
