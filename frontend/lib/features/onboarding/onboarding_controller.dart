import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_page_model.dart';

class OnboardingController {
  final PageController pageController = PageController();
  int currentIndex = 0;

  final List<OnboardingPageModel> pages = [
    OnboardingPageModel(
      title: "مرحبا بك في الموسوعة الذكية",
      description: "استكشف تاريخ اليمن القديم بطريقة تفاعلية",
      image: "assets/images/on1.jpg",
    ),
    OnboardingPageModel(
      title: "تعرف على الممالك القديمة",
      description: "سبأ، معين، حمير، قتبان والمزيد",
      image: "assets/images/on2.jpg",
    ),
    OnboardingPageModel(
      title: "الواقع المعزز",
      description: "شاهد المعالم اليمنية بتقنية AR",
      image: "assets/images/on3.jpg",
    ),
  ];

  Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("onboarding_seen", true);
  }
}
