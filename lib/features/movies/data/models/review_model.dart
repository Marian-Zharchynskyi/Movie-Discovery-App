import 'package:movie_discovery_app/features/movies/domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.author,
    required super.content,
    required super.createdAt,
    super.rating,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      author: json['author'] as String,
      content: json['content'] as String,
      createdAt: json['created_at'] as String,
      rating: json['author_details']?['rating']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'content': content,
      'created_at': createdAt,
      'author_details': rating != null ? {'rating': rating} : null,
    };
  }
}
