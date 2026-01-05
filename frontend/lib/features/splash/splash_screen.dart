import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String _status = "جارٍ التحميل...";
  bool _showStatus = true;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.7,
      upperBound: 1.0,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    );

    _fadeController.forward();
    _scaleController.forward();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 500));

    _updateStatus("جاري التحقق من الإعدادات...");
    await Future.delayed(const Duration(milliseconds: 600));

    _updateStatus("جاري تحميل البيانات...");
    await Future.delayed(const Duration(milliseconds: 600));

    _updateStatus("تهيئة النظام...");
    await Future.delayed(const Duration(milliseconds: 600));

    _updateStatus("جاري التحضير...");
    await Future.delayed(const Duration(milliseconds: 600));

    final prefs = await SharedPreferences.getInstance();
    final onboardingSeen = prefs.getBool("onboarding_seen") ?? false;

    if (!mounted) return;

    if (!onboardingSeen) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _updateStatus(String s) {
    setState(() {
      _showStatus = false;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() {
        _status = s;
        _showStatus = true;
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // خلفية حديثة بتدرج لوني
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.background,
              AppColors.background.withOpacity(0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // الشعار بحركة Scale لطيفة
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.account_balance,
                    size: 70,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // نص المسند
              Text(
                '𐩬𐩣𐩺𐩡𐩱 𐩻𐩧𐩩',
                style: TextStyle(
                  fontFamily: 'OldSouthArabian',
                  color: AppColors.primary,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // عنوان أسفل الشعار
              Text(
                'الموسوعة الذكية في تاريخ اليمن القديم',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                ),
              ),

              const Spacer(),

              const CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),

              const SizedBox(height: 16),

              // نص متغيّر بتأثير AnimatedSwitcher
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, anim) {
                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  );
                },
                child: _showStatus
                    ? Text(
                        _status,
                        key: ValueKey(_status),
                        style: TextStyle(
                          color: AppColors.textDark.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      )
                    : const SizedBox(),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
