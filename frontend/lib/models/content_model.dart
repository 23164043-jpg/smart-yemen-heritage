class Content {
  final String id;
  final String title;
  final String description;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;

  Content({
    required this.id,
    required this.title,
    required this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.imageUrl,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    // تحويل الإحداثيات من String إلى double
    // الإحداثيات قد تكون في حقل واحد "lat" بصيغة "15.3547, 44.2066"
    // أو في حقلين منفصلين "lat" و "lng"
    double? lat;
    double? lng;

    if (json['lat'] != null) {
      String latString = json['lat'].toString();
      // التحقق إذا كان الحقل يحتوي على كلا الإحداثيتين
      if (latString.contains(',')) {
        List<String> coords = latString.split(',');
        if (coords.length >= 2) {
          lat = double.tryParse(coords[0].trim());
          lng = double.tryParse(coords[1].trim());
        }
      } else {
        lat = double.tryParse(latString);
      }
    }

    // إذا كان هناك حقل lng منفصل
    if (json['lng'] != null && lng == null) {
      lng = double.tryParse(json['lng'].toString());
    }

    print('🔍 تحليل JSON للمحتوى:');
    print('   - ID: ${json['_id']}');
    print('   - Title: ${json['title']}');
    print('   - image_url: ${json['image_url']}');

    return Content(
      id: json['_id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      address: json['address'],
      latitude: lat,
      longitude: lng,
      imageUrl: json['image_url'],
    );
  }
}
