import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// jdhdjkfhkdfjkddhfkdjf
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Tajawal',
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      background: AppColors.background,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSurface: AppColors.textDark,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Tajawal',
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      background: Color(0xFF1C1B1F),
      surface: Color(0xFF27262B),
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF1C1B1F),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
  );
}
