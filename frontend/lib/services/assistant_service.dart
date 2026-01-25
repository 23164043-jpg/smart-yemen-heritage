import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class AssistantService {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://192.168.34.230:5000/api/ai";
    } else if (Platform.isAndroid) {
      return "http://192.168.34.230:5000/api/ai";
    } else {
      return "http://192.168.34.230:5000/api/ai";
    }
  }

  static Future<String> sendMessage(String message) async {
    final url = Uri.parse('$baseUrl/chat');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? "لا يوجد رد";
      } else {
        return "خطأ في الخادم: ${response.statusCode}";
      }
    } catch (e) {
      return "فشل الاتصال بالخادم: $e";
    }
  }
}
