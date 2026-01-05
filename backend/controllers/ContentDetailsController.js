const ContentDetails = require('../models/ContentDetails');

// إضافة تفاصيل جديدة
exports.createDetails = async (req, res) => {
  try {
    const details = await ContentDetails.create(req.body);
    res.status(201).json(details);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// جلب كل التفاصيل
exports.getAllDetails = async (req, res) => {
  try {
    const list = await ContentDetails.find().populate('content_id');
    res.json(list);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// جلب تفاصيل بناءً على الـ content_id
exports.getByContentId = async (req, res) => {
  try {
    const details = await ContentDetails.find({ content_id: req.params.id });

    if (!details || details.length === 0) {
      return res.status(404).json({ message: 'No details found' });
    }

    res.json(details);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// حذف التفاصيل
exports.deleteDetails = async (req, res) => {
  try {
    await ContentDetails.findByIdAndDelete(req.params.id);
    res.json({ message: 'Deleted successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
