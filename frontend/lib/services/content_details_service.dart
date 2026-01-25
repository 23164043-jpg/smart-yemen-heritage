import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/content_details_model.dart';

class ContentDetailsService {
  // دعم جميع المنصات
  static String get baseUrl {
    if (kIsWeb) {
      return "http://192.168.34.230:5000/api/content-details/by-content/";
    } else if (Platform.isAndroid) {
      return "http://192.168.34.230:5000/api/content-details/by-content/";
    } else {
      return "http://192.168.34.230:5000/api/content-details/by-content/";
    }
  }

  static Future<List<ContentDetails>> fetchContentDetails(
      String contentId) async {
    try {
      final url = Uri.parse('$baseUrl$contentId');
      print('ℹ️ ContentDetailsService: جلب البيانات من: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        print('✅ تم جلب ${data.length} عنصر');
        return data.map((json) => ContentDetails.fromJson(json)).toList();
      } else {
        print('❌ خطأ: ${response.statusCode} - ${response.body}');
        throw Exception('فشل في جلب البيانات: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ خطأ في ContentDetailsService: $e');
      throw Exception('خطأ في الاتصال: $e');
    }
  }
}
