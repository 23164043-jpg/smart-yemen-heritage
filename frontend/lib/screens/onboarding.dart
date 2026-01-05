import 'package:flutter/material.dart';
import 'signin_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreen1State();
}

class _OnboardingScreen1State extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      'image': 'assets/images/sanaa.jpg',
      'title': 'ابدأ رحلتك الآن',
      'desc':
          'انطلق في رحلة استكشافية عبر الزمن واكتشف عظمة التاريخ اليمني القديم',
    },
    {
      'image': 'assets/images/balqees.jpg',
      'title': 'تعرف على حضارتنا',
      'desc':
          'استكشف أسرار الممالك اليمنية القديمة وتعرف على روعة النقوش والآثار',
    },
    {
      'image': 'assets/images/oldsanaa.jpg',
      'title': 'كن جزءاً من التاريخ',
      'desc': 'ابدأ مغامرتك الآن وشاركنا الحفاظ على تراث اليمن العظيم',
    },
  ];

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    } else {
      // الانتقال إلى صفحة تسجيل الدخول مع حركة أنميشن من اليسار لليمين
      Navigator.of(context).push(_createRouteToSignIn());
    }
  }

  Route _createRouteToSignIn() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SignInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F0E8),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // ✅ الزخرفة العلوية
            _topDecoration(),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    child: _buildPage(
                      image: page['image']!,
                      title: page['title']!,
                      desc: page['desc']!,
                    ),
                  );
                },
              ),
            ),

            // ✅ المؤشرات السفلية
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (index) {
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: _currentPage == index ? 10 : 8,
                    height: _currentPage == index ? 10 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.brown
                          : Colors.brown.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            // ✅ الزر
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD1B38D),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _nextPage,
                child: const Text(
                  'ابدأ الآن',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),
            // ✅ الزخرفة السفلية
            _bottomDecoration(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(
      {required String image, required String title, required String desc}) {
    return Column(
      key: ValueKey(title),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            image,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _sideLine(),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B2F2F),
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(width: 6),
            _sideLine(),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.brown,
              fontFamily: 'Cairo',
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sideLine() {
    return Container(
      width: 20,
      height: 2,
      color: Colors.brown.withOpacity(0.4),
    );
  }

  Widget _topDecoration() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        height: 16,
        child: CustomPaint(
          painter: DottedLinePainter(),
          size: const Size(double.infinity, 16),
        ),
      ),
    );
  }

  Widget _bottomDecoration() {
    return SizedBox(
      height: 16,
      child: CustomPaint(
        painter: DottedLinePainter(),
        size: const Size(double.infinity, 16),
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.withOpacity(0.6)
      ..strokeWidth = 2;
    const dashWidth = 4;
    const dashSpace = 6;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
