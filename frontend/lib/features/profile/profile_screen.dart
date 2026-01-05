import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_controller.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/settings/settings_controller.dart';

const Color _primaryColor = Color(0xFFCD853F);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'مستخدم';
  String _email = 'example@mail.com';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? 'مستخدم';
      _email = prefs.getString('user_email') ?? 'example@mail.com';
    });
  }

  Future<void> _save(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    _load();
  }

  void _openEdit() {
    final nameController = TextEditingController(text: _name);
    final emailController = TextEditingController(text: _email);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('تعديل الملف الشخصي',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: _primaryColor)),
            const SizedBox(height: 8),
            TextField(
                controller: nameController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                    labelText: 'الاسم',
                    labelStyle: TextStyle(color: _primaryColor)),
                cursorColor: _primaryColor),
            const SizedBox(height: 8),
            TextField(
                controller: emailController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    labelStyle: TextStyle(color: _primaryColor)),
                cursorColor: _primaryColor),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  _save(
                      nameController.text.trim(), emailController.text.trim());
                  Navigator.pop(context);
                },
                child: const Text('حفظ'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _openSettings() {
    SettingsController? settings;
    try {
      settings = Provider.of<SettingsController>(context, listen: false);
    } catch (_) {
      settings = null;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('الإعدادات',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: _primaryColor)),
              const SizedBox(height: 8),
              SwitchListTile(
                value: context.watch<SettingsProvider>().isDarkMode,
                title: const Text('الوضع الداكن'),
                onChanged: (value) =>
                    context.read<SettingsProvider>().toggleDarkMode(),
                secondary: const Icon(Icons.dark_mode),
              ),
              ListTile(
                leading: const Icon(Icons.language, color: _primaryColor),
                title: const Text('تغيير اللغة'),
                onTap: () async {
                  final sel = await showDialog<String>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('اختر اللغة',
                          style: TextStyle(color: _primaryColor)),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, 'ar'),
                            child: const Text('العربية')),
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, 'en'),
                            child: const Text('English')),
                      ],
                    ),
                  );
                  if (sel != null) {
                    AppController.changeLanguage(sel);
                    try {
                      settings?.setLanguage(sel);
                    } catch (_) {}
                    setState(() {});
                    Navigator.pop(context);
                  }
                },
              ),
            ]),
      ),
    );
  }

  void _openHelpCenter() {
    try {
      Navigator.pushNamed(context, '/help');
      return;
    } catch (_) {}
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const _HelpCenterPage()));
  }

  void _openPrivacyPolicy() {
    try {
      Navigator.pushNamed(context, '/privacy');
      return;
    } catch (_) {}
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const _PrivacyPolicyPage()));
  }

  void _openAbout() {
    Navigator.pushNamed(context, '/about_app');
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد', style: TextStyle(color: _primaryColor)),
        content: const Text('هل تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
              child: const Text('إلغاء'), onPressed: () => Navigator.pop(ctx)),
          TextButton(
              child: const Text('خروج'),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacementNamed(context, '/login');
              }),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback action) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _primaryColor.withOpacity(0.4))),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        trailing: Icon(icon, color: _primaryColor),
        title: Text(title,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.black87)),
        onTap: action,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
          title: const Text('الملف الشخصي'),
          centerTitle: true,
          backgroundColor: _primaryColor),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage:
                        const AssetImage('assets/images/user.png')),
                const SizedBox(height: 12),
                Text(_name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: _primaryColor)),
                Text(_email, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 25),
          _buildMenuItem(Icons.edit, "تعديل المعلومات", _openEdit),
          _buildMenuItem(Icons.settings, "الإعدادات", _openSettings),
          _buildMenuItem(Icons.favorite, "المفضلة",
              () => Navigator.pushNamed(context, '/favorites')),
          _buildMenuItem(Icons.history, "سجل الزيارات", () {}),
          _buildMenuItem(Icons.help, "مركز المساعدة", _openHelpCenter),
          _buildMenuItem(Icons.info, "حول التطبيق", _openAbout),
          _buildMenuItem(
              Icons.privacy_tip, "سياسة الخصوصية", _openPrivacyPolicy),
          _buildMenuItem(Icons.logout, "تسجيل الخروج", _logout),
        ]),
      ),
    );
  }
}

class _HelpCenterPage extends StatelessWidget {
  const _HelpCenterPage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('مركز المساعدة'), backgroundColor: _primaryColor),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          const Text('مركز المساعدة',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor)),
          const SizedBox(height: 12),
          const Text(
              'إذا واجهت مشكلة، تواصل معنا عبر البريد support@yemen-heritage.example أو استخدم نموذج الاتصال داخل التطبيق.',
              textAlign: TextAlign.right),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('فتح نموذج تواصل (محاكاة)')));
            },
            child: const Text('اتصل بالدعم'),
          ),
        ]),
      ),
    );
  }
}

class _PrivacyPolicyPage extends StatelessWidget {
  const _PrivacyPolicyPage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('سياسة الخصوصية'), backgroundColor: _primaryColor),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text('سياسة الخصوصية',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor)),
                SizedBox(height: 12),
                Text(
                  'نحترم خصوصيتك. يتم استخدام بيانات بسيطة مثل اسم المستخدم والبريد لحفظ الإعدادات وتحسين تجربة التطبيق. '
                  'لا نشارك البيانات مع أطراف خارجية بدون موافقة المستخدم. هذه سياسة عامة — استبدلها بنص سياسة حقيقي لمشروعك.',
                  textAlign: TextAlign.right,
                ),
              ]),
        ),
      ),
    );
  }
}
