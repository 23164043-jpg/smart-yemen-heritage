// سكربت للتحقق من بيانات الآثار في قاعدة البيانات
const mongoose = require('mongoose');
const Content = require('./models/Content');
const ContentType = require('./models/ContentType');
const ContentDetails = require('./models/ContentDetails');

mongoose.connect('mongodb+srv://shehapsalem9_db_user:gsxC6k6OMdr7X5Za@cluster0.7jpeu2l.mongodb.net/?appName=Cluster0')
    .then(async () => {
        console.log('✅ Connected to MongoDB');
        
        // 1. البحث عن نوع المحتوى Antiquities
        const antiquityType = await ContentType.findOne({ type_name: 'Antiquities' });
        console.log('\n📋 نوع المحتوى Antiquities:', antiquityType);
        
        if (!antiquityType) {
            console.log('❌ لا يوجد نوع محتوى باسم Antiquities');
            
            // عرض جميع أنواع المحتوى المتاحة
            const allTypes = await ContentType.find({});
            console.log('\n📋 جميع أنواع المحتوى المتاحة:');
            allTypes.forEach(t => console.log(`  - ${t.type_name} (ID: ${t._id})`));
            
            mongoose.connection.close();
            return;
        }
        
        // 2. البحث عن محتويات الآثار
        const contents = await Content.find({ type_id: antiquityType._id });
        console.log(`\n📦 عدد محتويات الآثار: ${contents.length}`);
        
        if (contents.length === 0) {
            console.log('⚠️ لا توجد بيانات آثار في قاعدة البيانات');
        } else {
            contents.forEach((c, i) => {
                console.log(`\n${i + 1}. ${c.title}`);
                console.log(`   📍 العنوان: ${c.address || 'غير محدد'}`);
                console.log(`   🖼️ الصورة: ${c.imageUrl || 'غير محدد'}`);
                console.log(`   🆔 ID: ${c._id}`);
            });
        }
        
        mongoose.connection.close();
    })
    .catch(err => {
        console.error('❌ خطأ:', err);
        mongoose.connection.close();
    });
