import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/sanaa.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.5),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 50),

                // // الزخرفة العلوية
                // _buildTopDecoration(),
                // const SizedBox(height: 50),

                // الأيقونة الدائرية
                _buildIconCircle(),
                const SizedBox(height: 20),

                // النصوص الرئيسية
                _buildMainTexts(),
                const SizedBox(height: 15),

                // حقل البريد الإلكتروني
                _buildEmailField(),
                const SizedBox(height: 20),

                // حقل كلمة المرور
                _buildPasswordField(),
                const SizedBox(height: 10),

                // نسيت كلمة المرور
                _buildForgotPassword(),
                const SizedBox(height: 15),

                // زر تسجيل الدخول
                _buildLoginButton(),
                const SizedBox(height: 25),

                // فاصل "أو"
                _buildDivider(),
                const SizedBox(height: 25),

                // رابط إنشاء حساب
                _buildSignupLink(),
                const Spacer(),

                // النص السفلي
                _buildFooter(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildTopDecoration() {
  //   return SizedBox(
  //     height: 40,
  //     child: CustomPaint(
  //       size: const Size(double.infinity, 40),
  //       painter: _TicksPainter(),
  //     ),
  //   );
  // }

  Widget _buildIconCircle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          width: 3,
          color: Colors.amber.shade200,
        ),
      ),
      child:
          Icon(Icons.menu_book_rounded, size: 60, color: Colors.amber.shade200),
    );
  }

  Widget _buildMainTexts() {
    return Column(
      children: [
        Text(
          'اليمن',
          style: GoogleFonts.tajawal(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          'التراث العريق',
          style: GoogleFonts.tajawal(
            fontSize: 18,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'البريد الإلكتروني',
          style: GoogleFonts.tajawal(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          height: 55,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: TextField(
            style: GoogleFonts.tajawal(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'أدخل بريدك الإلكتروني',
              hintStyle: GoogleFonts.tajawal(
                color: Colors.white54,
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'كلمة المرور',
          style: GoogleFonts.tajawal(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 55,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: TextField(
            obscureText: true,
            style: GoogleFonts.tajawal(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'أدخل كلمة المرور',
              hintStyle: GoogleFonts.tajawal(
                color: Colors.white54,
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {},
        child: Text(
          'نسيت كلمة المرور؟',
          style: GoogleFonts.tajawal(
            color: Colors.amber.shade200,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: Text(
          'تسجيل الدخول',
          style: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.white.withOpacity(0.3),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'أو',
            style: GoogleFonts.tajawal(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.white.withOpacity(0.3),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSignupLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ليس لديك حساب؟ ',
          style: GoogleFonts.tajawal(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Text(
            'إنشاء حساب جديد',
            style: GoogleFonts.tajawal(
              color: Colors.amber.shade200,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Text(
      'مرحباً بك في رحلتك عبر التاريخ اليمني العريق',
      textAlign: TextAlign.center,
      style: GoogleFonts.tajawal(
        color: Colors.white70,
        fontSize: 14,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
//
// class _TicksPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = const Color(0xFFB79B73)
//       ..strokeWidth = 2.0
//       ..strokeCap = StrokeCap.round;
//
//     // الخط الأفقي الرئيسي
//     canvas.drawLine(
//       Offset(0, size.height - 20),
//       Offset(size.width, size.height - 20),
//       paint,
//     );
//
//     // العلامات الرأسية
//     final spacing = size.width / 8;
//     for (int i = 0; i <= 8; i++) {
//       final x = i * spacing;
//
//       if (i == 0 || i == 8) {
//         // النهايات - علامات طويلة
//         canvas.drawLine(
//           Offset(x, size.height - 20),
//           Offset(x, size.height - 40),
//           paint,
//         );
//       } else if (i == 4) {
//         // المنتصف - علامة متوسطة
//         canvas.drawLine(
//           Offset(x, size.height - 20),
//           Offset(x, size.height - 35),
//           paint,
//         );
//       } else {
//         // العلامات الأخرى - قصيرة
//         canvas.drawLine(
//           Offset(x, size.height - 20),
//           Offset(x, size.height - 30),
//           paint,
//         );
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
