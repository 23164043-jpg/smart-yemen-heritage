import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';

// استيراد الخدمات والموديلات الأساسية
import '../../../models/content_details_model.dart';
import '../../../services/content_details_service.dart';
// استيراد الخدمات الجديدة (Favorites & Feedback/Auth)
import '../../../core/services/favorites_manager.dart';
import '../../../services/feedback_service.dart';
import '../../../services/auth_service.dart';
// استيراد الشاشات الأخرى
import '../../ar/ar_view_screen.dart';
import '../../assistant/smart_assistant_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ═══════════════════ تعريف الألوان والثوابت ═══════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════

const Color _primaryGold = Color(0xFFD4A017);
const Color _primaryGoldLight = Color(0xFFE8C547);
const Color _primaryGoldDark = Color(0xFFB8860B);
const Color _backgroundColor = Colors.white;
const Color _surfaceColor = Color(0xFFF8F9FA);
const Color _darkCard = Color(0xFF1E1E2D);
const Color _darkCardLight = Color(0xFF2D2D3D);
const Color _textPrimary = Color(0xFF2D2D2D);
const Color _textSecondary = Color(0xFF6B7280);
const Color _textMuted = Color(0xFF9CA3AF);

// ═══════════════════════════════════════════════════════════════════════════
// ═══════════════════ الصفحة الرئيسية ═══════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════

class ContentDetailsScreen extends StatefulWidget {
  final String contentId;
  final double? latitude;
  final double? longitude;
  final String? address;

  const ContentDetailsScreen({
    super.key,
    required this.contentId,
    this.latitude,
    this.longitude,
    this.address,
  });

  @override
  State<ContentDetailsScreen> createState() => _ContentDetailsScreenState();
}

class _ContentDetailsScreenState extends State<ContentDetailsScreen>
    with SingleTickerProviderStateMixin {
  // =================== متغيرات الحالة ===================
  late Future<List<ContentDetails>> _detailsFuture;
  late TabController _tabController;

  bool _isBookmarked = false;
  bool _isSpeaking = false;
  ContentDetails? _currentItemDetails;
  GoogleMapController? _mapController;

  // Text-to-Speech عبر Method Channel
  static const MethodChannel _ttsChannel =
      MethodChannel('com.example.frontend/tts');
  bool _ttsInitialized = false;

  final List<String> defaultImages = [
    'assets/images/dar_alhajar1.jpg',
    'assets/images/dar_alhajar2.jpg',
    'assets/images/dar_alhajar3.jpg',
  ];

  // =================== Quick Facts Data ===================
  final List<Map<String, dynamic>> _quickFacts = [
    {
      'icon': Icons.calendar_today,
      'label': 'تاريخ البناء',
      'value': 'القرن السادس عشر'
    },
    {'icon': Icons.height, 'label': 'الارتفاع', 'value': 'حتى 8 طوابق'},
    {'icon': Icons.location_city, 'label': 'المباني', 'value': '~500 برج'},
    {'icon': Icons.foundation, 'label': 'المواد', 'value': 'طوب طيني'},
    {'icon': Icons.verified, 'label': 'اليونسكو', 'value': '1982'},
  ];

  // =================== Timeline Data ===================
  final List<Map<String, String>> _timelineData = [
    {
      'period': 'العصور القديمة',
      'title': 'التأسيس',
      'description':
          'تم تأسيس هذا المعلم في العصور القديمة كأحد أهم المباني التاريخية في المنطقة.',
    },
    {
      'period': 'العصور الوسطى',
      'title': 'فترة الازدهار',
      'description':
          'شهد المعلم فترة ازدهار كبيرة وأصبح مركزاً ثقافياً وحضارياً مهماً.',
    },
    {
      'period': 'العصر الحديث',
      'title': 'الترميم والحفاظ',
      'description':
          'تم ترميم المعلم والحفاظ عليه كإرث تاريخي للأجيال القادمة.',
    },
  ];

  // =================== دورة الحياة ===================
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkToken();
    _isBookmarked = FavoritesManager.instance.isFavorite(widget.contentId);
    _detailsFuture =
        ContentDetailsService.fetchContentDetails(widget.contentId);
    _initTts();
  }

  /// تهيئة Text-to-Speech عبر Method Channel
  Future<void> _initTts() async {
    try {
      final result = await _ttsChannel.invokeMethod('initialize', {
        'language': 'ar',
        'speechRate': 0.8,
      });
      _ttsInitialized = result == true;
    } catch (e) {
      debugPrint('TTS initialization error: $e');
      // TTS متاح افتراضياً على معظم أجهزة Android
      _ttsInitialized = true;
    }
  }

  @override
  void dispose() {
    _stopSpeaking();
    _tabController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  /// إيقاف القراءة الصوتية
  Future<void> _stopSpeaking() async {
    try {
      await _ttsChannel.invokeMethod('stop');
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
    if (mounted) setState(() => _isSpeaking = false);
  }

  // =================== دالة تصحيح رابط الصورة ===================
  String _resolveImageUrl(String url) {
    const String baseUrl = "http://192.168.200.230:5000";
    if (url.startsWith('/uploads')) {
      return baseUrl + url;
    }
    if (url.contains('10.0.2.2:5000') || url.contains('localhost:5000')) {
      final uri = Uri.parse(url);
      return '$baseUrl${uri.path}';
    }
    return url;
  }

  // =================== تشخيص التوكن ===================
  void _checkToken() async {
    final token = await AuthService.getAuthToken();
    if (token != null) {
      debugPrint('✅ CheckToken: التوكن موجود');
    } else {
      debugPrint('❌ CheckToken: التوكن NULL.');
    }
  }

  // =================== حساب وقت القراءة ===================
  String _calculateReadTime(String description) {
    final wordCount = description.split(' ').length;
    final minutes = (wordCount / 200).ceil();
    return '$minutes دقيقة';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ═══════════════════ وظائف التفاعل الأساسية ═══════════════════════════════
  // ═══════════════════════════════════════════════════════════════════════════

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

    _showSnackBar(
      _isBookmarked ? 'تم الحفظ في المفضلة ⭐' : 'تم إزالة الحفظ من المفضلة',
      icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
    );
  }

  void _shareContent() {
    if (_currentItemDetails == null) return;

    final String shareText = '''
🏛️ ${_currentItemDetails!.title}

${_currentItemDetails!.description.length > 200 ? '${_currentItemDetails!.description.substring(0, 200)}...' : _currentItemDetails!.description}

📍 اكتشف المزيد عبر تطبيق التراث اليمني الذكي
    ''';

    Share.share(shareText, subject: _currentItemDetails!.title);
  }

  Future<void> _toggleSpeech() async {
    print('🔊🔊🔊 TTS BUTTON PRESSED 🔊🔊🔊');
    
    if (_currentItemDetails == null) {
      print('❌ TTS: Content not loaded');
      _showSnackBar('الرجاء الانتظار حتى يتم تحميل المحتوى', isError: true);
      return;
    }

    if (_isSpeaking) {
      // إيقاف القراءة
      print('🔇 TTS: Stopping speech');
      await _stopSpeaking();
      _showSnackBar('تم إيقاف القراءة 🔇', icon: Icons.volume_off);
    } else {
      // بدء القراءة
      setState(() => _isSpeaking = true);
      _showSnackBar('جاري القراءة الصوتية... 🔊', icon: Icons.volume_up);

      // تحضير النص للقراءة
      String textToRead = _prepareTextForSpeech();
      print('📝 TTS: Text length: ${textToRead.length}');

      try {
        // بدء القراءة عبر Method Channel
        print('🚀 TTS: Calling Method Channel speak');
        final result = await _ttsChannel.invokeMethod('speak', {
          'text': textToRead,
          'language': 'ar',
        });
        print('✅ TTS: Result = $result');

        // محاكاة وقت القراءة (تقريبياً 100 كلمة في الدقيقة)
        final wordCount = textToRead.split(' ').length;
        final estimatedDuration =
            Duration(milliseconds: (wordCount * 600).clamp(3000, 60000));
        print('⏱️ TTS: Duration = ${estimatedDuration.inSeconds}s');

        await Future.delayed(estimatedDuration);
        if (mounted) setState(() => _isSpeaking = false);
      } catch (e) {
        print('❌❌❌ TTS ERROR: $e');
        if (mounted) setState(() => _isSpeaking = false);
        _showSnackBar('خطأ في القراءة الصوتية', isError: true);
      }
    }
  }

  /// استخدام Google TTS كبديل
  Future<void> _speakWithGoogleTTS(String text) async {
    try {
      // تقصير النص إذا كان طويلاً جداً
      final shortText = text.length > 200 ? text.substring(0, 200) : text;
      final encodedText = Uri.encodeComponent(shortText);
      final url =
          'https://translate.google.com/translate_tts?ie=UTF-8&q=$encodedText&tl=ar&client=tw-ob';

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Google TTS error: $e');
      if (mounted) {
        setState(() => _isSpeaking = false);
        _showSnackBar('خدمة القراءة الصوتية غير متاحة حالياً', isError: true);
      }
    }
  }

  /// تحضير النص للقراءة الصوتية
  String _prepareTextForSpeech() {
    if (_currentItemDetails == null) return '';

    final item = _currentItemDetails!;
    final StringBuffer textBuffer = StringBuffer();

    // إضافة العنوان
    textBuffer.writeln(item.title);
    textBuffer.writeln();

    // إضافة الوصف
    if (item.description.isNotEmpty) {
      textBuffer.writeln(item.description);
    }

    return textBuffer.toString();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ═══════════════════ وظائف الخريطة ═══════════════════════════════════════════
  // ═══════════════════════════════════════════════════════════════════════════

  // الإحداثيات الافتراضية لصنعاء القديمة (باب اليمن)
  static const double _defaultLatitude = 15.3547;
  static const double _defaultLongitude = 44.2066;

  /// الحصول على الإحداثيات (من widget أو من item أو الافتراضية)
  double _getLatitude(ContentDetails item) {
    // أولوية: widget.latitude > item.latitude > default
    return widget.latitude ?? item.latitude ?? _defaultLatitude;
  }

  double _getLongitude(ContentDetails item) {
    // أولوية: widget.longitude > item.longitude > default
    return widget.longitude ?? item.longitude ?? _defaultLongitude;
  }

  bool _hasRealCoordinates(ContentDetails item) {
    // إحداثيات حقيقية إذا كانت موجودة في widget أو item
    return (widget.latitude != null && widget.longitude != null) ||
        (item.latitude != null && item.longitude != null);
  }

  /// عرض خيارات فتح الخريطة (داخل التطبيق أو خارجياً)
  void _showMapOptions(ContentDetails item) {
    final bool hasCoordinates = _hasRealCoordinates(item);
    final double lat = _getLatitude(item);
    final double lng = _getLongitude(item);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // العنوان
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _primaryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.map, color: _primaryGold, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'عرض الموقع على الخريطة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'اختر طريقة عرض موقع "${item.title}"',
              style: const TextStyle(color: _textSecondary, fontSize: 14),
            ),
            // تنبيه إذا كانت الإحداثيات افتراضية
            if (!hasCoordinates) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.orange[700], size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'سيتم عرض موقع تقريبي لصنعاء القديمة',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            // الخيار الأول: فتح Google Maps خارجياً (الافتراضي)
            _buildMapOptionCard(
              icon: Icons.open_in_new,
              title: 'فتح في Google Maps',
              subtitle: hasCoordinates
                  ? 'فتح التطبيق الخارجي للحصول على الاتجاهات'
                  : 'عرض موقع صنعاء القديمة التقريبي',
              isRecommended: true,
              onTap: () {
                Navigator.pop(context);
                _openExternalMap(lat, lng);
              },
            ),
            const SizedBox(height: 12),
            // الخيار الثاني: فتح داخل التطبيق
            _buildMapOptionCard(
              icon: Icons.map_outlined,
              title: 'عرض داخل التطبيق',
              subtitle: hasCoordinates
                  ? 'عرض الموقع على خريطة مدمجة'
                  : 'عرض موقع صنعاء القديمة التقريبي',
              onTap: () {
                Navigator.pop(context);
                _openInAppMapWithCoords(item, lat, lng, hasCoordinates);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// بناء بطاقة خيار الخريطة
  Widget _buildMapOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isRecommended = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isRecommended ? _primaryGold.withOpacity(0.1) : _surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRecommended ? _primaryGold : Colors.grey.shade300,
              width: isRecommended ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isRecommended ? _primaryGold : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isRecommended ? Colors.white : _textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isRecommended ? _primaryGold : _textPrimary,
                          ),
                        ),
                        if (isRecommended) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _primaryGold,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'موصى به',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isRecommended ? _primaryGold : Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// فتح الخريطة خارجياً في تطبيق Google Maps
  void _openExternalMap(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        _showSnackBar('جاري فتح Google Maps... 🗺️', icon: Icons.map);
      } else {
        _showSnackBar('لا يمكن فتح تطبيق الخرائط', isError: true);
      }
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء فتح الخريطة', isError: true);
      debugPrint('Error opening map: $e');
    }
  }

  /// فتح الخريطة داخل التطبيق في صفحة منفصلة
  void _openInAppMap(ContentDetails item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenMapPage(
          title: item.title,
          latitude: item.latitude!,
          longitude: item.longitude!,
          address: item.address,
        ),
      ),
    );
  }

  /// فتح الخريطة داخل التطبيق مع إحداثيات محددة
  void _openInAppMapWithCoords(
      ContentDetails item, double lat, double lng, bool hasRealCoordinates) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenMapPage(
          title: item.title,
          latitude: lat,
          longitude: lng,
          address: item.address,
          isApproximateLocation: !hasRealCoordinates,
        ),
      ),
    );
  }

  /// الدالة القديمة للتوافق مع الكود الموجود
  void _openLocationOnMap(double? latitude, double? longitude) async {
    if (latitude == null || longitude == null) {
      _showSnackBar('لا توجد إحداثيات متاحة لهذا المعلم', isError: true);
      return;
    }
    _openExternalMap(latitude, longitude);
  }

  void _navigateToAR() {
    if (_currentItemDetails == null) {
      _showSnackBar('الرجاء الانتظار حتى يتم تحميل البيانات', isError: true);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ARViewScreen(
          modelUrl: _currentItemDetails!.imageUrl,
          title: _currentItemDetails!.title,
        ),
      ),
    );
  }

  void _navigateToAssistant() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SmartAssistantScreen()),
    );
  }

  void _showSnackBar(String message, {IconData? icon, bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
            ],
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red[700] : _primaryGold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ═══════════════════ وظائف التقييم ═══════════════════════════════════════
  // ═══════════════════════════════════════════════════════════════════════════

  void _showRatingDialog(BuildContext context) {
    int? selectedRating;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.star, color: _primaryGold),
              SizedBox(width: 10),
              Text('تقييم المعلم', style: TextStyle(color: _textPrimary)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'شاركنا رأيك حول هذا المعلم التاريخي',
                  style: TextStyle(color: _textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                StatefulBuilder(
                  builder: (context, setState) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < (selectedRating ?? 0)
                                ? Icons.star
                                : Icons.star_border,
                            color: _primaryGold,
                            size: 36,
                          ),
                          onPressed: () =>
                              setState(() => selectedRating = index + 1),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: commentController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: 'ملاحظاتك (اختياري)',
                    hintText: 'اكتب ملاحظاتك هنا...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: _primaryGold, width: 2),
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
              child:
                  const Text('إلغاء', style: TextStyle(color: _textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedRating == null) {
                  _showSnackBar('الرجاء اختيار تقييم', isError: true);
                  return;
                }
                Navigator.pop(context);
                _submitFeedback(selectedRating!, commentController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGold,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('إرسال', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _submitFeedback(int rating, String comment) async {
    try {
      final String? userId = await AuthService.getUserId();
      final String? authToken = await AuthService.getAuthToken();

      if (authToken == null || userId == null) {
        _showSnackBar('الرجاء تسجيل الدخول أولاً لإضافة تقييم', isError: true);
        return;
      }

      await FeedbackService.createFeedback(
        userId,
        widget.contentId,
        rating,
        comment.isEmpty ? null : comment,
      );

      _showSnackBar('تم إرسال تقييمك بنجاح! ⭐', icon: Icons.check_circle);
    } catch (e) {
      _showSnackBar('فشل إرسال التقييم: ${e.toString()}', isError: true);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ═══════════════════ بناء الواجهة الرئيسية ═══════════════════════════════
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: FutureBuilder<List<ContentDetails>>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final item = snapshot.data!.first;
          _currentItemDetails = item;

          return _buildMainContent(item);
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ═══════════════════ حالات التحميل والخطأ ═══════════════════════════════
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _primaryGold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: _primaryGold,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'جاري تحميل التفاصيل...',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.error_outline, color: Colors.red[400], size: 48),
            ),
            const SizedBox(height: 24),
            const Text(
              'حدث خطأ في تحميل البيانات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: _textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _detailsFuture = ContentDetailsService.fetchContentDetails(
                      widget.contentId);
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGold,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _primaryGold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.info_outline, color: _primaryGold, size: 48),
          ),
          const SizedBox(height: 24),
          const Text(
            'لا توجد تفاصيل لهذا المعلم',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ═══════════════════ المحتوى الرئيسي (CustomScrollView) ═══════════════════
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMainContent(ContentDetails item) {
    final screenHeight = MediaQuery.of(context).size.height;
    final String resolvedImageUrl =
        (item.imageUrl != null && item.imageUrl!.isNotEmpty)
            ? _resolveImageUrl(item.imageUrl!)
            : defaultImages[0];

    return CustomScrollView(
      slivers: [
        // ═══════════════════ 1️⃣ Hero Section ═══════════════════
        _buildHeroSection(item, resolvedImageUrl, screenHeight),

        // ═══════════════════ 2️⃣ Info Bar ═══════════════════
        SliverToBoxAdapter(child: _buildInfoBar(item)),

        // ═══════════════════ 3️⃣ Article Content ═══════════════════
        SliverToBoxAdapter(child: _buildArticleContent(item)),

        // ═══════════════════ 4️⃣ Tabs Section ═══════════════════
        SliverToBoxAdapter(child: _buildTabsSection(item)),

        // ═══════════════════ 5️⃣ Quick Facts ═══════════════════
        SliverToBoxAdapter(child: _buildQuickFacts()),

        // ═══════════════════ 6️⃣ Need Help / AI Section ═══════════════════
        SliverToBoxAdapter(child: _buildNeedHelpSection()),

        // ═══════════════════ 7️⃣ Footer ═══════════════════
        SliverToBoxAdapter(child: _buildFooter()),

        // مساحة إضافية
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ═══════════════════ 1️⃣ Hero Section ═══════════════════════════════════════
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeroSection(
      ContentDetails item, String imageUrl, double screenHeight) {
    final bool isNetworkImage = imageUrl.startsWith('http');
    final readTime = _calculateReadTime(item.description);

    return SliverAppBar(
      expandedHeight: screenHeight * 0.55,
      pinned: true,
      stretch: true,
      backgroundColor: _darkCard,
      systemOverlayStyle: SystemUiOverlayStyle.light,

      // زر الرجوع
      leading: _buildHeroIconButton(
        icon: Icons.arrow_back_ios_new,
        onPressed: () => Navigator.pop(context),
      ),

      // أزرار الـ Header
      actions: [
        _buildHeroIconButton(
            icon: Icons.share_outlined, onPressed: _shareContent),
        _buildHeroIconButton(
          icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          onPressed: _toggleBookmark,
          isActive: _isBookmarked,
        ),
        const SizedBox(width: 8),
      ],

      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // الصورة الخلفية
            isNetworkImage
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: _darkCard,
                        child: const Center(
                          child: CircularProgressIndicator(color: _primaryGold),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) =>
                        Image.asset(defaultImages[0], fit: BoxFit.cover),
                  )
                : Image.asset(imageUrl, fit: BoxFit.cover),

            // التدرج اللوني
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
            ),

            // محتوى الـ Hero
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildBadge('العمارة', Icons.architecture),
                      _buildBadge('القرن السادس عشر', Icons.history),
                      _buildBadge(readTime, Icons.schedule),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // عنوان المعلم
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      shadows: [
                        Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 8,
                            color: Colors.black45),
                      ],
                    ),
                  ),

                  // العنوان الفرعي
                  if (item.address != null && item.address!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            item.address!,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),

                  // أزرار التفاعل داخل الـ Hero
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildHeroActionButton(
                        icon: _isSpeaking ? Icons.stop : Icons.headphones,
                        label: _isSpeaking ? 'إيقاف' : 'استماع',
                        onPressed: _toggleSpeech,
                        isActive: _isSpeaking,
                      ),
                      _buildHeroActionButton(
                        icon: Icons.view_in_ar,
                        label: 'AR / VR',
                        onPressed: _navigateToAR,
                      ),
                      _buildHeroActionButton(
                        icon: Icons.map_outlined,
                        label: 'الخريطة',
                        onPressed: () => _showMapOptions(item),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.black.withOpacity(0.4),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: IconButton(
        icon:
            Icon(icon, color: isActive ? _primaryGold : Colors.white, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _primaryGold.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? _primaryGold : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isActive ? _primaryGold : Colors.white30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ═══════════════════ 2️⃣ Info Bar ═══════════════════════════════════════════
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildInfoBar(ContentDetails item) {
    final readTime = _calculateReadTime(item.description);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _darkCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(Icons.update, 'آخر تحديث', 'اليوم'),
          _buildInfoDivider(),
          _buildInfoItem(Icons.schedule, 'وقت القراءة', readTime),
          _buildInfoDivider(),
          IconButton(
            onPressed: _shareContent,
            icon: const Icon(Icons.ios_share, color: Colors.white70, size: 22),
            tooltip: 'تصدير',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _primaryGold, size: 20),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white24,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ═══════════════════ 3️⃣ Article Content ═══════════════════════════════════
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildArticleContent(ContentDetails item) {
    final paragraphs =
        item.description.split('\n').where((p) => p.trim().isNotEmpty).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.article_outlined,
                    color: _primaryGold, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'عن المعلم',
                style: TextStyle(
                  fontSize: 22,
                  color: _textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // محتوى الوصف
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: paragraphs.isEmpty
                  ? [
                      Text(
                        item.description,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          fontSize: 16,
                          color: _textPrimary,
                          height: 1.9,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ]
                  : paragraphs.map((paragraph) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          paragraph.trim(),
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontSize: 16,
                            color: _textPrimary,
                            height: 1.9,
                            letterSpacing: 0.3,
                          ),
                        ),
                      );
                    }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ═══════════════════ 4️⃣ Tabs Section ═══════════════════════════════════════
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTabsSection(ContentDetails item) {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      child: Column(
        children: [
          // TabBar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: _primaryGold,
                borderRadius: BorderRadius.circular(14),
              ),
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: _textSecondary,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'التاريخ'),
                Tab(text: 'الموقع'),
                Tab(text: 'معالم مشابهة'),
              ],
            ),
          ),

          // TabBarView
          SizedBox(
            height: 420,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTimelineTab(),
                _buildMapTab(item),
                _buildRelatedTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ═══════════════════ Timeline Tab ═══════════════════════════════════════════
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTimelineTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _timelineData.length,
        itemBuilder: (context, index) {
          final event = _timelineData[index];
          final isLast = index == _timelineData.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الخط الزمني العمودي
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_primaryGold, _primaryGoldDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _primaryGold.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.circle,
                          color: Colors.white, size: 10),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 3,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _primaryGold,
                                _primaryGold.withOpacity(0.3)
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                // المحتوى
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _primaryGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            event['period']!,
                            style: const TextStyle(
                              color: _primaryGold,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          event['title']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          event['description']!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: _textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ═══════════════════ Map Tab ═══════════════════════════════════════════════
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMapTab(ContentDetails item) {
    if (item.latitude == null || item.longitude == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.location_off, size: 48, color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            const Text(
              'لا تتوفر بيانات الموقع لهذا المعلم',
              style: TextStyle(color: _textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    final LatLng location = LatLng(item.latitude!, item.longitude!);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GoogleMap(
                initialCameraPosition:
                    CameraPosition(target: location, zoom: 15),
                markers: {
                  Marker(
                    markerId: const MarkerId('landmark_location'),
                    position: location,
                    infoWindow: InfoWindow(title: item.title),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueOrange),
                  ),
                },
                onMapCreated: (controller) => _mapController = controller,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
                mapToolbarEnabled: false,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  _openLocationOnMap(item.latitude, item.longitude),
              icon: const Icon(Icons.open_in_new),
              label: const Text('فتح في Google Maps'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ═══════════════════ Related Tab ═══════════════════════════════════════════
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildRelatedTab() {
    final List<Map<String, String>> relatedLandmarks = [
      {'name': 'دار الحجر', 'image': 'assets/images/dar_alhajar1.jpg'},
      {'name': 'قصر غمدان', 'image': 'assets/images/dar_alhajar2.jpg'},
      {'name': 'سد مأرب', 'image': 'assets/images/dar_alhajar3.jpg'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: relatedLandmarks.length,
        itemBuilder: (context, index) {
          final landmark = relatedLandmarks[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          landmark['image']!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: _surfaceColor,
                            child:
                                const Icon(Icons.image, color: _textSecondary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              landmark['name']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'معلم تاريخي',
                              style: TextStyle(
                                  fontSize: 13, color: _textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _primaryGold.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_ios,
                            color: _primaryGold, size: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ═══════════════════ 5️⃣ Quick Facts ═══════════════════════════════════════
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildQuickFacts() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _darkCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.fact_check, color: _primaryGold, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'حقائق سريعة',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // البيانات
          ...List.generate(_quickFacts.length, (index) {
            final fact = _quickFacts[index];
            final isLast = index == _quickFacts.length - 1;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Icon(fact['icon'] as IconData,
                          color: _primaryGold, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        fact['label'] as String,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 14),
                      ),
                      const Spacer(),
                      Text(
                        fact['value'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(color: Colors.white.withOpacity(0.1), height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ═══════════════════ 6️⃣ Need Help Section ═══════════════════════════════════
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildNeedHelpSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _primaryGold.withOpacity(0.15),
            _primaryGold.withOpacity(0.05)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryGold.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // أيقونة AI
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryGold.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, color: _primaryGold, size: 36),
          ),
          const SizedBox(height: 16),

          // العنوان
          const Text(
            'هل تحتاج مساعدة؟',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // الوصف
          const Text(
            'اسأل المساعد الذكي للحصول على مزيد من التفاصيل أو الترجمة أو معلومات ذات صلة.',
            style: TextStyle(color: _textSecondary, fontSize: 14, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // زر المساعد
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _navigateToAssistant,
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text(
                'اسأل المساعد الذكي',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 4,
                shadowColor: _primaryGold.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ═══════════════════ 7️⃣ Footer ═══════════════════════════════════════════
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          // خط فاصل
          Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.shade300,
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // أزرار الفوتر
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFooterButton(
                  Icons.star_border, 'تقييم', () => _showRatingDialog(context)),
              const SizedBox(width: 24),
              _buildFooterButton(Icons.share_outlined, 'مشاركة', _shareContent),
              const SizedBox(width: 24),
              _buildFooterButton(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                'حفظ',
                _toggleBookmark,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // النص
          Text(
            'التراث اليمني الذكي © 2024',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton(
      IconData icon, String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(icon, color: _primaryGold, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(color: _textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ═══════════════════ صفحة الخريطة الكاملة ═══════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════

class _FullScreenMapPage extends StatefulWidget {
  final String title;
  final double latitude;
  final double longitude;
  final String? address;
  final bool isApproximateLocation;

  const _FullScreenMapPage({
    required this.title,
    required this.latitude,
    required this.longitude,
    this.address,
    this.isApproximateLocation = false,
  });

  @override
  State<_FullScreenMapPage> createState() => _FullScreenMapPageState();
}

class _FullScreenMapPageState extends State<_FullScreenMapPage> {
  bool _isSatellite = false;
  int _zoomLevel = 15;

  void _openExternalMap() async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openDirections() async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${widget.latitude},${widget.longitude}';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _getStaticMapUrl() {
    final mapType = _isSatellite ? 'satellite' : 'roadmap';
    return 'https://maps.googleapis.com/maps/api/staticmap'
        '?center=${widget.latitude},${widget.longitude}'
        '&zoom=$_zoomLevel'
        '&size=600x400'
        '&maptype=$mapType'
        '&markers=color:orange%7C${widget.latitude},${widget.longitude}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _darkCard,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'موقع المعلم',
              style:
                  TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: _openExternalMap,
            tooltip: 'فتح في Google Maps',
          ),
        ],
      ),
      body: Column(
        children: [
          // تنبيه الموقع التقريبي
          if (widget.isApproximateLocation)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.orange.withOpacity(0.15),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'هذا موقع تقريبي لصنعاء القديمة - اضغط على "فتح في Google Maps" للموقع الدقيق',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // محتوى الخريطة
          Expanded(
            child: Stack(
              children: [
                // خلفية مع أيقونة الخريطة
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _darkCard.withOpacity(0.1),
                        _primaryGold.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // أيقونة الموقع الكبيرة
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: _primaryGold.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on,
                            size: 60,
                            color: _primaryGold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _darkCard,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${widget.latitude.toStringAsFixed(4)}, ${widget.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.isApproximateLocation
                              ? 'صنعاء القديمة - موقع تقريبي'
                              : 'الموقع الدقيق',
                          style: TextStyle(
                            fontSize: 14,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // بطاقة الإجراءات
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // معلومات الموقع
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _primaryGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.place,
                          color: _primaryGold,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'موقع المعلم',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'اضغط على الأزرار أدناه لعرض الموقع أو الحصول على الاتجاهات',
                              style: TextStyle(
                                fontSize: 12,
                                color: _textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // أزرار الإجراءات
                  Row(
                    children: [
                      // زر فتح الخريطة
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _openExternalMap,
                          icon: const Icon(Icons.map, size: 20),
                          label: const Text('فتح الخريطة'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryGold,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // زر الاتجاهات
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _openDirections,
                          icon: const Icon(Icons.directions, size: 20),
                          label: const Text('الاتجاهات'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _darkCard,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // زر مشاركة الموقع
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final shareText =
                            '${widget.title}\n\nالموقع: https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}';
                        Share.share(shareText);
                      },
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('مشاركة الموقع'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primaryGold,
                        side: const BorderSide(color: _primaryGold),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
