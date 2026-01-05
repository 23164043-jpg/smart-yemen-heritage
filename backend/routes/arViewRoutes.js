const express = require('express');
const router = express.Router();
const arCtrl = require('../controllers/arViewController');
const { protect } = require('../middleware/authMiddleware');

router.post('/', protect, arCtrl.create);
router.get('/', arCtrl.getAll);
router.delete('/:id', protect, arCtrl.remove);

module.exports = router;
