const Content = require('../models/Content');
const ContentType = require('../models/ContentType'); // ⬅️ إضافة هذا السطر

exports.createContent = async (req, res) => {
    try {
        const content = await Content.create(req.body);
        res.status(201).json(content);
    } catch (err) { res.status(400).json({ message: err.message }); }
};

// 🌟 الدالة المُعدلة: تدعم فلترة المحتوى حسب نوعه
exports.getAll = async (req, res) => {
    try {
        // 1. قراءة الـ Query Parameter (مثال: 'معالم' من ?type=معالم)
        const requestedTypeName = req.query.type; 
        
        let findCondition = {}; 

        if (requestedTypeName) {
            // 2. البحث عن الـ ID لنوع المحتوى المطلوب (بحث مرن يدعم الجزء من الاسم)
            let contentType = await ContentType.findOne({ type_name: requestedTypeName });

            // إذا لم يجد بالاسم الدقيق، ابحث بشكل يحتوي على الاسم
            if (!contentType) {
                contentType = await ContentType.findOne({ 
                    type_name: { $regex: requestedTypeName, $options: 'i' } 
                });
            }

            if (!contentType) {
                // إذا لم يتم العثور على نوع المحتوى المطلوب
                console.log(`❌ Content type "${requestedTypeName}" not found.`);
                return res.status(404).json({ message: `Content type "${requestedTypeName}" not found.` });
            }

            console.log(`✅ Found content type: ${contentType.type_name} (ID: ${contentType._id})`);

            // 3. تحديث شرط البحث لاستخدام الـ ID الذي تم العثور عليه
            findCondition = { type_id: contentType._id };
        }

        // 4. تطبيق شرط البحث
        const list = await Content.find(findCondition)
            .populate('type_id')
            .populate('admin_id');

        console.log(`📦 Found ${list.length} contents`);
        res.json(list);
    } catch (err) { 
        console.error(err);
        res.status(500).json({ message: err.message }); 
    }
};

exports.getOne = async (req, res) => {
    try {
        const c = await Content.findById(req.params.id).populate('type_id').populate('admin_id');
        if (!c) return res.status(404).json({ message: 'Not found' });
        res.json(c);
    } catch (err) { res.status(500).json({ message: err.message }); }
};

exports.update = async (req, res) => {
    try {
        const updated = await Content.findByIdAndUpdate(req.params.id, req.body, { new: true });
        res.json(updated);
    } catch (err) { res.status(400).json({ message: err.message }); }
};

exports.remove = async (req, res) => {
    try {
        await Content.findByIdAndDelete(req.params.id);
        res.json({ message: 'Deleted' });
    } catch (err) { res.status(500).json({ message: err.message }); }
};