import 'package:flutter/material.dart';
import '../../models/content_model.dart';
import '../../services/content_service.dart';
import '../../services/content_details_service.dart';
import '../landmarks/details/content_details_screen.dart';

const Color _primaryColor = Color(0xFF8B4513); // لون بني للمواقع المندثرة
const Color _backgroundColor = Colors.white;

class ExtinctSitesScreen extends StatefulWidget {
  const ExtinctSitesScreen({super.key});

  @override
  State<ExtinctSitesScreen> createState() => _ExtinctSitesScreenState();
}

class _ExtinctSitesScreenState extends State<ExtinctSitesScreen> {
  late Future<List<Content>> _contentsFuture;

  // الصور الافتراضية
  final List<String> defaultImages = [
    "assets/images/dar_alhajar.jpg",
    "assets/images/bab_yemen.jpg",
    "assets/images/hadramout.jpg",
  ];

  @override
  void initState() {
    super.initState();
    _contentsFuture = ContentService.fetchContents(type: 'المواقع المندثرة');
  }

  String _resolveImageUrl(String url) {
    const String baseUrl = "http://192.168.34.230:5000";
    if (url.startsWith('/uploads')) return baseUrl + url;
    return url;
  }

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
      print("⚠️ خطأ في جلب تفاصيل الصورة: $e");
    }

    return defaultImages[index % defaultImages.length];
  }

  Widget _buildContentCard(String imageUrl, Content item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryColor.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
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
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Image.asset(
                    defaultImages[index % defaultImages.length],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  );
                },
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
                        Expanded(
                          child: Text(
                            item.address!,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: _primaryColor, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 4,
        title: const Text(
          "المواقع المندثرة",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Content>>(
        future: _contentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: _primaryColor,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    "حدث خطأ: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final contents = snapshot.data ?? [];

          if (contents.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "لا توجد مواقع مندثرة حالياً",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: ListView.builder(
              itemCount: contents.length,
              itemBuilder: (context, index) {
                final item = contents[index];

                return FutureBuilder<String>(
                  future: _fetchImageForContent(item.id, index),
                  builder: (context, imgSnapshot) {
                    final imageUrl = imgSnapshot.data ??
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
                      child: _buildContentCard(imageUrl, item, index),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
