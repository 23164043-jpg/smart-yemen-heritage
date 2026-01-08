// lib/services/auth_service.dart

import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  // دعم جميع المنصات تلقائياً
  static String get baseUrl {
    if (kIsWeb) {
      return "http://192.168.200.230:5000/api/users"; // Web
    } else if (Platform.isAndroid) {
      return "http://192.168.200.230:5000/api/users"; // Android Device
    } else {
      return "http://192.168.200.230:5000/api/users"; // iOS, Windows, macOS, Linux
    }
  }

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  // 1. 🔑 دالة لحفظ التوكن ومعرف المستخدم
  static Future<void> _saveTokenAndUserId(String token, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final successToken = await prefs.setString(_tokenKey, token);
    final successId = await prefs.setString(_userIdKey, userId);

    // سجل تشخيصي يوضح ما إذا كانت عملية الحفظ ناجحة
    print(
        '✅ AuthService: حالة حفظ التوكن: ($successToken)، حالة حفظ الـ ID: ($successId).');
  }

  // 2. 🔐 دالة لجلب التوكن (مع سجل تشخيصي)
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print(
        'ℹ️ AuthService.getAuthToken(): قيمة التوكن المُعادة هي: ${token != null ? token.substring(0, 10) + '...' : 'NULL'}');
    return token;
  }

  // 3. 👤 دالة لجلب معرف المستخدم
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // 4. 🚪 دالة تسجيل الدخول (المصححة مع التأخير الزمني)
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");
    print('ℹ️ AuthService: محاولة تسجيل الدخول إلى: $url');

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
      final token = data['token'] as String?;
      // 💡 التصحيح: جلب معرف المستخدم من داخل كائن 'user'
      final userId = data['user']?['id'] as String?;

      if (token != null && userId != null) {
        await _saveTokenAndUserId(token, userId);

        // ⏳ إضافة تأخير لضمان إتمام عملية الكتابة إلى القرص
        await Future.delayed(const Duration(milliseconds: 300));

        return {"success": true, "data": data};
      } else {
        print(
            '❌ AuthService: فشل الحفظ. التوكن: $token, معرف المستخدم: $userId');
        return {
          "success": false,
          "message":
              "Login successful, but token or user ID missing in response."
        };
      }
    } else {
      print('❌ AuthService: فشل تسجيل الدخول. الحالة: ${response.statusCode}');
      return {"success": false, "message": data["message"] ?? "Login failed"};
    }
  }

  // 5. 🗑️ دالة لتسجيل الخروج
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    print('✅ AuthService: تم تسجيل الخروج ومسح التوكن والمعرف.');
  }

  // 🧹 دالة مسح الذاكرة القسرية (مؤقتة للاختبار)
  static Future<void> clearAllPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('🚨 AuthService: تم مسح جميع بيانات SharedPreferences قسريًا.');
  }
}
