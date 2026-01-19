import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../favorites/favorites_screen.dart';
import '../assistant/smart_assistant_screen.dart';
import '../profile/profile_screen.dart';

/// شاشة التنقل الرئيسية
/// تستخدم IndexedStack للحفاظ على حالة الصفحات وعدم إعادة بنائها
/// 
/// المنطق المستخدم:
/// - IndexedStack يحتفظ بجميع الصفحات في الذاكرة
/// - عند التنقل، يتم فقط تغيير الـ index المعروض
/// - هذا يمنع فقدان البيانات أو إعادة التحميل عند العودة للصفحة
class MainNavigationScreen extends StatefulWidget {
  final String userName;
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    required this.userName,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  // اللون الأساسي للتطبيق
  static const Color _primaryColor = Color(0xFFD4A017);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  // قائمة الصفحات - تُبنى مرة واحدة فقط
  late final List<Widget> _pages = [
    HomeScreen(userName: widget.userName),
    const FavoritesScreen(),
    const SmartAssistantScreen(),
    const ProfileScreen(),
  ];

  // عناصر شريط التنقل السفلي
  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
    _NavItem(icon: Icons.favorite_rounded, label: 'المفضلة'),
    _NavItem(icon: Icons.smart_toy_rounded, label: 'المساعد'),
    _NavItem(icon: Icons.person_rounded, label: 'حسابي'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// بناء شريط التنقل السفلي بتصميم بسيط وأنيق
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
              (index) => _buildNavItem(index),
            ),
          ),
        ),
      ),
    );
  }

  /// بناء عنصر واحد من شريط التنقل
  Widget _buildNavItem(int index) {
    final isSelected = _currentIndex == index;
    final item = _navItems[index];

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 24,
              color: isSelected ? _primaryColor : Colors.grey[500],
            ),
            // إظهار النص فقط للعنصر المحدد
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                item.label,
                style: TextStyle(
                  color: _primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// كلاس مساعد لتخزين بيانات عناصر التنقل
class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.label,
  });
}
