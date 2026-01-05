// lib/services/feedback_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/feedback_model.dart';
import 'auth_service.dart'; // 💡 استيراد AuthService

class FeedbackService {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:5000/api/feedback";
    } else if (Platform.isAndroid) {
      return "http://10.228.82.230:5000/api/feedback";
    } else {
      return "http://localhost:5000/api/feedback";
    }
  }

  // 1. 🚀 إرسال تقييم جديد (يتطلب Token)
  static Future<FeedbackItem> createFeedback(
      String userId, String contentId, int rating, String? comment) async {
    // 🔐 جلب رمز التصديق (Token) من الخدمة
    final token = await AuthService.getAuthToken();

    if (token == null) {
      // إطلاق استثناء إذا لم يكن المستخدم مسجل دخول
      throw Exception(
          "Authentication required. Please log in to submit feedback.");
    }

    // إعداد البيانات المراد إرسالها
    final feedbackData = {
      'user_id': userId,
      'content_id': contentId,
      'rating': rating,
      'comment': comment,
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        // إرسال رمز التصديق في رأس Authorization
        'Authorization': 'Bearer $token',
      },
      body: json.encode(feedbackData),
    );

    if (response.statusCode == 201) {
      return FeedbackItem.fromJson(json.decode(response.body));
    } else {
      final errorBody = json.decode(response.body);
      String errorMessage =
          errorBody['message'] ?? 'Failed to create feedback.';

      if (response.statusCode == 401) {
        throw Exception(
            "Authentication failed (401). Token is invalid or expired.");
      }

      throw Exception(
          "Feedback creation failed (Status ${response.statusCode}): $errorMessage");
    }
  }

  // 2. 📝 جلب جميع التقييمات
  static Future<List<FeedbackItem>> fetchAllFeedback() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List jsonList = json.decode(response.body);
      return jsonList.map((item) => FeedbackItem.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load feedback");
    }
  }
}
