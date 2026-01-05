import 'package:flutter/material.dart';

class AppController {
  // ThemeMode notifier (default light)
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier(ThemeMode.light);

  // Locale notifier (default Arabic 'ar')
  static final ValueNotifier<Locale> locale = ValueNotifier(const Locale('ar'));

  // Toggle theme
  static void toggleTheme(bool dark) {
    themeMode.value = dark ? ThemeMode.dark : ThemeMode.light;
  }

  // Change language
  static void changeLanguage(String code) {
    locale.value = Locale(code);
  }
}
