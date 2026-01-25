// lib/core/utils/url_helper.dart

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class UrlHelper {
  // Base URL للصور والملفات
  static String get baseUrl {
    if (kIsWeb) {
      return "http://192.168.0.198:5000";
    } else if (Platform.isAndroid) {
      return "http://192.168.0.198:5000";
    } else {
      return "http://192.168.0.198:5000";
    }
  }

  /// تصحيح رابط الصورة ليعمل على جميع الأجهزة
  static String fixImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return '';
    }

    // تصحيح أي IP قديم إلى الـ IP الحالي
    String fixedUrl = url;
    
    // قائمة بالـ IPs القديمة التي يجب استبدالها
    final oldIps = [
      'http://10.0.2.2:5000',
      'http://192.168.8.134:5000',
      'http://192.168.200.230:5000',
      'http://10.228.82.230:5000',
      'http://192.168.34.201:5000',
      'http://localhost:5000',
      'http://10.0.2.2',
      'http://192.168.8.134',
      'http://10.228.82.230',
      'http://192.168.34.201',
    ];
    
    for (var oldIp in oldIps) {
      if (fixedUrl.contains(oldIp)) {
        fixedUrl = fixedUrl.replaceAll(oldIp, baseUrl);
        print('🔧 UrlHelper: تم تصحيح الرابط من $oldIp إلى $baseUrl');
        break;
      }
    }

    // إذا كان الرابط يبدأ بـ /uploads
    if (fixedUrl.startsWith('/uploads')) {
      fixedUrl = '$baseUrl$fixedUrl';
      print('🔧 UrlHelper: إضافة baseUrl للرابط النسبي');
    }

    return fixedUrl;
  }
}
