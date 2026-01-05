import 'package:flutter/material.dart';
import 'signin_page.dart';

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

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
            _topDecoration(),
            Expanded(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/images/oldsanaa.jpg',
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
                      const Text(
                        'كن جزءاً من التاريخ',
                        style: TextStyle(
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      'ابدأ مغامرتك الآن وشارك في حماية التراث اليمني العظيم عبر تطبيقنا الذكي.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.brown,
                        fontFamily: 'Cairo',
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(false),
                _buildDot(false),
                _buildDot(true),
              ],
            ),
            const SizedBox(height: 24),
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
                onPressed: () {
                  Navigator.of(context).push(_createRouteToSignIn());
                },
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
            _bottomDecoration(),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool active) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: active ? 10 : 8,
        height: active ? 10 : 8,
        decoration: BoxDecoration(
          color: active ? Colors.brown : Colors.brown.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
      );

  Widget _sideLine() =>
      Container(width: 20, height: 2, color: Colors.brown.withOpacity(0.4));

  Widget _topDecoration() => SizedBox(
        height: 16,
        child: CustomPaint(painter: DottedLinePainter()),
      );

  Widget _bottomDecoration() => SizedBox(
        height: 16,
        child: CustomPaint(painter: DottedLinePainter()),
      );
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
