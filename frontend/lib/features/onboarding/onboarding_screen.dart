import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../auth/login/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  late AnimationController _anim;
  late Animation<double> _fade;

  int _index = 0;

  final List<Map<String, String>> pages = [
    {
      "image": "assets/images/Onboarding1.webp",
      "title": "اكتشف تاريخ اليمن",
      "desc": "تعرف على الحضارات اليمنية القديمة بطريقة تفاعلية."
    },
    {
      "image": "assets/images/Onboarding2.webp",
      "title": "واقع معزز",
      "desc": "اعرض المجسمات التاريخية وكأنها أمامك."
    },
    {
      "image": "assets/images/Onboarding3.webp",
      "title": "موسوعة ذكية",
      "desc": "مساعد ذكي يقدم لك المعلومات التاريخية."
    },
  ];

  @override
  void initState() {
    super.initState();

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fade = CurvedAnimation(
      parent: _anim,
      curve: Curves.easeInOut,
    );

    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("onboarding_seen", true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // زر تخطي
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: finishOnboarding,
                child: Text(
                  "تخطي",
                  style: TextStyle(color: AppColors.primary, fontSize: 18),
                ),
              ),
            ),

            // الصفحات
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) {
                  setState(() {
                    _index = i;
                    _anim.forward(from: 0);
                  });
                },
                itemBuilder: (_, i) {
                  return FadeTransition(
                    opacity: _fade,
                    child: Column(
                      children: [
                        Image.asset(
                          pages[i]["image"]!,
                          height: 280,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 20),

                        // العنوان
                        Text(
                          pages[i]["title"]!,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // الوصف
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            pages[i]["desc"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.6,
                              color: AppColors.textDark.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // النقاط
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: _index == i ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // زر التالي / ابدأ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  if (_index == pages.length - 1) {
                    finishOnboarding();
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Text(
                  _index == pages.length - 1 ? "ابدأ الآن" : "التالي",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
