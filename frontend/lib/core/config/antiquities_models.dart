/// خريطة ربط الآثار اليمنية بنماذج 3D
///
/// هذا الملف يحتوي على خريطة تربط كل أثر تاريخي بنموذجه ثلاثي الأبعاد
/// يمكنك إضافة نماذج جديدة بسهولة عن طريق إضافة سطر جديد في الخريطة
///
/// كيفية إضافة نموذج جديد:
/// 1. احصل على نموذج GLB من موقع مثل Sketchfab أو Tripo AI
/// 2. ضع الملف في مجلد assets/models/ أو استخدم معرف Sketchfab
/// 3. أضف السطر التالي في الخريطة:
///    'اسم_الأثر': 'assets/models/اسم_الملف.glb',
///    أو للنماذج من Sketchfab:
///    'اسم_الأثر': 'sketchfab:معرف_النموذج',
///
/// ملاحظة: تأكد من أن اسم الأثر مطابق تماماً لاسم الأثر في قاعدة البيانات

class AntiquitiesModels {
  /// خريطة النماذج ثلاثية الأبعاد
  /// المفتاح: اسم الأثر (بالعربية)
  /// القيمة: مسار ملف النموذج GLB أو معرف Sketchfab
  static const Map<String, String> models = {
    // ===== الآثار والتماثيل اليمنية =====

    // تمثال معاد كرب - الحضارة اليمنية القديمة (نموذج Sketchfab)
    'تمثال معاد كرب': 'sketchfab:8dcb54f81b134d8f80b43691f0c36505',
    'معاد كرب': 'sketchfab:8dcb54f81b134d8f80b43691f0c36505',
    
    // تمثال أثري يمني عام
    'تمثال أثري يمني': 'sketchfab:8dcb54f81b134d8f80b43691f0c36505',
    
    // يمكنك إضافة المزيد من الآثار هنا عند توفر نماذج ثلاثية الأبعاد:
    // 'نقش المسند السبئي': 'sketchfab:معرف_النموذج',
    // 'تمثال الأسد البرونزي': 'sketchfab:معرف_النموذج',
    // 'أواني برونزية': 'assets/models/bronze_vessels.glb',
  };

  /// النموذج الافتراضي عند عدم وجود نموذج مخصص للأثر
  static const String defaultModel =
      'https://modelviewer.dev/shared-assets/models/Astronaut.glb';

  /// الحصول على رابط النموذج للأثر
  /// [antiquityName] اسم الأثر
  /// يعيد مسار النموذج إذا وُجد، أو النموذج الافتراضي إذا لم يوجد
  static String getModelUrl(String antiquityName) {
    // البحث عن النموذج بالاسم الكامل
    if (models.containsKey(antiquityName)) {
      return models[antiquityName]!;
    }

    // البحث بالاسم الجزئي (يحتوي على)
    for (var entry in models.entries) {
      if (antiquityName.contains(entry.key) || entry.key.contains(antiquityName)) {
        return entry.value;
      }
    }

    // إذا لم يوجد، استخدم النموذج الافتراضي
    return defaultModel;
  }

  /// التحقق إذا كان الأثر يملك نموذج 3D
  static bool hasModel(String antiquityName) {
    if (models.containsKey(antiquityName)) {
      return true;
    }

    // البحث بالاسم الجزئي
    for (var entry in models.entries) {
      if (antiquityName.contains(entry.key) || entry.key.contains(antiquityName)) {
        return true;
      }
    }

    return false;
  }

  /// الحصول على قائمة بجميع الآثار التي تملك نماذج 3D
  static List<String> getAvailableAntiquities() {
    return models.keys.toList();
  }
}
