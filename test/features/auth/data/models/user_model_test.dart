import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    const tUserModel = UserModel(
      id: '123',
      email: 'test@example.com',
      displayName: 'Test User',
      photoUrl: 'https://example.com/photo.jpg',
      role: 'User',
    );

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        // act
        final result = tUserModel.toJson();

        // assert
        final expectedMap = {
          'id': '123',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'photoUrl': 'https://example.com/photo.jpg',
          'role': 'User',
        };
        expect(result, expectedMap);
      });

      test('should handle null values', () {
        // arrange
        const userModel = UserModel(
          id: '123',
          email: 'test@example.com',
          role: 'User',
        );

        // act
        final result = userModel.toJson();

        // assert
        expect(result['displayName'], null);
        expect(result['photoUrl'], null);
      });
    });

    group('fromJson', () {
      test('should return a valid UserModel from JSON', () {
        // arrange
        final json = {
          'id': '123',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'photoUrl': 'https://example.com/photo.jpg',
          'role': 'User',
        };

        // act
        final result = UserModel.fromJson(json);

        // assert
        expect(result.id, '123');
        expect(result.email, 'test@example.com');
        expect(result.displayName, 'Test User');
        expect(result.photoUrl, 'https://example.com/photo.jpg');
        expect(result.role, 'User');
      });

      test('should use default role when not provided', () {
        // arrange
        final json = {
          'id': '123',
          'email': 'test@example.com',
        };

        // act
        final result = UserModel.fromJson(json);

        // assert
        expect(result.role, 'User');
      });

      test('should handle null optional fields', () {
        // arrange
        final json = {
          'id': '123',
          'email': 'test@example.com',
          'displayName': null,
          'photoUrl': null,
          'role': 'Admin',
        };

        // act
        final result = UserModel.fromJson(json);

        // assert
        expect(result.displayName, null);
        expect(result.photoUrl, null);
        expect(result.role, 'Admin');
      });
    });

    group('fromJson and toJson', () {
      test('should maintain data integrity through serialization cycle', () {
        // arrange
        final json = tUserModel.toJson();

        // act
        final result = UserModel.fromJson(json);

        // assert
        expect(result.id, tUserModel.id);
        expect(result.email, tUserModel.email);
        expect(result.displayName, tUserModel.displayName);
        expect(result.photoUrl, tUserModel.photoUrl);
        expect(result.role, tUserModel.role);
      });
    });
  });
}
