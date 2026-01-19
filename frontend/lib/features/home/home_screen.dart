import 'package:flutter/material.dart';
import 'package:frontend/features/assistant/smart_assistant_screen.dart';
import 'package:frontend/features/Kingdoms/schedule2_screen.dart';
import 'package:frontend/features/landmarks/schedule_screen.dart';
import '../Antiquities/AntiquitiesScreen.dart';
import '../ExtinctSites/ExtinctSitesScreen.dart';
import '../search/search_screen.dart';
import '../../models/content_model.dart';
import '../../services/content_service.dart';
import '../../services/content_details_service.dart';
import '../Landmarks/details/content_details_screen.dart';
import '../../core/utils/url_helper.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color primary = const Color(0xFFD4A017);
  final Color landmarksColor = const Color(0xFF2E7D32);
  final Color kingdomsColor = const Color(0xFFB8860B);
  final Color antiquitiesColor = const Color(0xFF696969);
  final Color extinctColor = const Color(0xFF8B4513);

  final List<String> sliderImages = [
    "assets/images/place1.jpg",
    "assets/images/bab_yemen1.jpg",
    "assets/images/place2.jpg",
  ];

  int _currentPage = 0;

  // البيانات الديناميكية من Backend - تنويع موسوعي
  bool _isLoading = true;
  String? _errorMessage;

  Content? _landmarkContent;
  Content? _kingdomContent;
  Content? _antiquityContent;
  Content? _extinctSiteContent;

  // خريطة لتخزين روابط الصور من تفاصيل المحتوى
  Map<String, String?> _contentImages = {};

  @override
  void initState() {
    super.initState();
    _loadEncyclopediaContent();
  }

  // جلب محتوى موسوعي متنوع من جميع الأقسام
  Future<void> _loadEncyclopediaContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // جلب معلم تاريخي (استخدام الاسم الإنجليزي كما في قاعدة البيانات)
      final landmarks = await ContentService.fetchContents(type: 'Landmarks');
      _landmarkContent = landmarks.isNotEmpty ? landmarks.first : null;
      if (_landmarkContent != null) {
        print('📍 معلم تاريخي: ${_landmarkContent!.title}');
        // جلب صورة من التفاصيل
        await _loadContentImage(_landmarkContent!.id);
      }

      // جلب مملكة يمنية قديمة
      final kingdoms = await ContentService.fetchContents(type: 'Kingdoms');
      _kingdomContent = kingdoms.isNotEmpty ? kingdoms.first : null;
      if (_kingdomContent != null) {
        print('👑 مملكة: ${_kingdomContent!.title}');
        await _loadContentImage(_kingdomContent!.id);
      }

      // جلب أثر أو موقع أثري
      final antiquities =
          await ContentService.fetchContents(type: 'Antiquities');
      _antiquityContent = antiquities.isNotEmpty ? antiquities.first : null;
      if (_antiquityContent != null) {
        print('🏺 أثر: ${_antiquityContent!.title}');
        await _loadContentImage(_antiquityContent!.id);
      }

      // جلب موقع مندثر
      final extinctSites =
          await ContentService.fetchContents(type: 'Extinct Sites');
      _extinctSiteContent = extinctSites.isNotEmpty ? extinctSites.first : null;
      if (_extinctSiteContent != null) {
        print('🗺️ موقع مندثر: ${_extinctSiteContent!.title}');
        await _loadContentImage(_extinctSiteContent!.id);
      }
    } catch (e) {
      debugPrint('❌ Error loading encyclopedia content: $e');
      _errorMessage = 'حدث خطأ أثناء تحميل المحتوى';
    }

    setState(() => _isLoading = false);
  }

  // جلب صورة المحتوى من التفاصيل
  Future<void> _loadContentImage(String contentId) async {
    try {
      final details =
          await ContentDetailsService.fetchContentDetails(contentId);
      if (details.isNotEmpty) {
        // البحث عن أول تفاصيل بها صورة
        for (var detail in details) {
          if (detail.imageUrl != null && detail.imageUrl!.isNotEmpty) {
            // تصحيح رابط الصورة يدوياً للتأكد
            String fixedUrl = UrlHelper.fixImageUrl(detail.imageUrl!);
            _contentImages[contentId] = fixedUrl;
            print('🖼️ تم جلب صورة للمحتوى $contentId');
            print('   📥 الرابط الأصلي: ${detail.imageUrl}');
            print('   ✅ الرابط المصحح: $fixedUrl');
            break;
          }
        }
      }
    } catch (e) {
      print('⚠️ خطأ في جلب صورة المحتوى $contentId: $e');
    }
  }

  // ================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: primary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              '𐩱𐩡𐩣𐩬',
              style: const TextStyle(
                fontFamily: 'OldSouthArabian',
                fontSize: 28,
                color: Color(0xFFD4A017),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'الموسوعة الذكية في تاريخ اليمن القديم',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            )
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: primary),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const SearchScreen(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildHomeContent(),
    );
  }

  // ================================================================
  Widget _buildHomeContent() {
    return RefreshIndicator(
      color: primary,
      onRefresh: _loadEncyclopediaContent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _imageSlider(),
            const SizedBox(height: 20),

            // رسالة موسوعية تعريفية
            _buildIntroSection(),
            const SizedBox(height: 25),

            // الأقسام الرئيسية في الأعلى
            _buildMainSections(),
            const SizedBox(height: 30),

            // المحتوى الموسوعي المتنوع
            _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState()
                    : _buildEncyclopediaContent(),

            const SizedBox(height: 24),

            // زر Call To Action لاستكشاف الموسوعة
            _buildExploreButton(),

            const SizedBox(height: 30),

            // شريط التقنيات الذكية (AI & AR) في الأسفل
            _buildSmartTechBanner(),
            const SizedBox(height: 30),

            // Footer الموسوعي
            _buildEncyclopediaFooter(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ============ الرسالة الموسوعية التعريفية ============
  Widget _buildIntroSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withOpacity(0.08),
            primary.withOpacity(0.03),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // أيقونة الموسوعة
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              color: primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),

          // العنوان
          Text(
            'مرحباً بك في الموسوعة الذكية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // الوصف
          Text(
            'من هنا تبدأ رحلتك في استكشاف حضارات اليمن القديم،\n'
            'من الممالك العظيمة إلى المعالم والآثار\n'
            'باستخدام أحدث تقنيات الذكاء الاصطناعي والواقع المعزز.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // شارات التقنيات
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTechBadge(
                  Icons.smart_toy_outlined, 'AI', const Color(0xFF1976D2)),
              const SizedBox(width: 12),
              _buildTechBadge(
                  Icons.view_in_ar_outlined, 'AR', const Color(0xFF7B1FA2)),
              const SizedBox(width: 12),
              _buildTechBadge(Icons.menu_book_outlined, 'موسوعة', primary),
            ],
          ),
        ],
      ),
    );
  }

  /// بناء شارة تقنية صغيرة
  Widget _buildTechBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// بناء شارة تقنية مصغرة (للأقسام الموسوعية)
  Widget _buildMiniTechBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ============ زر استكشاف الموسوعة ============
  Widget _buildExploreButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          // التمرير لأعلى لعرض الأقسام أو فتح قائمة الأقسام
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) => _buildSectionsSheet(),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: primary.withOpacity(0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.explore_rounded, size: 24),
            SizedBox(width: 10),
            Text(
              'استكشف الموسوعة كاملة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ورقة الأقسام السفلية
  Widget _buildSectionsSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // المقبض
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // العنوان
          Text(
            'اختر القسم للاستكشاف',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
          const SizedBox(height: 20),

          // الأقسام
          Row(
            children: [
              Expanded(
                child: _buildSheetSection(
                  icon: Icons.account_balance,
                  label: 'الممالك',
                  color: kingdomsColor,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const KingdomsScreen()));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSheetSection(
                  icon: Icons.mosque,
                  label: 'المعالم',
                  color: landmarksColor,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LandmarksScreen()));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSheetSection(
                  icon: Icons.architecture,
                  label: 'الآثار',
                  color: antiquitiesColor,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AntiquitiesScreen()));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSheetSection(
                  icon: Icons.location_off,
                  label: 'المواقع المندثرة',
                  color: extinctColor,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ExtinctSitesScreen()));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSheetSection({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ============ شريط التقنيات الذكية ============
  Widget _buildSmartTechBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withOpacity(0.1), primary.withOpacity(0.05)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, color: primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'تقنيات ذكية لتجربة استثنائية',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTechCard(
                icon: Icons.smart_toy,
                title: 'الذكاء الاصطناعي',
                subtitle: 'شرح وتحليل ذكي',
                color: const Color(0xFF1976D2),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SmartAssistantScreen(),
                    ),
                  );
                },
              ),
              _buildTechCard(
                icon: Icons.view_in_ar,
                title: 'الواقع المعزز',
                subtitle: 'استكشاف تفاعلي',
                color: const Color(0xFF7B1FA2),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ستتمكن من استخدام الواقع المعزز قريباً'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============ Footer الموسوعي ============
  Widget _buildEncyclopediaFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2D2D2D),
            const Color(0xFF1A1A1A),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // الشعار واسم التطبيق
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '𐩱𐩡𐩣𐩬',
                    style: TextStyle(
                      fontFamily: 'OldSouthArabian',
                      fontSize: 20,
                      color: primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'الموسوعة الذكية',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // خط فاصل
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  primary.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // الوصف
          Text(
            'الموسوعة الذكية لتاريخ اليمن القديم',
            style: TextStyle(
              fontSize: 16,
              color: primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'منصة رقمية تفاعلية تجمع بين التراث اليمني العريق\nوالتقنيات الحديثة (الذكاء الاصطناعي والواقع المعزز)\nلتقديم تجربة موسوعية فريدة ومميزة',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white60,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // الميزات
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFooterFeature(Icons.smart_toy_outlined, 'AI'),
              const SizedBox(width: 24),
              _buildFooterFeature(Icons.view_in_ar_outlined, 'AR'),
              const SizedBox(width: 24),
              _buildFooterFeature(Icons.library_books_outlined, 'موسوعة'),
            ],
          ),

          const SizedBox(height: 24),

          // خط فاصل
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white24,
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // معلومات المشروع
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_outlined, size: 16, color: Colors.white38),
              const SizedBox(width: 8),
              const Text(
                'مشروع أكاديمي بحثي',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '© 2024 - 2026 جميع الحقوق محفوظة',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white30,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// بناء عنصر ميزة في الـ Footer
  Widget _buildFooterFeature(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: primary, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTechCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------- Slider ------------------------
  Widget _imageSlider() {
    return Column(
      children: [
        SizedBox(
          height: 230,
          child: PageView.builder(
            itemCount: sliderImages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (_, index) => _sliderCard(sliderImages[index]),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            sliderImages.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == i ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == i ? primary : Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _sliderCard(String img) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(img, fit: BoxFit.cover),
      ),
    );
  }

  // ---------------- Main Sections Icons -------------------------
  Widget _buildMainSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'الأقسام الرئيسية',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildSectionIcon(
              icon: Icons.account_balance,
              label: 'الممالك',
              color: const Color(0xFFB8860B),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KingdomsScreen()),
                );
              },
            ),
            _buildSectionIcon(
              icon: Icons.mosque,
              label: 'المعالم',
              color: const Color(0xFF2E7D32),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LandmarksScreen()),
                );
              },
            ),
            _buildSectionIcon(
              icon: Icons.architecture,
              label: 'الآثار',
              color: const Color(0xFF696969),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AntiquitiesScreen()),
                );
              },
            ),
            _buildSectionIcon(
              icon: Icons.location_off,
              label: 'المواقع المندثرة',
              color: const Color(0xFF8B4513),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExtinctSitesScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionIcon({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ============ حالة التحميل ============
  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Column(
          children: [
            CircularProgressIndicator(color: primary),
            const SizedBox(height: 16),
            Text(
              'جاري تحميل المحتوى الموسوعي...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ حالة الخطأ ============
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'حدث خطأ غير متوقع',
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadEncyclopediaContent,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ المحتوى الموسوعي الرئيسي ============
  Widget _buildEncyclopediaContent() {
    bool hasContent = _landmarkContent != null ||
        _kingdomContent != null ||
        _antiquityContent != null ||
        _extinctSiteContent != null;

    if (!hasContent) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.library_books, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'لا يوجد محتوى متاح حالياً',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'يرجى المحاولة مرة أخرى لاحقاً',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // عنوان القسم الموسوعي
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'المحتوى الموسوعي',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.menu_book, color: primary, size: 28),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'اكتشف تنوع التراث اليمني عبر العصور',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 24),

        // أقسام المحتوى الموسوعي
        if (_landmarkContent != null)
          _buildEncyclopediaSection(
            title: '🏛️ المعالم التاريخية',
            subtitle: 'مواقع أثرية شاهدة على حضارة عريقة',
            content: _landmarkContent!,
            color: landmarksColor,
            icon: Icons.mosque,
            sectionScreen: const LandmarksScreen(),
            sectionLabel: 'المعالم',
            supportsAI: true,
            supportsAR: true,
          ),

        if (_kingdomContent != null)
          _buildEncyclopediaSection(
            title: '👑 الممالك اليمنية القديمة',
            subtitle: 'حضارات وممالك سادت ثم بادت',
            content: _kingdomContent!,
            color: kingdomsColor,
            icon: Icons.account_balance,
            sectionScreen: const KingdomsScreen(),
            sectionLabel: 'الممالك',
            supportsAI: true,
            supportsAR: false,
          ),

        if (_antiquityContent != null)
          _buildEncyclopediaSection(
            title: '🏺 الآثار والمواقع الأثرية',
            subtitle: 'شواهد تاريخية من عمق الحضارة',
            content: _antiquityContent!,
            color: antiquitiesColor,
            icon: Icons.architecture,
            sectionScreen: const AntiquitiesScreen(),
            sectionLabel: 'الآثار',
            supportsAI: true,
            supportsAR: true,
          ),

        if (_extinctSiteContent != null)
          _buildEncyclopediaSection(
            title: '🗺️ المواقع المندثرة',
            subtitle: 'أماكن اندثرت لكن ذكراها باقية',
            content: _extinctSiteContent!,
            color: extinctColor,
            icon: Icons.location_off,
            sectionScreen: const ExtinctSitesScreen(),
            sectionLabel: 'المواقع المندثرة',
            supportsAI: true,
            supportsAR: false,
          ),
      ],
    );
  }

  // ============ بطاقة قسم موسوعي ============
  Widget _buildEncyclopediaSection({
    required String title,
    required String subtitle,
    required Content content,
    required Color color,
    required IconData icon,
    required Widget sectionScreen,
    required String sectionLabel,
    bool supportsAI = false,
    bool supportsAR = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // رأس القسم
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(icon, color: color, size: 24),
                  ],
                ),
                const SizedBox(height: 8),
                // شارات التقنيات الذكية
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const Spacer(),
                    if (supportsAI)
                      _buildMiniTechBadge(Icons.smart_toy_outlined, 'AI',
                          const Color(0xFF1976D2)),
                    if (supportsAI && supportsAR) const SizedBox(width: 6),
                    if (supportsAR)
                      _buildMiniTechBadge(Icons.view_in_ar_outlined, 'AR',
                          const Color(0xFF7B1FA2)),
                  ],
                ),
              ],
            ),
          ),

          // محتوى البطاقة
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ContentDetailsScreen(
                    contentId: content.id,
                    latitude: content.latitude,
                    longitude: content.longitude,
                    address: content.address,
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // الصورة - جلبها من خريطة الصور (من تفاصيل المحتوى)
                Builder(
                  builder: (context) {
                    final imageUrl = _contentImages[content.id];
                    print('🖼️ صورة المحتوى ${content.title}: $imageUrl');

                    if (imageUrl != null && imageUrl.isNotEmpty) {
                      return ClipRRect(
                        borderRadius: BorderRadius.zero,
                        child: Image.network(
                          imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: color,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('❌ خطأ في تحميل الصورة: $error');
                            print('🔗 رابط الصورة: $imageUrl');
                            return Container(
                              height: 200,
                              color: Colors.grey[300],
                              child:
                                  Icon(icon, size: 80, color: Colors.grey[400]),
                            );
                          },
                        ),
                      );
                    } else {
                      return Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: Icon(icon, size: 80, color: Colors.grey[400]),
                      );
                    }
                  },
                ),

                // المعلومات
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        content.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        content.description.length > 150
                            ? '${content.description.substring(0, 150)}...'
                            : content.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      if (content.address != null &&
                          content.address!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                content.address!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: color,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.location_on, size: 16, color: color),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_back,
                                  color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'اقرأ المزيد',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // رابط اكتشف المزيد
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => sectionScreen),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(top: BorderSide(color: color.withOpacity(0.1))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'اكتشف المزيد من $sectionLabel',
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.explore_outlined, color: color, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Drawer UI -------------------------
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, primary.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.book, size: 60, color: Colors.white),
                const SizedBox(height: 10),
                const Text(
                  "القائمة الرئيسية",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.home,
            label: "الرئيسية",
            onTap: () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            icon: Icons.mic,
            label: "المساعد الذكي",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SmartAssistantScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.account_balance,
            label: "الممالك",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const KingdomsScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.mosque,
            label: "المعالم",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LandmarksScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.architecture,
            label: "الآثار",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AntiquitiesScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.location_off,
            label: "المواقع المندثرة",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ExtinctSitesScreen()));
            },
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.favorite,
            label: "المفضلة",
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/favorites');
            },
          ),
          _buildDrawerItem(
            icon: Icons.person,
            label: "الملف الشخصي",
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: primary),
      title: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}
