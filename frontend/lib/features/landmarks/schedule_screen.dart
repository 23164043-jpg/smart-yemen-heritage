// lib/features/landmarks/schedule_screen.dart

import 'package:flutter/material.dart';
import '../../models/content_model.dart';
import '../../services/content_service.dart';
import '../../services/content_details_service.dart';
import 'details/content_details_screen.dart';

// تعريف الألوان
const Color _primaryColor = Color(0xFFCD853F);
const Color _cardColor = Colors.white;

class LandmarksScreen extends StatefulWidget {
  const LandmarksScreen({super.key});

  @override
  State<LandmarksScreen> createState() => _LandmarksScreenState();
}

class _LandmarksScreenState extends State<LandmarksScreen> {
  late Future<List<Content>> _contentsFuture;

  final List<String> defaultImages = [
    "assets/images/dar_alhajar.jpg",
    "assets/images/bab_yemen.jpg",
    "assets/images/hadramout.jpg",
  ];

  @override
  void initState() {
    super.initState();
    _contentsFuture = ContentService.fetchContents(type: 'Landmarks');
  }

  // لدالة تصحيح روابط الصور
  String _resolveImageUrl(String url) {
    // دعم Android Device
    const String baseUrl = "http://192.168.43.34:5000";
    if (url.startsWith('/uploads')) return baseUrl + url;
    return url;
  }

  // 💡 دالة للحصول على الصورة الفعلية من تفاصيل المحتوى
  Future<String> _fetchImageForContent(String contentId, int index) async {
    try {
      final details =
          await ContentDetailsService.fetchContentDetails(contentId);
      if (details.isNotEmpty &&
          details.first.imageUrl != null &&
          details.first.imageUrl!.isNotEmpty) {
        return _resolveImageUrl(details.first.imageUrl!);
      }
    } catch (e) {
      print("⚠️ خطأ في جلب الصورة: $e");
    }
    // fallback إذا لم تتوفر الصورة
    return defaultImages[index % defaultImages.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        title: const Text(
          "المعالم التاريخية",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 4,
      ),
      body: FutureBuilder<List<Content>>(
        future: _contentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _primaryColor),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "حدث خطأ: ${snapshot.error}",
                style: const TextStyle(color: _primaryColor),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("لا توجد معالم متاحة"));
          }

          final contents = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contents.length,
            itemBuilder: (context, index) {
              final item = contents[index];

              return FutureBuilder<String>(
                future: _fetchImageForContent(item.id, index),
                builder: (context, snapshotImage) {
                  final imageToShow = snapshotImage.data ??
                      defaultImages[index % defaultImages.length];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ContentDetailsScreen(
                            contentId: item.id,
                            latitude: item.latitude,
                            longitude: item.longitude,
                            address: item.address,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: _primaryColor.withOpacity(0.5), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            spreadRadius: 0,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: imageToShow.startsWith('http')
                                  ? Image.network(
                                      imageToShow,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          defaultImages[
                                              index % defaultImages.length],
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      imageToShow,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      color: _primaryColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (item.address != null)
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on,
                                            color: Colors.grey, size: 16),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            item.address!,
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                color: _primaryColor, size: 16),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
