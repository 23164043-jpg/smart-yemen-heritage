import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../login/login_screen.dart';
import '../../../services/signup_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // شعار الدائرة
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.person_add, color: Colors.white, size: 30),
              ),

              const SizedBox(height: 20),

              Text(
                "إنشاء حساب",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "قم بإنشاء حساب جديد للمتابعة",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textDark.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 40),

              // الاسم
              TextField(
                controller: nameController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: "الاسم الكامل",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // البريد الإلكتروني
              TextField(
                controller: emailController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: "البريد الإلكتروني",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // كلمة المرور
              TextField(
                controller: passwordController,
                textAlign: TextAlign.right,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "كلمة المرور",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // زر إنشاء الحساب
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final email = emailController.text.trim();
                    final password = passwordController.text.trim();

                    if (name.isEmpty || email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("الرجاء تعبئة جميع الحقول")),
                      );
                      return;
                    }

                    setState(() => isLoading = true);

                    final service = SignupService();
                    final result = await service.registerUser(
                      name: name,
                      email: email,
                      password: password,
                    );

                    setState(() => isLoading = false);

                    if (result["success"]) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("تم إنشاء الحساب بنجاح")),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result["message"])),
                      );
                    }
                  },
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "إنشاء حساب",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "لديك حساب بالفعل؟ ",
                    style: TextStyle(color: AppColors.textDark),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    child: Text(
                      "تسجيل دخول",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialIcon(Icons.facebook, Colors.blue),
                  const SizedBox(width: 15),
                  _socialIcon(Icons.g_mobiledata, Colors.red),
                  const SizedBox(width: 15),
                  _socialIcon(Icons.camera_alt, Colors.purple),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(10),
      child: Icon(icon, color: color, size: 30),
    );
  }
}
