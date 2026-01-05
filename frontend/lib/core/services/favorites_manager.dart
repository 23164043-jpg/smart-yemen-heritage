// lib/core/services/favorites_manager.dart
class FavoritesManager {
  FavoritesManager._private();
  static final FavoritesManager instance = FavoritesManager._private();

  // مجموعة المعرفات المحفوظة
  final Set<String> _ids = {};

  // خريطة لمعلومات العنصر (title, image) بناءً على id
  final Map<String, Map<String, String>> _meta = {};

  bool isFavorite(String id) => _ids.contains(id);

  /// toggleFavorite: يحفظ أو يزيل من المفضلة
  /// تمرّر id و optional title/image حتى تظهر في صفحة المفضلة لاحقاً
  void toggleFavorite(String id,
      {required String title, required String image}) {
    if (_ids.contains(id)) {
      _ids.remove(id);
      _meta.remove(id);
    } else {
      _ids.add(id);
      _meta[id] = {'title': title, 'image': image};
    }
  }

  /// للحصول على قائمة المفضلات (كل عنصر: id, title, image)
  List<Map<String, String>> getFavorites() {
    return _ids.map((id) {
      final m = _meta[id];
      return {
        'id': id,
        'title': m != null ? (m['title'] ?? '') : '',
        'image': m != null ? (m['image'] ?? '') : '',
      };
    }).toList();
  }

  /// مسح كل المفضلات (اختياري)
  void clearAll() {
    _ids.clear();
    _meta.clear();
  }
}
