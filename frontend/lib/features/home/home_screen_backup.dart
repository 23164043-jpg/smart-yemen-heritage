// ignore_for_file: unused_field, unused_local_variable, undefined_identifier, duplicate_definition, unused_import
// هذا ملف نسخة احتياطية - يحتوي على أخطاء ولا يُستخدم في التطبيق

import 'package:flutter/material.dart';
import 'package:frontend/features/assistant/smart_assistant_screen.dart';
import 'package:frontend/features/Kingdoms/schedule2_screen.dart';
import 'package:frontend/features/landmarks/schedule_screen.dart';
import '../Antiquities/AntiquitiesScreen.dart';
import '../ExtinctSites/ExtinctSitesScreen.dart';
import '../search/search_screen.dart';
import '../ar/ar_view_screen.dart';
import '../../models/content_model.dart';
import '../../services/content_service.dart';
import '../Landmarks/details/content_details_screen.dart';

// تعريف المتغيرات المفقودة
final List<Map<String, String>> allPlaces = [];
final List<String> categories = ['معالم', 'ممالك', 'آثار', 'مواقع منقرضة'];
int _selectedNavIndex = 0;
int _selectedCategoryIndex = 0;

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

  // البيانات الديناميكية الموسوعية (عدة عناصر من كل نوع)
  bool _isLoading = true;
  List<Content> _landmarks = [];
  List<Content> _kingdoms = [];
  List<Content> _antiquities = [];
  List<Content> _extinctSites = [];

  List<Map<String, String>> filteredPlaces = [];
  final List<String> sliderImages = [
    "assets/images/place1.jpg",
    "assets/images/bab_yemen1.jpg",
    "assets/images/place2.jpg",
  ];

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    filteredPlaces = List.from(allPlaces);
  }

  //-------------- Drawer navigation ----------------
  Widget _buildDrawerItem(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: primary),
      title: Text(label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }

  //-------------- Bottom Navigation ----------------
  void _onNavItemTapped(int index) {
    if (index == 0) {
      setState(() => _selectedNavIndex = 0);
      return;
    }
    if (index == 1) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const SmartAssistantScreen()));
      return;
    }
    if (index == 2) {
      Navigator.pushNamed(context, '/favorites');
      return;
    }
    if (index == 3) {
      Navigator.pushNamed(context, '/profile');
      return;
    }
  }

  //-------------- Category Tap ----------------
  void _onCategorySelected(int index) {
    setState(() => _selectedCategoryIndex = index);

    final categoryName = categories[index];

    if (categoryName == "معالم") {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const LandmarksScreen()));
    } else if (categoryName == "ممالك") {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const KingdomsScreen()));
    } else if (categoryName == "آثار") {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AntiquitiesScreen()));
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
      body: IndexedStack(
        index: _selectedNavIndex,
        children: [
          _buildHomeContent(),
          const SizedBox(),
          const SizedBox(),
          const SizedBox(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        selectedItemColor: primary,
        unselectedItemColor: Colors.black54,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: _onNavItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(
              icon: Icon(Icons.mic), label: "المساعد الذكي"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "المفضلة"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "الملف الشخصي"),
        ],
      ),
    );
  }

  // ================================================================
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _imageSlider(),
          const SizedBox(height: 25),
          _buildCategories(),
          const SizedBox(height: 20),
          _buildPlacesGrid(),
        ],
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

  // ---------------- Categories -------------------------
  Widget _buildCategories() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () => _onCategorySelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primary),
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------- Places Grid -------------------------
  Widget _buildPlacesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredPlaces.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: .78,
      ),
      itemBuilder: (_, index) {
        final place = filteredPlaces[index];
        return GestureDetector(
          onTap: () async {
            try {
              List<Content> allContents = await ContentService.fetchContents();
              Content selected = allContents.firstWhere(
                (c) => c.title == place['title'],
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ContentDetailsScreen(
                    contentId: selected.id,
                    latitude: selected.latitude,
                    longitude: selected.longitude,
                    address: selected.address,
                  ),
                ),
              );
            } catch (_) {}
          },
          child: _placeCard(place),
        );
      },
    );
  }

  Widget _placeCard(Map<String, String> place) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5F3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.07), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(place['image']!,
                height: 110, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(place['title']!,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  place['location']!,
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // ---------------- Drawer UI -------------------------
  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 10),
          children: [
            const SizedBox(height: 10),
            Center(
              child: Text(
                "القائمة الرئيسية",
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: primary),
              ),
            ),
            const Divider(),
            _buildDrawerItem(icon: Icons.home, label: "الرئيسية", onTap: () {}),
            _buildDrawerItem(
                icon: Icons.mic,
                label: "المساعد الذكي",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SmartAssistantScreen()));
                }),
            _buildDrawerItem(
                icon: Icons.account_balance,
                label: "الممالك",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const KingdomsScreen()));
                }),
            _buildDrawerItem(
                icon: Icons.mosque,
                label: "المعالم",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LandmarksScreen()));
                }),
            _buildDrawerItem(
                icon: Icons.architecture,
                label: "الآثار",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AntiquitiesScreen()));
                }),
            _buildDrawerItem(
                icon: Icons.favorite,
                label: "المفضلة",
                onTap: () {
                  Navigator.pushNamed(context, '/favorites');
                }),
            _buildDrawerItem(
                icon: Icons.notifications, label: "الإشعارات", onTap: () {}),
            _buildDrawerItem(
                icon: Icons.support, label: "الدعم والتواصل", onTap: () {}),
            _buildDrawerItem(
                icon: Icons.language, label: "تغيير اللغة", onTap: () {}),
            _buildDrawerItem(
                icon: Icons.dark_mode, label: "الوضع الداكن", onTap: () {}),
            _buildDrawerItem(
                icon: Icons.info,
                label: "حول التطبيق",
                onTap: () {
                  Navigator.pushNamed(context, '/about_app');
                }),
            _buildDrawerItem(
                icon: Icons.policy, label: "سياسة الخصوصية", onTap: () {}),
            _buildDrawerItem(
                icon: Icons.logout, label: "تسجيل الخروج", onTap: () {}),
          ],
        ),
      ),
    );
  }
}
