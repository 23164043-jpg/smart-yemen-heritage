import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class SignupService {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:5000/api/users/register";
    } else if (Platform.isAndroid) {
      return "http://10.228.82.230:5000/api/users/register";
    } else {
      return "http://localhost:5000/api/users/register";
    }
  }

  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_name": name,
          "user_email": email,
          "user_password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          "success": true,
          "user": data["user"],
          "token": data["token"],
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "حدث خطأ غير متوقع"
        };
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}
