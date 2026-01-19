// سكريبت للتحقق من روابط الصور في قاعدة البيانات
const mongoose = require('mongoose');

// الاتصال بقاعدة البيانات
const mongoUri = 'mongodb+srv://osamamohammed:0SLlwOe2sMCGZWQK@yemenheritage.gwvxl.mongodb.net/yemeni_heritage?retryWrites=true&w=majority';

mongoose.connect(mongoUri, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('✅ تم الاتصال بقاعدة البيانات'))
.catch(err => console.error('❌ خطأ في الاتصال:', err));

// نموذج المحتوى
const contentSchema = new mongoose.Schema({
  title: String,
  description: String,
  type: String,
  image_url: String,
  address: String,
  lat: String,
  lng: String,
}, { collection: 'contents' });

const Content = mongoose.model('Content', contentSchema);

// فحص روابط الصور
async function checkImages() {
  try {
    console.log('\n📊 فحص روابط الصور في قاعدة البيانات...\n');
    
    // جلب جميع المعالم
    const landmarks = await Content.find({ type: 'Landmarks' }).limit(5);
    console.log(`🔍 عدد المعالم المسترجعة: ${landmarks.length}`);
    
    landmarks.forEach((item, index) => {
      console.log(`\n--- معلم ${index + 1} ---`);
      console.log(`📝 العنوان: ${item.title}`);
      console.log(`🖼️  رابط الصورة: ${item.image_url || 'لا يوجد'}`);
      console.log(`📍 الإحداثيات: ${item.lat || 'لا يوجد'}, ${item.lng || 'لا يوجد'}`);
    });

    // جلب الممالك
    console.log('\n\n================================\n');
    const kingdoms = await Content.find({ type: 'Kingdoms' }).limit(5);
    console.log(`🔍 عدد الممالك المسترجعة: ${kingdoms.length}`);
    
    kingdoms.forEach((item, index) => {
      console.log(`\n--- مملكة ${index + 1} ---`);
      console.log(`📝 العنوان: ${item.title}`);
      console.log(`🖼️  رابط الصورة: ${item.image_url || 'لا يوجد'}`);
      console.log(`📍 الإحداثيات: ${item.lat || 'لا يوجد'}, ${item.lng || 'لا يوجد'}`);
    });

    // جلب المواقع المندثرة
    console.log('\n\n================================\n');
    const extinctSites = await Content.find({ type: 'المواقع المندثرة' }).limit(5);
    console.log(`🔍 عدد المواقع المندثرة المسترجعة: ${extinctSites.length}`);
    
    extinctSites.forEach((item, index) => {
      console.log(`\n--- موقع ${index + 1} ---`);
      console.log(`📝 العنوان: ${item.title}`);
      console.log(`🖼️  رابط الصورة: ${item.image_url || 'لا يوجد'}`);
      console.log(`📍 الإحداثيات: ${item.lat || 'لا يوجد'}, ${item.lng || 'لا يوجد'}`);
    });

    // إحصائيات
    console.log('\n\n📈 إحصائيات روابط الصور:\n');
    const allContent = await Content.find({});
    const withImage = allContent.filter(item => item.image_url && item.image_url.trim() !== '');
    const withoutImage = allContent.filter(item => !item.image_url || item.image_url.trim() === '');
    
    console.log(`✅ محتوى مع صور: ${withImage.length}`);
    console.log(`❌ محتوى بدون صور: ${withoutImage.length}`);
    console.log(`📊 إجمالي المحتوى: ${allContent.length}`);

    // عرض بعض الروابط
    if (withImage.length > 0) {
      console.log('\n🔗 أمثلة على روابط الصور:');
      withImage.slice(0, 3).forEach((item, index) => {
        console.log(`${index + 1}. ${item.title}: ${item.image_url}`);
      });
    }

    mongoose.connection.close();
    console.log('\n✅ تم إغلاق الاتصال بقاعدة البيانات');
  } catch (error) {
    console.error('❌ خطأ:', error);
    mongoose.connection.close();
  }
}

checkImages();
