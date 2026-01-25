import 'package:flutter/material.dart';
// استيراد الخدمات والموديلات الأساسية
import '../../../models/content_details_model.dart';
import '../../../services/content_details_service.dart';
// استيراد الخدمات الجديدة (Favorites & Feedback/Auth)
import '../../../core/services/favorites_manager.dart';
import '../../../services/feedback_service.dart' as feedback;
import '../../../services/auth_service.dart'; // 💡 استيراد AuthService
// استيراد الشاشات الأخرى
import '../../ar/ar_view_screen.dart';
import '../../assistant/smart_assistant_screen.dart';

// تعريف الألوان المستخدمة لضمان التناسق
const Color _primaryColor = Color(0xFFD4A017); // اللون الذهبي/الكهرماني
const Color _backgroundColor = Colors.white; // لون الخلفية الأبيض

class ContentDetailsScreen extends StatefulWidget {
  final String contentId;
  final String? address;

  const ContentDetailsScreen({
    super.key,
    required this.contentId,
    this.address,
  });

  @override
  State<ContentDetailsScreen> createState() => _ContentDetailsScreenState();
}

class _ContentDetailsScreenState extends State<ContentDetailsScreen> {
  late Future<List<ContentDetails>> _detailsFuture;
  bool _isBookmarked = false;
  // تم إزالة _currentImageIndex لأنه غير مستخدم في هذا الكود

  ContentDetails? _currentItemDetails;

  final List<String> defaultImages = [
    'assets/images/dar_alhajar1.jpg',
    'assets/images/dar_alhajar2.jpg',
    'assets/images/dar_alhajar3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _checkToken();
    _isBookmarked = FavoritesManager.instance.isFavorite(widget.contentId);
    _detailsFuture =
        ContentDetailsService.fetchContentDetails(widget.contentId);
  }

  // لدالة مساعدة لتصحيح رابط الصورة
  String _resolveImageUrl(String url) {
    // لدعم Android Device
    const String baseUrl = "http://192.168.8.134:5000";

    // إذا كان الرابط يبدأ بـ /uploads (مسار نسبي)، أضف الـ Base URL
    if (url.startsWith('/uploads')) {
      return baseUrl + url;
    }
    // إذا كان رابط شبكة كامل (http/https) أو ملف asset محلي
    return url;
  }

  // 💡 تشخيص: دالة مؤقتة لفحص التوكن
  void _checkToken() async {
    final token = await AuthService.getAuthToken();

    if (token != null) {
      print('✅ CheckToken: التوكن موجود، يبدأ بـ: ${token.substring(0, 10)}');
    } else {
      print('❌ CheckToken: التوكن NULL.');
    }
  }

  // ===========================================
  // ============= وظائف المفضلة (Favorites) =============
  // ===========================================

  void _toggleBookmark() {
    if (_currentItemDetails == null) return;

    FavoritesManager.instance.toggleFavorite(
      widget.contentId,
      title: _currentItemDetails!.title,
      image: _currentItemDetails!.imageUrl ?? defaultImages[0],
    );

    setState(() {
      _isBookmarked = FavoritesManager.instance.isFavorite(widget.contentId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isBookmarked
            ? 'تم الحفظ في المفضلة'
            : 'تم إزالة الحفظ من المفضلة'),
        duration: const Duration(seconds: 2),
        backgroundColor: _primaryColor,
      ),
    );
  }

  // ===========================================
  // ============= وظائف التقييمات (Feedback) المُعدَّلة =============
  // ===========================================

  void _showRatingDialog(BuildContext context) {
    int? selectedRating;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تقييم وإضافة ملاحظة', textAlign: TextAlign.right),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. تحديد النجوم (التقييم)
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < (selectedRating ?? 0)
                                ? Icons.star
                                : Icons.star_border,
                            color: _primaryColor,
                            size: 30,
                          ),
                          onPressed: () {
                            setState(() {
                              selectedRating = index + 1;
                            });
                          },
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(height: 15),
                // 2. حقل التعليق
                TextField(
                  controller: commentController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: 'ملاحظاتك (اختياري)',
                    border: const OutlineInputBorder(),
                    labelStyle: TextStyle(color: Colors.grey.shade600),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: _primaryColor),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedRating == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'الرجاء اختيار تقييم (نجمة واحدة على الأقل).')),
                  );
                  return;
                }
                Navigator.pop(context); // إغلاق مربع الحوار
                _submitFeedback(selectedRating!, commentController.text);
              },
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
              child: const Text('إرسال', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _submitFeedback(int rating, String comment) async {
    final String contentId = widget.contentId;

    try {
      // 1. 💡 جلب معرف المستخدم الحقيقي والتوكن للتحقق
      final String? userId = await AuthService.getUserId();
      final String? authToken = await AuthService.getAuthToken();

      if (authToken == null || userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الرجاء تسجيل الدخول أولاً لإضافة تقييم.'),
            backgroundColor: Colors.blueGrey,
          ),
        );
        return;
      }

      // 2. إرسال البيانات عبر الخدمة باستخدام الـ userId الحقيقي
      await feedback.createFeedback(
        userId, // استخدام الـ userId الذي تم جلبه
        contentId,
        rating,
        comment.isEmpty ? null : comment,
      );

      // 3. إظهار رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال تقييمك بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // 4. إظهار رسالة خطأ
      String errorMessage = e.toString().contains("Authentication required")
          ? "يجب تسجيل الدخول لإضافة تقييم."
          : e.toString().replaceAll('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل إرسال التقييم: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ... (بقية دوال المساعد والواقع المعزز) ...
  void _navigateToAR() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => const ARViewScreen(title: 'نموذج ثلاثي الأبعاد')),
    );
  }

  void _showSmartAssistantPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.all(20),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: _primaryColor,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'المساعد الذكي',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                ),
                const Expanded(
                  child: SmartAssistantScreen(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================
  // ============= WIDGET BUILDERS =============
  // ===========================================

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
          _currentItemDetails = item;

          // 💡 يتم تمرير قائمة الصور (أو الرابط الوحيد) للعرض
          final List<String> images =
              (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                  ? [item.imageUrl!]
                  : defaultImages;

          return Stack(
            children: [
              // 1. المحتوى القابل للتمرير (CustomScrollView)
              CustomScrollView(
                slivers: [
                  // شريط التطبيق المرن (SliverAppBar)
                  SliverAppBar(
                    expandedHeight: screenHeight * 0.55,
                    pinned: true,
                    backgroundColor: _backgroundColor,
                    leading: _buildCircleIconButton(
                      icon: Icons.arrow_back,
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      _buildCircleIconButton(
                        icon: Icons.share,
                        onPressed: () {/* وظيفة المشاركة */},
                      ),
                      _buildCircleIconButton(
                        icon: _isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        onPressed: _toggleBookmark,
                        iconColor: _isBookmarked ? _primaryColor : Colors.white,
                        backgroundColor:
                            _isBookmarked ? Colors.white : Colors.black45,
                      ),
                      const SizedBox(width: 8),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildImageGallery(images, screenHeight),
                    ),
                  ),

                  // 2. المحتوى الثابت (SliverToBoxAdapter)
                  SliverToBoxAdapter(
                    child: Container(
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
                      padding:
                          EdgeInsets.fromLTRB(20, 30, 20, screenHeight * 0.15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderSection(
                              item.title, item.imageUrl ?? defaultImages[0]),
                          const SizedBox(height: 8),

                          // ====== هنا عرض الموقع بنفس شكل صفحة المعالم (أيقونة + نص) ======
                          if (item.address != null && item.address!.isNotEmpty)
                            _buildLocationRow(item.address),
                          const SizedBox(height: 15),

                          _buildSmallImageGallery(images),
                          const SizedBox(height: 30),
                          //_buildAboutSection(item.description),
                          const SizedBox(height: 30),
                          _buildInteractionButtons(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // 3. الأزرار السفلية الثابتة (Sticky Bottom Actions)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        offset: const Offset(0, -4),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        // زر الواقع المعزز (AR Button)
                        Expanded(
                          flex: 3,
                          child: ElevatedButton.icon(
                            onPressed: _navigateToAR,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                            ),
                            icon: const Icon(Icons.view_in_ar, size: 24),
                            label: const Text('المشاهدة بالواقع المعزز',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // زر المساعد الذكي (Assistant Button)
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            onPressed: () => _showSmartAssistantPopup(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _primaryColor,
                              side: const BorderSide(
                                  color: _primaryColor, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child:
                                const Icon(Icons.record_voice_over, size: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color iconColor = Colors.white,
    Color backgroundColor = Colors.black45,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8, left: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: 24),
        onPressed: onPressed,
      ),
    );
  }

  // 🖼️ دالة بناء معرض الصور (مع تصحيح الرابط)
  Widget _buildImageGallery(List<String> images, double screenHeight) {
    // 💡 تصحيح الرابط أولاً
    final String imagePath = _resolveImageUrl(images[0]);
    final bool isNetworkImage = imagePath.startsWith('http');

    return isNetworkImage
        ? Image.network(
            imagePath,
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
          )
        : Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: screenHeight * 0.55,
          );
  }

  // 👤 دالة بناء قسم الرأس (مع تصحيح الرابط)
  Widget _buildHeaderSection(String title, String imageUrl) {
    // 💡 تصحيح الرابط أولاً
    final String imagePath = _resolveImageUrl(imageUrl);
    final bool isNetworkImage = imagePath.startsWith('http');

    Widget imageWidget = isNetworkImage
        ? Image.network(
            imagePath,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              defaultImages[0],
              fit: BoxFit.cover,
            ),
          )
        : Image.asset(
            imagePath,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          );

    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          radius: 28,
          child: ClipOval(
            child: imageWidget,
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

  // ------------------- هنا أضفنا دالة عرض الموقع -------------------
  // عرض الموقع بنفس شكل صفحة المعالم (أيقونة + نص، بدون تفاعل)
  Widget _buildLocationRow(String? address) {
    if (address == null || address.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        const Icon(Icons.location_on, color: Colors.grey, size: 16),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            address,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // 🖼️ دالة بناء معرض الصور الصغير (مع تصحيح الرابط)
  Widget _buildSmallImageGallery(List<String> images) {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          // 💡 تطبيق التصحيح هنا
          final String imagePath = _resolveImageUrl(images[index]);
          final isAsset = imagePath.startsWith('assets');

          Widget imageWidget = isAsset
              ? Image.asset(imagePath, width: 70, height: 70, fit: BoxFit.cover)
              : Image.network(
                  imagePath,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    defaultImages[index % defaultImages.length],
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                );

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageWidget,
            ),
          );
        },
      ),
    );
  }

  // ignore: unused_element
  Widget _buildAboutSection(String description, String? address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.info_outline, color: _primaryColor, size: 24),
            SizedBox(width: 8),
            Text(
              'عن المعلم',
              style: TextStyle(
                  fontSize: 20,
                  color: _primaryColor,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        if (address != null && address.isNotEmpty) _buildLocationRow(address),
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
          onPressed: () {
            // تنفيذ جلب وعرض التعليقات هنا
          },
        ),
        _buildIconWithText(
          icon: Icons.star_border,
          text: 'أضف تقييمك',
          onPressed: () => _showRatingDialog(context), // ربط دالة التقييم
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
