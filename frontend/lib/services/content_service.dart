// lib/services/content_service.dart

import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/content_model.dart';

class ContentService {
  // دعم جميع المنصات
  static String get baseUrl {
    if (kIsWeb) {
      return "http://192.168.34.230:5000/api";
    } else if (Platform.isAndroid) {
      return "http://192.168.34.230:5000/api";
    } else {
      return "http://192.168.34.230:5000/api";
    }
  }

  // 🌟 التعديل: الدالة تقبل الآن معامل اختياري لنوع المحتوى
  static Future<List<Content>> fetchContents({String? type}) async {
    try {
      // 1. بناء الرابط الأساسي
      String url = "$baseUrl/content";

      // 2. إذا كان نوع المحتوى مُمررًا، أضف الـ Query Parameter
      if (type != null && type.isNotEmpty) {
        // بناء رابط مثل: http://192.168.8.134:5000/api/content?type=معالم
        url = "$url?type=$type";
      }

      print('ℹ️ ContentService: جلب المحتوى من: $url');

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List jsonData = json.decode(response.body);
        print('✅ تم جلب ${jsonData.length} محتوى');
        return jsonData.map((item) => Content.fromJson(item)).toList();
      } else {
        // يمكنك فحص حالة 404 إذا لم يتم العثور على النوع
        if (response.statusCode == 404) {
          print('ℹ️ لم يتم العثور على محتوى');
          return [];
        }
        print('❌ خطأ: ${response.statusCode} - ${response.body}');
        throw Exception(
            "Failed to load contents. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print('❌ خطأ في ContentService: $e');
      throw Exception("خطأ في الاتصال: $e");
    }
  }
}
