// Product Review Model
class ProductReview {
  final String id;
  final String userName;
  final String userAvatar;
  final int rating;
  final DateTime date;
  final String comment;

  ProductReview({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.date,
    required this.comment,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id']?.toString() ?? '',
      userName: json['user_name'] ?? 'Anonymous',
      userAvatar: '', // Not provided in API
      rating: json['rating'] ?? 0,
      date: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      comment: json['review_text'] ?? '',
    );
  }
}
