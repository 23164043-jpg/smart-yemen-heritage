import 'package:flutter/material.dart';
import '../../models/content_model.dart';
import '../../core/utils/url_helper.dart';
import '../../services/content_service.dart';
import '../../services/content_details_service.dart';
import '../landmarks/details/content_details_screen.dart';

class KingdomsScreen extends StatefulWidget {
  const KingdomsScreen({super.key});

  @override
  State<KingdomsScreen> createState() => _KingdomsScreenState();
}

class _KingdomsScreenState extends State<KingdomsScreen> {
  late Future<List<Content>> _contentsFuture;

  final List<String> defaultImages = [
    "assets/images/dar_alhajar.jpg",
    "assets/images/bab_yemen.jpg",
    "assets/images/hadramout.jpg",
  ];

  @override
  void initState() {
    super.initState();
    _contentsFuture = ContentService.fetchContents(type: 'Kingdoms');
  }

  String _resolveImageUrl(String url) {
    return UrlHelper.fixImageUrl(url);
  }

  // نفس الدالة الموجودة في المعالم
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
    return defaultImages[index % defaultImages.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFCD853F),
        title: const Text(
          "الممالك اليمنية القديمة",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Content>>(
        future: _contentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFFCD853F)));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("لا توجد ممالك متاحة"));
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
                          builder: (_) =>
                              ContentDetailsScreen(contentId: item.id),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.brown.withOpacity(0.5)),
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
                                imageToShow,
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
                              child: Text(
                                item.title,
                                style: const TextStyle(
                                  color: Color(0xFFCD853F),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                color: Color(0xFFCD853F), size: 16),
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
