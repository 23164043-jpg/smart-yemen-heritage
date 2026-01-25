import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart'; // لجلب التوكن الخاص بالمستخدم

class NotificationService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static const String _baseUrl =
      'http://192.168.43.34:5000/api/device-tokens';

  static Future<void> init() async {
    // 1️⃣ طلب صلاحيات الإشعارات
    NotificationSettings settings =
        await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
        '🔔 Notification permission status: ${settings.authorizationStatus}');

    // 2️⃣ جلب FCM Token
    String? fcmToken = await _messaging.getToken();
    debugPrint('🔥 FCM TOKEN: $fcmToken');

    if (fcmToken == null) return;

    // 3️⃣ جلب JWT Token (توكن تسجيل الدخول)
    final authToken = await AuthService.getAuthToken();
    if (authToken == null) {
      debugPrint('⚠️ المستخدم غير مسجل دخول – لم يتم إرسال FCM Token');
      return;
    }

    // 4️⃣ إرسال FCM Token إلى الباك اند
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'token': fcmToken,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ تم حفظ FCM Token في السيرفر');
      } else {
        debugPrint(
            '❌ فشل حفظ FCM Token: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ خطأ أثناء إرسال FCM Token: $e');
    }

    // 5️⃣ استقبال إشعار أثناء فتح التطبيق
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 إشعار وارد (Foreground)');
      debugPrint('📌 العنوان: ${message.notification?.title}');
      debugPrint('📌 النص: ${message.notification?.body}');
    });
  }
}
