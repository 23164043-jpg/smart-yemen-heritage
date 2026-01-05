// lib/models/feedback_model.dart

// 💡 يمكنك تعديل هذا الكلاس مستقبلاً ليشمل تفاصيل المستخدم والمحتوى (Populated Data)
class FeedbackItem {
  final String? id;
  final String userId;
  final String contentId;
  final int rating;
  final String? comment;
  final DateTime? createdAt;

  FeedbackItem({
    this.id,
    required this.userId,
    required this.contentId,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  // دالة لإنشاء كائن من JSON (لجلب البيانات)
  factory FeedbackItem.fromJson(Map<String, dynamic> json) {
    return FeedbackItem(
      id: json['_id'] as String?,
      userId: json['user_id'] as String,
      contentId: json['content_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  // دالة لتحويل الكائن إلى JSON (لإرسال البيانات إلى API)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'content_id': contentId,
      'rating': rating,
      'comment': comment,
    };
  }
}
