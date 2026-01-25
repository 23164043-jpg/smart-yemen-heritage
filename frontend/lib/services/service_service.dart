import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';
import '../core/config/api_config.dart';

class ServiceService {
  static Future<List<ServiceModel>> fetchByContent(String contentId) async {
    final url =
        '${ApiConfig.baseUrl}/api/services/by-content/$contentId';

    final response =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ServiceModel.fromJson(e)).toList();
    } else {
      throw Exception('فشل في جلب الخدمات');
    }
  }
}
