const express = require('express');
const router = express.Router();
const serviceCtrl = require('../controllers/serviceController');
const { protect } = require('../middleware/authMiddleware');

// ✅ لازم يكون أول شيء
router.get('/by-content/:contentId', serviceCtrl.getByContent);

router.post('/', protect, serviceCtrl.create);
router.get('/', serviceCtrl.getAll);
router.get('/:id', serviceCtrl.getOne);
router.put('/:id', protect, serviceCtrl.update);
router.delete('/:id', protect, serviceCtrl.remove);

module.exports = router;
