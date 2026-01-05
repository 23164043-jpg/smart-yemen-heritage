import '../core/utils/url_helper.dart';

class ContentDetails {
  final String id;
  final String contentId;
  final String title;
  final String description;
  final String languageCode;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;

  ContentDetails({
    required this.id,
    required this.contentId,
    required this.title,
    required this.description,
    required this.languageCode,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });

  factory ContentDetails.fromJson(Map<String, dynamic> json) {
    // تصحيح رابط الصورة تلقائياً
    String? rawImageUrl = json['image_url'];
    String? fixedImageUrl =
        rawImageUrl != null ? UrlHelper.fixImageUrl(rawImageUrl) : null;

    double? lat;
    double? lng;
    if (json['latitude'] != null) {
      lat = double.tryParse(json['latitude'].toString());
    }
    if (json['longitude'] != null) {
      lng = double.tryParse(json['longitude'].toString());
    }

    return ContentDetails(
      id: json['_id'],
      contentId: json['content_id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      languageCode: json['language_code'] ?? '',
      imageUrl: fixedImageUrl,
      latitude: lat,
      longitude: lng,
    );
  }

  get address => null;
}
