import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 اختبار الاتصال بالسيرفر...\n');
  
  final ips = [
    '192.168.137.171',
    '10.0.2.2', // للمحاكي
    'localhost',
    '127.0.0.1',
  ];
  
  for (final ip in ips) {
    final url = 'http://$ip:5000/api/users/login';
    print('📡 اختبار: $url');
    
    try {
      final sw = Stopwatch()..start();
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: '{"user_email":"yahya@gmail.com","user_password":"1234321"}',
      ).timeout(Duration(seconds: 5));
      sw.stop();
      
      print('✅ نجح! الحالة: ${response.statusCode}, الوقت: ${sw.elapsedMilliseconds}ms\n');
    } catch (e) {
      print('❌ فشل: $e\n');
    }
  }
}
