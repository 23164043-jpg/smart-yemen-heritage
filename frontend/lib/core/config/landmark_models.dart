/// خريطة ربط المعالم بنماذج 3D
///
/// هذا الملف يحتوي على خريطة تربط كل معلم تاريخي بنموذجه ثلاثي الأبعاد
/// يمكنك إضافة نماذج جديدة بسهولة عن طريق إضافة سطر جديد في الخريطة
///
/// كيفية إضافة نموذج جديد:
/// 1. احصل على نموذج GLB من موقع مثل Sketchfab أو Tripo AI
/// 2. ضع الملف في مجلد assets/models/
/// 3. أضف السطر التالي في الخريطة:
///    'اسم_المعلم': 'assets/models/اسم_الملف.glb',
///
/// ملاحظة: تأكد من أن اسم المعلم مطابق تماماً لاسم المعلم في قاعدة البيانات

class LandmarkModels {
  /// خريطة النماذج ثلاثية الأبعاد
  /// المفتاح: اسم المعلم (بالعربية)
  /// القيمة: مسار ملف النموذج GLB
  static const Map<String, String> models = {
    // ===== المعالم اليمنية =====

    // دار الحجر - صنعاء
    'دار الحجر':
        'assets/models/tripo_pbr_model_a82b51d4-80ce-41d1-ac78-f3c40214d270.glb',

    // باب اليمن - صنعاء (نموذج Sketchfab)
    'باب اليمن': 'sketchfab:5833e4e0e058409ab735ccc4ffde5e7a',

    // عرش بلقيس / معبد بران - مأرب (نموذج Sketchfab)
    'عرش بلقيس': 'sketchfab:9c310eb9b2d244819fe2e8bd3a3dd135',
    'معبد بران': 'sketchfab:9c310eb9b2d244819fe2e8bd3a3dd135',

    // يمكنك إضافة المزيد من المعالم هنا:
    // 'سد مأرب': 'assets/models/marib_dam.glb',
    // 'قصر غمدان': 'assets/models/ghumdan_palace.glb',
    // 'صنعاء القديمة': 'assets/models/old_sanaa.glb',
    // 'شبام حضرموت': 'assets/models/shibam.glb',
    // 'جامع الصالح': 'assets/models/al_saleh_mosque.glb',
  };

  /// النموذج الافتراضي عند عدم وجود نموذج مخصص للمعلم
  static const String defaultModel =
      'https://modelviewer.dev/shared-assets/models/Astronaut.glb';

  /// الحصول على رابط النموذج للمعلم
  /// [landmarkName] اسم المعلم
  /// يعيد مسار النموذج إذا وُجد، أو النموذج الافتراضي إذا لم يوجد
  static String getModelUrl(String landmarkName) {
    // البحث عن النموذج بالاسم الكامل
    if (models.containsKey(landmarkName)) {
      return models[landmarkName]!;
    }

    // البحث عن تطابق جزئي
    for (var entry in models.entries) {
      if (landmarkName.contains(entry.key) ||
          entry.key.contains(landmarkName)) {
        return entry.value;
      }
    }

    // إرجاع النموذج الافتراضي
    return defaultModel;
  }

  /// التحقق مما إذا كان المعلم له نموذج مخصص
  static bool hasCustomModel(String landmarkName) {
    if (models.containsKey(landmarkName)) {
      return true;
    }

    for (var entry in models.entries) {
      if (landmarkName.contains(entry.key) ||
          entry.key.contains(landmarkName)) {
        return true;
      }
    }

    return false;
  }

  /// الحصول على قائمة بأسماء المعالم التي لها نماذج
  static List<String> getAvailableLandmarks() {
    return models.keys.toList();
  }
}
