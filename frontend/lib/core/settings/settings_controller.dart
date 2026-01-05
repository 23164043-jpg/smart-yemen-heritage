import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  bool _darkMode = false;
  String _languageCode = 'ar';

  bool get darkMode => _darkMode;
  String get languageCode => _languageCode;

  // Toggle simple
  void toggleDarkMode() {
    _darkMode = !_darkMode;
    notifyListeners();
    _savePrefs();
  }

  Future<void> setDarkMode(bool val) async {
    _darkMode = val;
    notifyListeners();
    await _savePrefs();
  }

  void toggleLanguage() {
    _languageCode = _languageCode == 'ar' ? 'en' : 'ar';
    notifyListeners();
    _savePrefs();
  }

  Future<void> setLanguage(String code) async {
    _languageCode = code;
    notifyListeners();
    await _savePrefs();
  }

  Future<void> _savePrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dark_mode', _darkMode);
      await prefs.setString('language', _languageCode);
    } catch (_) {}
  }

  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _darkMode = prefs.getBool('dark_mode') ?? _darkMode;
      _languageCode = prefs.getString('language') ?? _languageCode;
      notifyListeners();
    } catch (_) {}
  }
}
