import 'package:flutter/material.dart';
import '../../models/content_model.dart';
import '../../services/content_service.dart';
import '../../services/content_details_service.dart';
import '../landmarks/details/content_details_screen.dart';

const Color _primaryColor = Color(0xFFCD853F);
const Color _backgroundColor = Colors.white;

class AntiquitiesScreen extends StatefulWidget {
  const AntiquitiesScreen({super.key});

  @override
  State<AntiquitiesScreen> createState() => _AntiquitiesScreenState();
}

class _AntiquitiesScreenState extends State<AntiquitiesScreen> {
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

    // النوع الصحيح بدون رموز خاطئة
    _contentsFuture = ContentService.fetchContents(type: 'Antiquities');
  }

  // لنفس الدالة المستخدمة في الممالك والمعالم
  String _resolveImageUrl(String url) {
    // دعم Android Device
    const String baseUrl = "http://10.228.82.230:5000";
    if (url.startsWith('/uploads')) return baseUrl + url;
    return url;
  }

  // 🔥 جلب صورة المحتوى من ContentDetails
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

  // 🔥 بطاقة المحتوى
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

            // النصوص
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
          "الآثار القديمة",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<Content>>(
        future: _contentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: _primaryColor));
          }

          if (snapshot.hasError) {
            return Center(child: Text("خطأ: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("لا توجد آثار متاحة"));
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
                  final imageUrl = snapshotImage.data ??
                      defaultImages[index % defaultImages.length];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ContentDetailsScreen(contentId: item.id),
                        ),
                      );
                    },
                    child: _buildContentCard(imageUrl, item, index),
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
