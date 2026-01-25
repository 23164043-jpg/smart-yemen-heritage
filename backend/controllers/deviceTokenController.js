const DeviceToken = require('../models/DeviceToken');

exports.saveToken = async (req, res) => {
  try {
    const userId = req.user._id;
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({ message: 'FCM token required' });
    }

    // منع التكرار
    await DeviceToken.findOneAndUpdate(
      { user_id: userId },
      { token },
      { upsert: true, new: true }
    );

    res.json({ message: 'Token saved successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
