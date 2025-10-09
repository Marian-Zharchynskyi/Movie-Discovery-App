class ReviewEntity {
  final String id;
  final String author;
  final String content;
  final String createdAt;
  final double? rating;

  const ReviewEntity({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
    this.rating,
  });
}
