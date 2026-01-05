import 'dart:convert';
import 'package:http/http.dart' as http;

/// ملاحظة: هذا مثال لنداء مباشر إلى OpenAI Chat Completions
/// ⚠️ لا تضع مفتاح الإنتاج داخل التطبيق! استخدم سيرفر وسيط للحماية.
class AssistantService {
  AssistantService._();
  static final instance = AssistantService._();

  // ضع هنا عنوان السيرفر إذا تستخدم proxy/backend بدلاً من OpenAI المباشر.
  final String _openaiUrl = "https://api.openai.com/v1/chat/completions";

  /// إرسال رسالة إلى API واستلام رد
  /// apiKey: مفتاح OpenAI مؤقت (أو اجلبه من secure storage)
  Future<String> sendMessage({
    required String apiKey,
    required String message,
    String model = 'gpt-3.5-turbo', // نموذج افتراضي آمن للاستخدام
    double temperature = 0.7,
  }) async {
    final uri = Uri.parse(_openaiUrl);

    final body = {
      "model": model,
      "messages": [
        {
          "role": "system",
          "content":
              "أنت مساعد افتراضي يساعد المستخدم بشكل مختصر وواضح باللغة العربية."
        },
        {"role": "user", "content": message}
      ],
      "temperature": temperature,
      "max_tokens": 800
    };

    final resp = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(resp.body);
      // استخراج النص من الرد
      final choice = data["choices"]?[0];
      final content = choice?["message"]?["content"] ?? '';
      return content.toString().trim();
    } else {
      // خطأ من السيرفر - رجع رسالة خطأ توضيحية
      throw Exception('Request failed (${resp.statusCode}): ${resp.body}');
    }
  }
}
