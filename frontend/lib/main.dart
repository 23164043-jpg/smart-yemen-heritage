import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/profile/about_app_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/login/login_screen.dart';
import 'features/auth/signup/signup_screen.dart';
import 'features/auth/forgot_password/forgot_password_screen.dart';
import 'features/auth/forgot_password/verification_screen.dart';
import 'features/home/home_screen.dart';
import 'features/favorites/favorites_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/landmarks/schedule_screen.dart';
import 'features/Kingdoms/schedule2_screen.dart';

import 'core/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // استخدم SettingsProvider الذي أرسلته (يحمل القيم من SharedPreferences)
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        // إذا لديك مزوّدات أخرى، أضفها هنا
      ],
      child: const AppRoot(),
    ),
  );
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Yemen Heritage',
          locale: settings.locale,
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          initialRoute: '/splash',
          routes: {
            '/splash': (c) => const SplashScreen(),
            '/onboarding': (c) => const OnboardingScreen(),
            '/login': (c) => const LoginPage(),
            '/signup': (c) => const SignupScreen(),
            '/forgot_password': (c) => const ForgotPasswordScreen(),
            '/verify': (c) => const VerificationScreen(),
            '/home': (c) => const HomeScreen(userName: ''),
            '/schedule': (c) => const LandmarksScreen(),
            '/schedule2': (c) => const KingdomsScreen(),
            '/favorites': (c) => const FavoritesScreen(),
            '/profile': (c) => const ProfileScreen(),
            '/about_app': (context) => const AboutAppScreen(),
          },
        );
      },
    );
  }
}
