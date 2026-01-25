import '../core/utils/url_helper.dart';

class ServiceModel {
  final String id;
  final String contentId;
  final String name;
  final String? description;
  final List<String> images;
  final double? latitude;
  final double? longitude;

  ServiceModel({
    required this.id,
    required this.contentId,
    required this.name,
    this.description,
    required this.images,
    this.latitude,
    this.longitude,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'],
      contentId: json['content_id'],
      name: json['service_name'] ?? '',
      description: json['description'],
      images: json['service_images'] != null
          ? List<String>.from(
              json['service_images'].map((e) => UrlHelper.fixImageUrl(e)),
            )
          : [],
      latitude: json['service_latitude'] != null
          ? double.tryParse(json['service_latitude'].toString())
          : null,
      longitude: json['service_longitude'] != null
          ? double.tryParse(json['service_longitude'].toString())
          : null,
    );
  }
}
