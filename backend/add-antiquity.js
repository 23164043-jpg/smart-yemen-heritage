// Script لإضافة محتوى آثار تجريبي
const mongoose = require('mongoose');
const Content = require('./models/Content');
const ContentType = require('./models/ContentType');
const ContentDetails = require('./models/ContentDetails');

// الاتصال بقاعدة البيانات
mongoose.connect('mongodb+srv://YEMEN2030:9i8LJKaO2GUXQ3bQ@cluster0.mongodb.net/yemeni_heritage?retryWrites=true&w=majority')
    .then(() => console.log('✅ Connected to MongoDB'))
    .catch(err => console.error('❌ MongoDB connection error:', err));

async function addAntiquityContent() {
    try {
        // 1. البحث عن نوع المحتوى "Antiquities"
        const antiquityType = await ContentType.findOne({ type_name: 'Antiquities' });
        
        if (!antiquityType) {
            console.error('❌ لم يتم العثور على نوع المحتوى "Antiquities"');
            mongoose.connection.close();
            return;
        }

        console.log(`✅ تم العثور على نوع المحتوى: ${antiquityType.type_name} (ID: ${antiquityType._id})`);

        // 2. إضافة محتوى آثار تجريبي
        const newAntiquity = await Content.create({
            title: 'تمثال أثري يمني',
            description: 'تمثال أثري نادر يعود إلى الحضارة اليمنية القديمة، يعكس مهارة النحاتين اليمنيين في ذلك العصر',
            type_id: antiquityType._id,
            address: 'المتحف الوطني، صنعاء',
            imageUrl: 'https://images.unsplash.com/photo-1595433707802-6b2626ef1c91?w=800',
            admin_id: null // يمكنك تعديل هذا لاحقاً
        });

        console.log(`✅ تم إضافة المحتوى: ${newAntiquity.title} (ID: ${newAntiquity._id})`);

        // 3. إضافة تفاصيل المحتوى
        const contentDetail = await ContentDetails.create({
            content_id: newAntiquity._id,
            title: 'معلومات تاريخية',
            description: 'هذا التمثال يمثل أحد أهم القطع الأثرية اليمنية التي تم اكتشافها في القرن العشرين. يعود تاريخه إلى القرن الأول قبل الميلاد ويعكس التقدم الفني والثقافي للحضارة اليمنية القديمة.',
            imageUrl: 'https://images.unsplash.com/photo-1595433707802-6b2626ef1c91?w=800',
            admin_id: null
        });

        console.log(`✅ تم إضافة التفاصيل للمحتوى`);

        mongoose.connection.close();
        console.log('\n✅ تم الانتهاء بنجاح! يمكنك الآن رؤية المحتوى في التطبيق');
        
    } catch (error) {
        console.error('❌ خطأ:', error);
        mongoose.connection.close();
    }
}

addAntiquityContent();
