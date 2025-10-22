import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/features/movies/data/models/review_model.dart';

void main() {
  group('ReviewModel', () {
    const tReviewModel = ReviewModel(
      id: '123',
      author: 'John Doe',
      content: 'Great movie! Highly recommended.',
      createdAt: '2024-01-15T10:30:00Z',
      rating: 9.0,
    );

    group('fromJson', () {
      test('should return a valid ReviewModel from JSON with rating', () {
        // arrange
        final json = {
          'id': '123',
          'author': 'John Doe',
          'content': 'Great movie! Highly recommended.',
          'created_at': '2024-01-15T10:30:00Z',
          'author_details': {'rating': 9.0},
        };

        // act
        final result = ReviewModel.fromJson(json);

        // assert
        expect(result.id, '123');
        expect(result.author, 'John Doe');
        expect(result.content, 'Great movie! Highly recommended.');
        expect(result.createdAt, '2024-01-15T10:30:00Z');
        expect(result.rating, 9.0);
      });

      test('should handle null rating', () {
        // arrange
        final json = {
          'id': '123',
          'author': 'John Doe',
          'content': 'Great movie!',
          'created_at': '2024-01-15T10:30:00Z',
        };

        // act
        final result = ReviewModel.fromJson(json);

        // assert
        expect(result.rating, null);
      });

      test('should handle null author_details', () {
        // arrange
        final json = {
          'id': '123',
          'author': 'John Doe',
          'content': 'Great movie!',
          'created_at': '2024-01-15T10:30:00Z',
          'author_details': null,
        };

        // act
        final result = ReviewModel.fromJson(json);

        // assert
        expect(result.rating, null);
      });

      test('should handle integer rating', () {
        // arrange
        final json = {
          'id': '123',
          'author': 'John Doe',
          'content': 'Great movie!',
          'created_at': '2024-01-15T10:30:00Z',
          'author_details': {'rating': 8},
        };

        // act
        final result = ReviewModel.fromJson(json);

        // assert
        expect(result.rating, 8.0);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data with rating', () {
        // act
        final result = tReviewModel.toJson();

        // assert
        expect(result['id'], '123');
        expect(result['author'], 'John Doe');
        expect(result['content'], 'Great movie! Highly recommended.');
        expect(result['created_at'], '2024-01-15T10:30:00Z');
        expect(result['author_details'], {'rating': 9.0});
      });

      test('should handle null rating in toJson', () {
        // arrange
        const reviewModel = ReviewModel(
          id: '123',
          author: 'John Doe',
          content: 'Great movie!',
          createdAt: '2024-01-15T10:30:00Z',
        );

        // act
        final result = reviewModel.toJson();

        // assert
        expect(result['author_details'], null);
      });
    });

    group('fromJson and toJson', () {
      test('should maintain data integrity through serialization cycle', () {
        // arrange
        final json = tReviewModel.toJson();

        // act
        final result = ReviewModel.fromJson(json);

        // assert
        expect(result.id, tReviewModel.id);
        expect(result.author, tReviewModel.author);
        expect(result.content, tReviewModel.content);
        expect(result.createdAt, tReviewModel.createdAt);
        expect(result.rating, tReviewModel.rating);
      });
    });
  });
}
