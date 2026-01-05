import 'package:flutter/material.dart';

// تعريف الألوان المستخدمة لتعكس طابع اليمن القديم
const Color primaryColor =
    Color(0xFF8B4513); // لون بني ترابي (إشارة إلى الطين والعمارة)
const Color accentColor =
    Color(0xFFDAA520); // لون ذهبي (إشارة إلى الكنوز والآثار)
const Color backgroundColor = Color(0xFFF5F5DC); // لون بيج فاتح (لون الخلفية)
const Color textColor = Color(0xFF3C3C3C); // لون نص داكن

class AncientYemenHomePage extends StatelessWidget {
  const AncientYemenHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      // شريط التطبيق العلوي
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'الموسوعة الذكية',
          style: TextStyle(
            fontFamily: 'Arabic', // افترض وجود خط عربي حديث
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      // القائمة الجانبية (للتنقل بين الأقسام الرئيسية)
      drawer: const AppDrawer(),

      // جسم الصفحة الرئيسية
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // بطاقة الترحيب والبحث
            const SearchWelcomeCard(),

            const SizedBox(height: 25),

            // عنوان الأقسام الرئيسية
            const Text(
              '**أقسام الموسوعة الرئيسية**',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            const Divider(color: accentColor, thickness: 2, endIndent: 200),
            const SizedBox(height: 15),

            // شبكة بطاقات الأقسام (Grid View)
            const SectionGrid(),
          ],
        ),
      ),
    );
  }
}

// --- المكون 1: بطاقة البحث والترحيب ---
class SearchWelcomeCard extends StatelessWidget {
  const SearchWelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            '**تاريخ اليمن القديم** 📜',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'اكتشف حضارات سبأ، ومعين، وحمير، وأسرار الآثار اليمنية.',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
            ),
          ),
          const SizedBox(height: 20),
          // حقل البحث
          TextField(
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: 'ابحث عن مملكة أو ملك أو موقع أثري...',
              hintStyle: const TextStyle(fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: accentColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
              prefixIcon: const Icon(Icons.search, color: primaryColor),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}

// --- المكون 2: شبكة الأقسام ---
class SectionGrid extends StatelessWidget {
  const SectionGrid({super.key});

  final List<Map<String, dynamic>> sections = const [
    {
      'title': 'الممالك القديمة',
      'icon': Icons.castle,
      'color': Color(0xFFB8860B)
    },
    {
      'title': 'المواقع الأثرية',
      'icon': Icons.location_city,
      'color': Color(0xFF696969)
    },
    {
      'title': 'النقوش والخطوط',
      'icon': Icons.text_snippet,
      'color': Color(0xFF556B2F)
    },
    {'title': 'الشخصيات الحاكمة', 'icon': Icons.person, 'color': primaryColor},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // لمنع التمرير الداخلي
      itemCount: sections.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // عمودان
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.2, // نسبة العرض إلى الارتفاع للبطاقة
      ),
      itemBuilder: (context, index) {
        final section = sections[index];
        return SectionCard(
          title: section['title'],
          icon: section['icon'],
          color: section['color'],
        );
      },
    );
  }
}

// --- المكون 3: بطاقة القسم الفردية ---
class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // يمكنك هنا إضافة الدالة للانتقال إلى صفحة القسم
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم النقر على قسم $title')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- المكون 4: القائمة الجانبية (Drawer) ---
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'الموسوعة اليمنية',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'تاريخ عريق ومُكتشف',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('الصفحة الرئيسية', textAlign: TextAlign.right),
            leading: const Icon(Icons.home, color: primaryColor),
            onTap: () {
              Navigator.pop(context); // إغلاق القائمة
            },
          ),
          ListTile(
            title: const Text('خريطة الآثار التفاعلية',
                textAlign: TextAlign.right),
            leading: const Icon(Icons.map, color: primaryColor),
            onTap: () {
              // توجيه إلى صفحة الخريطة
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('المقالات المحفوظة', textAlign: TextAlign.right),
            leading: const Icon(Icons.bookmark, color: primaryColor),
            onTap: () {
              // توجيه إلى صفحة المحفوظات
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('حول المشروع', textAlign: TextAlign.right),
            leading: const Icon(Icons.info, color: primaryColor),
            onTap: () {
              // توجيه إلى صفحة حول المشروع
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
