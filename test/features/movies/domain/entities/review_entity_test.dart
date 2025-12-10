import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/review_entity.dart';

void main() {
  group('ReviewEntity', () {
    test('should create ReviewEntity with all fields', () {
      // arrange & act
      const review = ReviewEntity(
        id: '123',
        author: 'John Doe',
        content: 'Great movie!',
        createdAt: '2024-01-15',
        rating: 9.0,
      );

      // assert
      expect(review.id, '123');
      expect(review.author, 'John Doe');
      expect(review.content, 'Great movie!');
      expect(review.createdAt, '2024-01-15');
      expect(review.rating, 9.0);
    });

    test('should create ReviewEntity without rating', () {
      // arrange & act
      const review = ReviewEntity(
        id: '123',
        author: 'John Doe',
        content: 'Great movie!',
        createdAt: '2024-01-15',
      );

      // assert
      expect(review.rating, null);
    });

    test('should be equal when all properties match', () {
      // arrange
      const review1 = ReviewEntity(
        id: '123',
        author: 'John Doe',
        content: 'Great movie!',
        createdAt: '2024-01-15',
        rating: 9.0,
      );

      const review2 = ReviewEntity(
        id: '123',
        author: 'John Doe',
        content: 'Great movie!',
        createdAt: '2024-01-15',
        rating: 9.0,
      );

      // assert
      expect(review1.id, review2.id);
      expect(review1.author, review2.author);
      expect(review1.content, review2.content);
      expect(review1.rating, review2.rating);
    });
  });
}
