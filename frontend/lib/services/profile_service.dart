import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة إدارة البروفايل - رفع وحذف صورة البروفايل
class ProfileService {
  // ============ إعدادات الـ API ============
  static String get baseUrl {
    if (kIsWeb) {
      return "http://192.168.43.34:5000/api/users";
    } else if (Platform.isAndroid) {
      return "http://192.168.43.34:5000/api/users";
    } else {
      return "http://192.168.43.34:5000/api/users";
    }
  }

  /// جلب التوكن المخزن
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // تصحيح: نفس المفتاح المستخدم في AuthService
  }

  /// حفظ رابط صورة البروفايل محلياً
  static Future<void> saveProfileImage(String? imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    if (imageUrl != null) {
      await prefs.setString('profile_image', imageUrl);
    } else {
      await prefs.remove('profile_image');
    }
  }

  /// جلب رابط صورة البروفايل المخزن محلياً
  static Future<String?> getProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_image');
  }

  /// رفع صورة البروفايل إلى السيرفر
  static Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'غير مصرح - يرجى تسجيل الدخول',
        };
      }

      print('📤 ProfileService: بدء رفع صورة البروفايل...');
      print('📁 حجم الملف: ${await imageFile.length()} bytes');

      // إنشاء طلب multipart
      final uri = Uri.parse('$baseUrl/profile/avatar');
      final request = http.MultipartRequest('POST', uri);

      // إضافة التوكن
      request.headers['Authorization'] = 'Bearer $token';

      // إضافة الصورة
      final multipartFile = await http.MultipartFile.fromPath(
        'avatar', // اسم الحقل المتوقع في Backend
        imageFile.path,
      );
      request.files.add(multipartFile);

      // إرسال الطلب
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 ProfileService: استجابة السيرفر: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final imageUrl = data['imageUrl'];

        // حفظ الرابط محلياً
        await saveProfileImage(imageUrl);

        print('✅ ProfileService: تم رفع الصورة بنجاح: $imageUrl');

        return {
          'success': true,
          'message': 'تم رفع الصورة بنجاح',
          'imageUrl': imageUrl,
        };
      } else {
        final error = json.decode(response.body);
        print('❌ ProfileService: فشل الرفع: ${error['message']}');

        return {
          'success': false,
          'message': error['message'] ?? 'فشل رفع الصورة',
        };
      }
    } catch (e) {
      print('❌ ProfileService: خطأ في رفع الصورة: $e');
      return {
        'success': false,
        'message': 'خطأ في الاتصال: $e',
      };
    }
  }

  /// حذف صورة البروفايل
  static Future<Map<String, dynamic>> deleteProfileImage() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'غير مصرح - يرجى تسجيل الدخول',
        };
      }

      print('🗑️ ProfileService: بدء حذف صورة البروفايل...');

      final response = await http.delete(
        Uri.parse('$baseUrl/profile/avatar'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // حذف الرابط المحلي
        await saveProfileImage(null);

        print('✅ ProfileService: تم حذف الصورة بنجاح');

        return {
          'success': true,
          'message': 'تم حذف الصورة بنجاح',
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'فشل حذف الصورة',
        };
      }
    } catch (e) {
      print('❌ ProfileService: خطأ في حذف الصورة: $e');
      return {
        'success': false,
        'message': 'خطأ في الاتصال: $e',
      };
    }
  }

  /// جلب معلومات المستخدم من السيرفر
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'غير مصرح - يرجى تسجيل الدخول',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // حفظ صورة البروفايل محلياً إذا وجدت
        if (data['profileImage'] != null) {
          await saveProfileImage(data['profileImage']);
        }

        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'فشل جلب المعلومات',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'خطأ في الاتصال: $e',
      };
    }
  }

  /// تحديث معلومات المستخدم
  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'غير مصرح - يرجى تسجيل الدخول',
        };
      }

      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_name': name,
          'user_email': email,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // تحديث البيانات المحلية
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', name);
        await prefs.setString('user_email', email);

        return {
          'success': true,
          'message': 'تم تحديث المعلومات بنجاح',
          'user': data['user'],
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'فشل تحديث المعلومات',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'خطأ في الاتصال: $e',
      };
    }
  }
}
