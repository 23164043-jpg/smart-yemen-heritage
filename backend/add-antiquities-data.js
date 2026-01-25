// سكربت لإضافة بيانات آثار يمنية إلى قاعدة البيانات
const mongoose = require('mongoose');
const Content = require('./models/Content');
const ContentType = require('./models/ContentType');
const ContentDetails = require('./models/ContentDetails');

mongoose.connect('mongodb+srv://shehapsalem9_db_user:gsxC6k6OMdr7X5Za@cluster0.7jpeu2l.mongodb.net/?appName=Cluster0')
    .then(async () => {
        console.log('✅ Connected to MongoDB');

        // 1. البحث عن نوع المحتوى الآثار
        const antiquityType = await ContentType.findOne({ 
            type_name: { $regex: 'Antiquities', $options: 'i' } 
        });

        if (!antiquityType) {
            console.log('❌ لم يتم العثور على نوع المحتوى "Antiquities"');
            mongoose.connection.close();
            return;
        }

        console.log(`✅ تم العثور على نوع المحتوى: ${antiquityType.type_name} (ID: ${antiquityType._id})`);

        // 2. التحقق من وجود بيانات مسبقاً
        const existingContents = await Content.find({ type_id: antiquityType._id });
        console.log(`📦 عدد الآثار الموجودة حالياً: ${existingContents.length}`);

        // 3. إضافة بيانات الآثار اليمنية
        const antiquitiesData = [
            {
                title: 'تمثال سيدة عرش بلقيس',
                description: 'تمثال برونزي نادر يعود لحضارة سبأ، يُجسد امرأة ملكية جالسة على عرش مزخرف. يُعتبر من أهم القطع الأثرية اليمنية المكتشفة.',
                address: 'المتحف الوطني، صنعاء',
                type_id: antiquityType._id,
                imageUrl: 'https://images.unsplash.com/photo-1608376630927-f7eb0e10f6f0?w=800'
            },
            {
                title: 'لوح حجري بالخط المسند',
                description: 'لوح حجري منقوش بالخط المسند القديم، يحتوي على نصوص تاريخية تعود للقرن الخامس قبل الميلاد. يُوثق أحداثاً مهمة من تاريخ مملكة سبأ.',
                address: 'معبد أوام، مأرب',
                type_id: antiquityType._id,
                imageUrl: 'https://images.unsplash.com/photo-1590069261209-f8e9b8642343?w=800'
            },
            {
                title: 'رأس ثور برونزي سبئي',
                description: 'قطعة فنية برونزية تُصور رأس ثور بتفاصيل دقيقة، كانت تُستخدم في الطقوس الدينية بمعابد سبأ. تعكس المهارة الفنية العالية للحرفيين اليمنيين القدماء.',
                address: 'معبد المقه، مأرب',
                type_id: antiquityType._id,
                imageUrl: 'https://images.unsplash.com/photo-1594736797933-d0501ba2fe65?w=800'
            },
            {
                title: 'مبخرة حجرية منقوشة',
                description: 'مبخرة حجرية مربعة الشكل مزينة بنقوش هندسية وكتابات بالمسند. استُخدمت في حرق البخور واللبان في المعابد اليمنية القديمة.',
                address: 'تمنع، شبوة',
                type_id: antiquityType._id,
                imageUrl: 'https://images.unsplash.com/photo-1582719188393-bb71ca45dbb9?w=800'
            },
            {
                title: 'تمثال أسد ذو لبدة',
                description: 'تمثال حجري ضخم لأسد واقف، يُمثل رمز القوة والحماية عند اليمنيين القدماء. كان يُوضع عند مداخل المعابد والقصور الملكية.',
                address: 'براقش، الجوف',
                type_id: antiquityType._id,
                imageUrl: 'https://images.unsplash.com/photo-1577083165633-14ebcdb0f658?w=800'
            },
            {
                title: 'قلادة ذهبية حميرية',
                description: 'قلادة ذهبية مُطعمة بالأحجار الكريمة، تعود لفترة مملكة حمير. تتميز بتصميم فريد يجمع بين العناصر اليمنية والتأثيرات الرومانية.',
                address: 'ظفار، إب',
                type_id: antiquityType._id,
                imageUrl: 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=800'
            }
        ];

        // 4. إضافة البيانات
        for (const antiquity of antiquitiesData) {
            // التحقق من عدم وجود العنصر مسبقاً
            const exists = await Content.findOne({ title: antiquity.title });
            if (exists) {
                console.log(`⚠️ العنصر "${antiquity.title}" موجود مسبقاً`);
                continue;
            }

            const newContent = await Content.create(antiquity);
            console.log(`✅ تم إضافة: ${newContent.title}`);

            // إضافة تفاصيل المحتوى
            await ContentDetails.create({
                content_id: newContent._id,
                title: 'معلومات تاريخية',
                description: antiquity.description + '\n\nهذه القطعة الأثرية تُعد شاهداً على عظمة الحضارة اليمنية القديمة وإبداع الفنانين والحرفيين اليمنيين.',
                imageUrl: antiquity.imageUrl
            });
            console.log(`   📝 تم إضافة التفاصيل`);
        }

        console.log('\n✅ تم الانتهاء بنجاح!');
        mongoose.connection.close();
    })
    .catch(err => {
        console.error('❌ خطأ:', err);
        mongoose.connection.close();
    });
