import 'package:flutter/material.dart';
import '../../../core/services/favorites_manager.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    final favs = FavoritesManager.instance.getFavorites();

    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
        centerTitle: true,
      ),
      body: favs.isEmpty
          ? const Center(child: Text('لم تقم بإضافة أي مفضلة بعد.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: favs.length,
              itemBuilder: (context, index) {
                final item = favs[index];
                return Card(
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(item['image'] ?? '',
                          width: 60, height: 60, fit: BoxFit.cover),
                    ),
                    title:
                        Text(item['title'] ?? '', textAlign: TextAlign.right),
                    onTap: () {
                      // هنا يمكنك فتح صفحة التفاصيل المناسبة إذا أردت لاحقاً
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        FavoritesManager.instance.toggleFavorite(
                            item['id'] ?? '',
                            title: item['title'] ?? '',
                            image: item['image'] ?? '');
                        setState(() {});
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
