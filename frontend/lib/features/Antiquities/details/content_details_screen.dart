import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../models/content_details_model.dart';
import '../../../services/content_details_service.dart';

// تعريف الألوان المستخدمة لضمان التناسق
// تم تغيير الألوان لتناسب تصميم الواجهة الرئيسية (الذهبي/الأبيض)
const Color _primaryColor =
    Color(0xFFD4A017); // اللون الذهبي/الكهرماني (AppColors.primary)
const Color _backgroundColor = Colors.white; // لون الخلفية الأبيض

class ContentDetailsScreen extends StatefulWidget {
  final String contentId;

  const ContentDetailsScreen({super.key, required this.contentId});

  @override
  State<ContentDetailsScreen> createState() => _ContentDetailsScreenState();
}

class _ContentDetailsScreenState extends State<ContentDetailsScreen> {
  late Future<List<ContentDetails>> _detailsFuture;
  final List<String> defaultImages = [
    'assets/images/dar_alhajar1.jpg',
    'assets/images/dar_alhajar2.jpg',
    'assets/images/dar_alhajar3.jpg',
  ];

  void _openLocationOnMap(double? latitude, double? longitude) async {
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد إحداثيات لهذا المعلم')),
      );
      return;
    }
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن فتح الخريطة')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _detailsFuture =
        ContentDetailsService.fetchContentDetails(widget.contentId);
  }

  // 💡 دالة مساعدة لتصحيح رابط الصورة
  String _resolveImageUrl(String url) {
    // عنوان السيرفر الفعلي
    const String baseUrl = "http://10.228.82.230:5000";
    
    // إذا كان الرابط يبدأ بـ /uploads
    if (url.startsWith('/uploads')) {
      return baseUrl + url;
    }
    
    // إذا كان الرابط يحتوي على عنوان المحاكي (10.0.2.2) أو localhost
    if (url.contains('10.0.2.2:5000') || url.contains('localhost:5000')) {
      // استخراج مسار الصورة واستبدال العنوان
      final uri = Uri.parse(url);
      return '$baseUrl${uri.path}';
    }
    
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: FutureBuilder<List<ContentDetails>>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: _primaryColor));
          } else if (snapshot.hasError) {
            return Center(
                child: Text("حدث خطأ: ${snapshot.error}",
                    style: const TextStyle(color: _primaryColor)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text("لا توجد تفاصيل لهذا المعلم",
                    style: TextStyle(color: _primaryColor)));
          }

          final item = snapshot.data!.first;
          // 💡 تصحيح روابط الصور
          final String resolvedImageUrl =
              (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                  ? _resolveImageUrl(item.imageUrl!)
                  : defaultImages[0];
          final List<String> images = [resolvedImageUrl];

          return ListView(
            children: [
              _buildImageGallery(images, screenHeight),
              if (item.latitude != null && item.longitude != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    height: 250,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(item.latitude!, item.longitude!),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('monument_location'),
                            position: LatLng(item.latitude!, item.longitude!),
                            infoWindow: InfoWindow(title: item.title),
                          ),
                        },
                        onMapCreated: (controller) {
                          // يمكن استخدام controller لاحقاً إذا لزم الأمر
                        },
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: true,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () =>
                        _openLocationOnMap(item.latitude, item.longitude),
                    icon: const Icon(Icons.location_on, size: 28),
                    label: const Text('عرض الموقع على الخريطة',
                        style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                    color: _backgroundColor,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: Offset(0, -5))
                    ]),
                padding: EdgeInsets.fromLTRB(20, 30, 20, screenHeight * 0.15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(
                        item.title, item.imageUrl ?? defaultImages[0]),
                    const SizedBox(height: 15),
                    _buildSmallImageGallery(images),
                    const SizedBox(height: 30),
                    _buildAboutSection(item.description),
                    const SizedBox(height: 30),
                    _buildInteractionButtons(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          );

          // تم حذف الكود الميت للأزرار السفلية الثابتة (غير مستخدم في هذا السياق)
        },
      ),
    );
  }

  // ===========================================
  // ============= WIDGET BUILDERS =============
  // ===========================================

  // ... (باقي دوال بناء ال Widgets كما هي، مع تطبيق _primaryColor)
  Widget _buildImageGallery(List<String> images, double screenHeight) {
    return Image.network(
      images[0],
      width: double.infinity,
      height: screenHeight * 0.55,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
            child: CircularProgressIndicator(color: _primaryColor));
      },
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          defaultImages[0],
          fit: BoxFit.cover,
          width: double.infinity,
          height: screenHeight * 0.55,
        );
      },
    );
  }

  Widget _buildHeaderSection(String title, String imageUrl) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          radius: 28,
          child: ClipOval(
            child: Image.network(
              imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                defaultImages[0],
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
                fontSize: 26,
                color: _primaryColor,
                fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallImageGallery(List<String> images) {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final isAsset = images[index].startsWith('assets');
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: isAsset
                  ? Image.asset(images[index],
                      width: 70, height: 70, fit: BoxFit.cover)
                  : Image.network(
                      images[index],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        defaultImages[index % defaultImages.length],
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAboutSection(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.info_outline, color: _primaryColor, size: 24),
            SizedBox(width: 8),
            Text('عن المعلم',
                style: TextStyle(
                    fontSize: 20,
                    color: _primaryColor,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        const Divider(color: _primaryColor, thickness: 0.5),
        const SizedBox(height: 10),
        Text(
          description,
          textAlign: TextAlign.justify,
          style:
              const TextStyle(fontSize: 16, color: Colors.black87, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildInteractionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildIconWithText(
          icon: Icons.comment_outlined,
          text: 'التعليقات (0)',
          onPressed: () {},
        ),
        _buildIconWithText(
          icon: Icons.star_border,
          text: 'أضف تقييمك',
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildIconWithText({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: _primaryColor, size: 30),
        ),
        Text(text, style: const TextStyle(color: _primaryColor, fontSize: 13)),
      ],
    );
  }
}
