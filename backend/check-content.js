// Script للتحقق من المحتوى في قاعدة البيانات
const mongoose = require('mongoose');
const Content = require('./models/Content');
const ContentType = require('./models/ContentType');

// الاتصال بقاعدة البيانات
mongoose.connect('mongodb+srv://YEMEN2030:9i8LJKaO2GUXQ3bQ@cluster0.mongodb.net/yemeni_heritage?retryWrites=true&w=majority')
    .then(() => console.log('✅ Connected to MongoDB'))
    .catch(err => console.error('❌ MongoDB connection error:', err));

async function checkContent() {
    try {
        // 1. التحقق من أنواع المحتوى
        console.log('\n📚 أنواع المحتوى المتوفرة:');
        const types = await ContentType.find();
        types.forEach(type => {
            console.log(`  - ${type.type_name} (ID: ${type._id})`);
        });

        // 2. التحقق من المحتوى لكل نوع
        console.log('\n📝 المحتوى المتوفر:');
        for (const type of types) {
            const contents = await Content.find({ type_id: type._id });
            console.log(`\n  ${type.type_name}: ${contents.length} محتوى`);
            contents.forEach(content => {
                console.log(`    - ${content.title} (${content.address || 'بدون عنوان'})`);
            });
        }

        // 3. التحقق من المحتوى بدون type_id
        const untyped = await Content.find({ type_id: null });
        if (untyped.length > 0) {
            console.log(`\n⚠️  محتوى بدون نوع: ${untyped.length}`);
        }

        mongoose.connection.close();
        console.log('\n✅ تم الانتهاء من الفحص');
    } catch (error) {
        console.error('❌ خطأ:', error);
        mongoose.connection.close();
    }
}

checkContent();
