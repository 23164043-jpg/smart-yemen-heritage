import 'package:flutter/material.dart';
import 'signin_page.dart'; // صفحة تسجيل الدخول

class OnboardingScreen1 extends StatefulWidget {
  const OnboardingScreen1({super.key});

  @override
  State<OnboardingScreen1> createState() => _OnboardingScreen1State();
}

class _OnboardingScreen1State extends State<OnboardingScreen1> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/sanaa.jpg",
      "title": "ابدأ رحلتك الآن",
      "desc":
          "انطلق في رحلة استكشافية عبر الزمن واكتشف عظمة التاريخ اليمني القديم",
    },
    {
      "image": "assets/images/balqees.jpg",
      "title": "اكتشف الجمال",
      "desc":
          "استمتع بروعة المعالم التاريخية والمناظر الطبيعية الخلابة في اليمن",
    },
    {
      "image": "assets/images/oldsanaa.jpg",
      "title": "كن جزءاً من التاريخ",
      "desc": "ابدأ مغامرتك الآن وشاركنا الحفاظ على تراث اليمن العظيم",
    },
  ];

  @override
  void initState() {
    super.initState();
    _autoScrollPages();
  }

  void _autoScrollPages() {
    Future.delayed(const Duration(seconds: 4), () {
      if (_currentPage < onboardingData.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        _autoScrollPages();
      }
    });
  }

  void _goToSignIn() {
    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 800),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SignInScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5ecde),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // const SizedBox(height: 40),
          // الزخرفة العلوية
          // _topDecoration(),

          const SizedBox(height: 20),

          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: onboardingData.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        onboardingData[index]["image"]!,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 80),
                    Text(
                      onboardingData[index]["title"]!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff3a2f1f),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Text(
                        onboardingData[index]["desc"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xff6b5642),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // المؤشر السفلي (الدوائر)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              onboardingData.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 18 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? const Color(0xffc9a46c)
                      : Colors.brown[200],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // زر ابدأ الآن
          ElevatedButton(
            onPressed: _goToSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffc9a46c),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: const Text(
              "ابدأ الآن",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),

          const SizedBox(height: 30),

          // الزخرفة السفلية
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 50),
          //   child: Image.asset("assets/images/decor_bottom.png"),
          // ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: CustomPaint(
        size: const Size(double.infinity, 20),
        painter: _TicksPainter(),
      ),
    );
  }
}

// ignore: unused_element
Widget _topDecoration() {
  return SizedBox(
    height: 50,
    width: 150,
    child: CustomPaint(
      size: const Size(double.infinity, 20),
      painter: _TicksPainter(),
    ),
  );
}

class _TicksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFB79B73)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final accentPaint = Paint()
      ..color = const Color(0xFFD4AF37) // لون ذهبي أفتح للزخارف
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // الخط الأفقي الرئيسي
    // canvas.drawLine(
    //   Offset(0, size.height - 25),
    //   Offset(size.width, size.height - 25),
    //   linePaint,
    // );

    // العلامات الرأسية بأنماط مختلفة
    final spacing = size.width / 6;
    for (int i = 0; i <= 6; i++) {
      final x = i * spacing;

      if (i == 0 || i == 6) {
        // النهايات - علامات مزدوجة
        canvas.drawLine(Offset(x, size.height - 25),
            Offset(x, size.height - 45), linePaint);
        canvas.drawLine(Offset(x - 2, size.height - 40),
            Offset(x + 2, size.height - 40), accentPaint);
      } else if (i == 3) {
        // المنتصف - علامة مع زخرفة
        canvas.drawLine(Offset(x, size.height - 25),
            Offset(x, size.height - 40), linePaint);
        // إضافة شكل ماسي صغير
        _drawDiamond(canvas, Offset(x, size.height - 42), 4, accentPaint);
      } else {
        // العلامات العادية
        canvas.drawLine(Offset(x, size.height - 25),
            Offset(x, size.height - 35), linePaint);
      }
    }
  }

  // دالة مساعدة لرسم شكل ماسي
  void _drawDiamond(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..lineTo(center.dx + size, center.dy)
      ..lineTo(center.dx, center.dy + size)
      ..lineTo(center.dx - size, center.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
