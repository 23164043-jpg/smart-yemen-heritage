import 'package:flutter/material.dart';

// نفس ألوان صفحة الممالك
const Color _primaryColor = Color(0xFFCD853F);
const Color _backgroundColor = Colors.white;

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: _primaryColor,
          elevation: 4,
          centerTitle: true,
          title: const Text(
            'عن التطبيق',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // بطاقة العنوان
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _primaryColor.withOpacity(0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.history_edu,
                      color: _primaryColor,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'الموسوعة الذكية – تاريخ اليمن القديم',
                            style: TextStyle(
                              color: _primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'تجربة معرفية تفاعلية مدعومة بالواقع المعزز',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // بطاقة المحتوى
              _infoCard(
                title: 'نبذة عن التطبيق',
                content:
                    'يهدف تطبيق الموسوعة الذكية في تاريخ اليمن القديم إلى إحياء الحضارات اليمنية العريقة، '
                    'من خلال تقديم محتوى تاريخي موثوق بأسلوب عصري يجمع بين النصوص، الصور، والواقع المعزز، '
                    'ليمنح المستخدم تجربة استكشاف فريدة.',
              ),

              _infoCard(
                title: 'رؤيتنا',
                content:
                    'أن يكون التاريخ اليمني حاضرًا في وجدان الأجيال القادمة، '
                    'سهل الوصول، غني بالمعلومة، ومواكبًا للتقنية الحديثة.',
              ),

              const SizedBox(height: 16),

              // معلومات سريعة
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _primaryColor.withOpacity(0.4)),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _InfoItem(title: 'الإصدار', value: '1.0.0'),
                    _InfoItem(title: 'التطوير', value: 'Yahya Alqataa'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // التذييل
              Text(
                'نعتز بتاريخنا… ونقدمه لك بروح المستقبل.',
                style: TextStyle(
                  color: _primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _primaryColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String value;

  const _InfoItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: _primaryColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
