// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // <--- الاستيراد الجديد

class AuthService {
  static const String baseUrl = "http://192.168.200.230:5000/api";
  static const String _tokenKey = 'auth_token'; // مفتاح التخزين

  // 1. 🔑 دالة لحفظ التوكن (Token)
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // 2. 🔐 دالة لجلب التوكن (لاستخدامها في FeedbackService)
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // 3. 🚪 دالة تسجيل الدخول (مُعدَّلة لحفظ التوكن)
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_email": email,
        "user_password": password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // 🚨 تحقق: يجب أن يكون الـ Backend يرسل التوكن في حقل ما (مثل 'token')
      final token = data['token'] as String?;

      if (token != null) {
        await _saveToken(token); // حفظ التوكن عند النجاح
        return {"success": true, "data": data};
      } else {
        // إذا نجح تسجيل الدخول لكن التوكن غير موجود
        return {
          "success": false,
          "message": "Login successful, but token missing."
        };
      }
    } else {
      return {"success": false, "message": data["message"] ?? "Login failed"};
    }
  }

  // 4. 🗑️ دالة لتسجيل الخروج (لمسح التوكن)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
