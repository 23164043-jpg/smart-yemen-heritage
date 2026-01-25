import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OcrService {
  static const String baseUrl = 'http://192.168.43.34:5000';

  // إرسال صورة للـ OCR
  Future<Map<String, dynamic>> processImage(File imageFile, String language) async {
    try {
      var uri = Uri.parse('$baseUrl/api/ai/ocr');
      var request = http.MultipartRequest('POST', uri);

      // إضافة الصورة
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      // إضافة اللغة
      request.fields['lang'] = language;

      // إرسال الطلب
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );

      // قراءة الاستجابة
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في معالجة الصورة: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // الحصول على اللغات المدعومة
  List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'ara', 'name': 'العربية'},
      {'code': 'eng', 'name': 'English'},
      {'code': 'ara+eng', 'name': 'العربية + English'},
    ];
  }
}
