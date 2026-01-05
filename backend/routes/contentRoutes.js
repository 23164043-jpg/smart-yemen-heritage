const express = require('express');
const router = express.Router();
const contentCtrl = require('../controllers/contentController');
const { protect } = require('../middleware/authMiddleware');

router.post('/', protect, contentCtrl.createContent);
router.get('/', contentCtrl.getAll);
router.get('/:id', contentCtrl.getOne);
router.put('/:id', protect, contentCtrl.update);
router.delete('/:id', protect, contentCtrl.remove);

module.exports = router;
