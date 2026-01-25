import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../navigation/main_navigation_screen.dart';
import '../signup/signup_screen.dart';
import '../forgot_password/forgot_password_screen.dart';
import '../../../core/providers/settings_provider.dart';

// لون الحقول الفاتح (يبقى كما في مشروعك)
const Color _fieldsBackgroundColor = Color(0xFFFBF8F0);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool isLoading = false;
  bool rememberMe = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadSavedLogin();
  }

  Future<void> _loadSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString("saved_email");
    final savedPassword = prefs.getString("saved_password");
    final savedRemember = prefs.getBool("remember_me") ?? false;

    if (savedRemember && savedEmail != null && savedPassword != null) {
      setState(() {
        emailController.text = savedEmail;
        passwordController.text = savedPassword;
        rememberMe = true;
      });
    }
  }

  Future<void> _saveLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('saved_email', emailController.text);
      await prefs.setString('saved_password', passwordController.text);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
    }
  }

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => isLoading = true);

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      final result = await AuthService().login(email, password);

      if (result['success'] == true) {
        await _saveLoginData();
        final userName = result['data']['user']['user_name'] as String;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تسجيل الدخول بنجاح 🎉")),
        );

        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigationScreen(userName: userName),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"] ?? "فشل تسجيل الدخول"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on TimeoutException {
      print('❌ Login Error: Timeout');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("انتهت مهلة الاتصال بالسيرفر"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('❌ Login Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("خطأ في الاتصال: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }

    setState(() => isLoading = false);
  }

  // تحكم بعرض البطاقة responsive
  double _cardMaxWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 1100) return 680;
    if (w > 800) return 600;
    if (w > 600) return 520;
    if (w > 420) return 380;
    return w - 32;
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = settings.isDarkMode;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : colorScheme.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: _cardMaxWidth(context)),
                child: _buildCard(context, colorScheme, isDark),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, ColorScheme cs, bool isDark) {
    final surfaceColor = isDark ? const Color(0xFF0B0B0B) : cs.surface;
    final textColor = isDark ? Colors.white : cs.onSurface;

    return Card(
      elevation: 8,
      color: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header row: icon + title
            Row(
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_stories, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "الموسوعة الذكية لتاريخ اليمن القديم",
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              "مرحباً بك مجدداً",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "سجل دخولك لمتابعة رحلتك عبر صفحات التاريخ",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 22),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  // البريد الإلكتروني
                  TextFormField(
                    controller: emailController,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: "البريد الإلكتروني",
                      labelStyle: TextStyle(
                          color: isDark ? Colors.grey.shade300 : Colors.grey),
                      prefixIcon: Icon(Icons.email, color: AppColors.primary),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF151515)
                          : _fieldsBackgroundColor,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "الرجاء إدخال البريد الإلكتروني";
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  // كلمة المرور
                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: "كلمة المرور",
                      labelStyle: TextStyle(
                          color: isDark ? Colors.grey.shade300 : Colors.grey),
                      prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF151515)
                          : _fieldsBackgroundColor,
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.primary),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "الرجاء إدخال كلمة المرور";
                      if (value.length < 6)
                        return "كلمة المرور يجب أن تكون 6 أحرف على الأقل";
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // remember + forgot
            Row(
              children: [
                Checkbox(
                  value: rememberMe,
                  onChanged: (v) => setState(() => rememberMe = v ?? false),
                  activeColor: AppColors.primary,
                  side: BorderSide(
                      color: isDark ? Colors.grey.shade700 : Colors.grey),
                ),
                const Text("تذكرني"),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen())),
                  child: Text("نسيت كلمة المرور؟",
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // زر الدخول
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : loginUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.2))
                    : const Text("تسجيل الدخول",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),

            const SizedBox(height: 16),

            // divider with text
            Row(
              children: [
                Expanded(
                    child: Divider(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text("أو تابع باستخدام",
                      style: TextStyle(
                          color: isDark ? Colors.grey.shade300 : Colors.grey)),
                ),
                Expanded(
                    child: Divider(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade300)),
              ],
            ),

            const SizedBox(height: 14),

            // Google button (outline style)
            SizedBox(
              height: 46,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: تنفيذ Google Sign-In
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color:
                          isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor:
                      isDark ? const Color(0xFF0A0A0A) : Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.g_mobiledata, size: 28),
                    SizedBox(width: 10),
                    Text("متابعة باستخدام Google"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Guest (text)
            Center(
              child: GestureDetector(
                onTap: () {
                  // TODO: دخول كزائر
                },
                child: Text("الدخول كزائر",
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: isDark ? Colors.grey.shade200 : Colors.black87)),
              ),
            ),

            const SizedBox(height: 18),

            // Signup row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("ليس لديك حساب؟ "),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SignupScreen())),
                  child: Text("إنشاء حساب",
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Dark mode switch using SettingsProvider
            Center(
              child: Consumer<SettingsProvider>(
                builder: (context, settingsProv, _) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("الوضع الداكن"),
                      const SizedBox(width: 8),
                      Switch(
                        value: settingsProv.isDarkMode,
                        onChanged: (v) async {
                          await settingsProv.setDarkMode(v);
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
