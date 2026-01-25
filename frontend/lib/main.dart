import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 🔥 Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// 🔔 Services
import 'services/notification_service.dart';
import 'services/local_notification_service.dart';

// Theme & Core
import 'core/theme/app_theme.dart';
import 'core/providers/settings_provider.dart';

// Screens
import 'features/profile/about_app_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/login/login_screen.dart';
import 'features/auth/signup/signup_screen.dart';
import 'features/auth/forgot_password/forgot_password_screen.dart';
import 'features/auth/forgot_password/verification_screen.dart';
import 'features/favorites/favorites_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/landmarks/schedule_screen.dart';
import 'features/Kingdoms/schedule2_screen.dart';
import 'features/navigation/main_navigation_screen.dart';
import 'features/ocr/ocr_screen.dart';

/// 🔥 مهم جدًا: Background handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Firebase
  await Firebase.initializeApp();

  // 🔔 Background notifications
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  // 🔔 FCM + Local Notifications
  await NotificationService.init();
  await LocalNotificationService.initialize();

  // ⚙️ Settings
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
        ),
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
            '/home': (c) => const MainNavigationScreen(userName: ''),
            '/main': (c) => const MainNavigationScreen(userName: ''),
            '/schedule': (c) => const LandmarksScreen(),
            '/schedule2': (c) => const KingdomsScreen(),
            '/favorites': (c) => const FavoritesScreen(),
            '/profile': (c) => const ProfileScreen(),
            '/about_app': (c) => const AboutAppScreen(),
            '/ocr': (c) => const OcrScreen(),
          },
        );
      },
    );
  }
}
