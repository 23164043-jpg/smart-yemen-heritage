import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_controller.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/settings/settings_controller.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';

const Color _primaryColor = Color(0xFFCD853F);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'مستخدم';
  String _email = 'example@mail.com';
  String? _profileImageUrl;
  bool _isUploadingImage = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // جلب البيانات من AuthService (البيانات الحقيقية من تسجيل الدخول)
    final userName = await AuthService.getUserName();
    final userEmail = await AuthService.getUserEmail();
    final profileImage = await ProfileService.getProfileImage();
    
    setState(() {
      _name = userName ?? 'مستخدم';
      _email = userEmail ?? 'example@mail.com';
      _profileImageUrl = profileImage;
    });
    
    print('👤 ProfileScreen: تم تحميل بيانات المستخدم - الاسم: $_name، البريد: $_email');
    print('🖼️ ProfileScreen: صورة البروفايل: $_profileImageUrl');

    // جلب البيانات من السيرفر (تحديث صورة البروفايل)
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    // تحقق من وجود توكن أولاً
    final token = await AuthService.getAuthToken();
    if (token == null || token.isEmpty) {
      print('⚠️ ProfileScreen: لا يوجد توكن - تخطي جلب البيانات من السيرفر');
      return;
    }
    
    final result = await ProfileService.getUserProfile();
    if (result['success'] && result['data'] != null) {
      final data = result['data'];
      setState(() {
        _profileImageUrl = data['profileImage'];
      });
    }
    // لا نعرض خطأ للمستخدم إذا فشل الجلب من السيرفر
  }

  Future<void> _save(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    // تحديث البيانات في SharedPreferences مباشرة
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    print('💾 ProfileScreen: تم حفظ التعديلات - الاسم: $name، البريد: $email');
    
    // تحديث على السيرفر أيضاً
    await ProfileService.updateProfile(name: name, email: email);
    
    _load();
  }

  /// اختيار وإرفاق صورة البروفايل
  Future<void> _pickAndUploadImage() async {
    try {
      // عرض خيارات اختيار الصورة
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'اختر مصدر الصورة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: _primaryColor),
                  title: const Text('المعرض'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: _primaryColor),
                  title: const Text('الكاميرا'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                if (_profileImageUrl != null) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('حذف الصورة', style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.pop(context);
                      _deleteProfileImage();
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      );

      if (source == null) return;

      // اختيار الصورة
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingImage = true);

      print('📸 ProfileScreen: تم اختيار صورة: ${pickedFile.path}');

      // رفع الصورة
      final result = await ProfileService.uploadProfileImage(File(pickedFile.path));

      if (result['success']) {
        setState(() {
          _profileImageUrl = result['imageUrl'];
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ تم تحديث صورة البروفايل بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${result['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ ProfileScreen: خطأ في اختيار/رفع الصورة: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  /// حذف صورة البروفايل
  Future<void> _deleteProfileImage() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف', style: TextStyle(color: _primaryColor)),
        content: const Text('هل تريد حذف صورة البروفايل؟'),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          TextButton(
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isUploadingImage = true);

    final result = await ProfileService.deleteProfileImage();

    if (result['success']) {
      setState(() {
        _profileImageUrl = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم حذف الصورة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isUploadingImage = false);
  }

  /// بناء صورة البروفايل مع زر التعديل
  Widget _buildProfileImage() {
    return Stack(
      children: [
        // الصورة
        GestureDetector(
          onTap: _isUploadingImage ? null : _pickAndUploadImage,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _primaryColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 55,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: _getProfileImage(),
              child: _isUploadingImage
                  ? const CircularProgressIndicator(color: _primaryColor)
                  : (_profileImageUrl == null
                      ? Icon(Icons.person, size: 50, color: Colors.grey.shade400)
                      : null),
            ),
          ),
        ),
        // زر تعديل الصورة
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _isUploadingImage ? null : _pickAndUploadImage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// جلب صورة البروفايل (من URL أو صورة افتراضية)
  ImageProvider? _getProfileImage() {
    if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      return NetworkImage(_profileImageUrl!);
    }
    // صورة افتراضية
    return const AssetImage('assets/images/user.png');
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
              onPressed: () async {
                // مسح جميع بيانات المستخدم باستخدام AuthService
                await AuthService.logout();
                print('🚪 ProfileScreen: تم تسجيل الخروج');
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
                _buildProfileImage(),
                const SizedBox(height: 12),
                Text(_name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: _primaryColor)),
                Text(_email, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Text(
                  'اضغط على الصورة لتغييرها',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
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
