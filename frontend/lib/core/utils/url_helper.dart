// lib/core/utils/url_helper.dart

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class UrlHelper {
  // Base URL للصور والملفات
  static String get baseUrl {
    if (kIsWeb) {
      return "http://192.168.8.134:5000";
    } else if (Platform.isAndroid) {
      return "http://192.168.8.134:5000";
    } else {
      return "http://192.168.8.134:5000";
    }
  }

  /// تصحيح رابط الصورة ليعمل على جميع الأجهزة
  static String fixImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return '';
    }

    // إذا كان الرابط يحتوي على 10.0.2.2 (عنوان المحاكي)
    if (url.contains('10.0.2.2')) {
      return url.replaceAll('http://10.0.2.2:5000', baseUrl);
    }

    // إذا كان الرابط يبدأ بـ /uploads
    if (fixedUrl.startsWith('/uploads')) {
      fixedUrl = '$baseUrl$fixedUrl';
      print('🔧 UrlHelper: إضافة baseUrl للرابط النسبي');
    }

    return fixedUrl;
  }
}
