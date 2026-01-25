const Notification = require('../models/Notification');
const DeviceToken = require('../models/DeviceToken');
const admin = require('../config/firebase');

// إنشاء إشعار + إرساله عبر Firebase
const create = async (req, res) => {
  try {
    const n = await Notification.create({
      title: req.body.title,
      description: req.body.description,
      image_url: req.body.image_url || null,
      admin_id: req.user?._id || null,
    });

    const tokens = await DeviceToken.find().select('token');

    if (tokens.length > 0) {
      const message = {
        notification: {
          title: n.title,
          body: n.description,
        },
        android: {
          priority: "high",
          notification: {
            channelId: "high_importance_channel",
            sound: "default",
          },
        },
        data: {
          admin_id: req.user?._id?.toString() || "",
          notification_id: n._id.toString(),
        },
        tokens: tokens.map(t => t.token),
      };

      await admin.messaging().sendEachForMulticast(message);
    }

    res.status(201).json(n);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// جلب جميع الإشعارات
const getAll = async (req, res) => {
  try {
    const list = await Notification.find().populate('admin_id');
    res.json(list);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

module.exports = {
  create,
  getAll,
};
