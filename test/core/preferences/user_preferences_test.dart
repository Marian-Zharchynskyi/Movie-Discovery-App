import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/preferences/user_preferences.dart';

class MockBox extends Mock implements Box {}

void main() {
  late UserPreferences userPreferences;
  late MockBox mockBox;

  setUp(() {
    mockBox = MockBox();
    userPreferences = UserPreferences(mockBox);
  });

  group('UserPreferences', () {
    group('Theme Mode', () {
      test('should set theme mode string', () async {
        // arrange
        const tThemeMode = 'dark';
        when(() => mockBox.put(any(), any()))
            .thenAnswer((_) async => Future.value());

        // act
        await userPreferences.setThemeModeString(tThemeMode);

        // assert
        verify(() => mockBox.put(UserPreferences.kThemeMode, tThemeMode))
            .called(1);
      });

      test('should get theme mode string when it exists', () {
        // arrange
        const tThemeMode = 'light';
        when(() => mockBox.get(any())).thenReturn(tThemeMode);

        // act
        final result = userPreferences.getThemeModeString();

        // assert
        expect(result, tThemeMode);
        verify(() => mockBox.get(UserPreferences.kThemeMode)).called(1);
      });

      test('should return null when theme mode is not set', () {
        // arrange
        when(() => mockBox.get(any())).thenReturn(null);

        // act
        final result = userPreferences.getThemeModeString();

        // assert
        expect(result, null);
      });

      test('should return null when theme mode is not a string', () {
        // arrange
        when(() => mockBox.get(any())).thenReturn(123);

        // act
        final result = userPreferences.getThemeModeString();

        // assert
        expect(result, null);
      });
    });

    group('Locale', () {
      test('should set locale code', () async {
        // arrange
        const tLocaleCode = 'uk';
        when(() => mockBox.put(any(), any()))
            .thenAnswer((_) async => Future.value());

        // act
        await userPreferences.setLocaleCode(tLocaleCode);

        // assert
        verify(() => mockBox.put(UserPreferences.kLocale, tLocaleCode))
            .called(1);
      });

      test('should delete locale when code is null', () async {
        // arrange
        when(() => mockBox.delete(any()))
            .thenAnswer((_) async => Future.value());

        // act
        await userPreferences.setLocaleCode(null);

        // assert
        verify(() => mockBox.delete(UserPreferences.kLocale)).called(1);
        verifyNever(() => mockBox.put(any(), any()));
      });

      test('should delete locale when code is empty', () async {
        // arrange
        when(() => mockBox.delete(any()))
            .thenAnswer((_) async => Future.value());

        // act
        await userPreferences.setLocaleCode('');

        // assert
        verify(() => mockBox.delete(UserPreferences.kLocale)).called(1);
      });

      test('should get locale code when it exists', () {
        // arrange
        const tLocaleCode = 'en';
        when(() => mockBox.get(any())).thenReturn(tLocaleCode);

        // act
        final result = userPreferences.getLocaleCode();

        // assert
        expect(result, tLocaleCode);
        verify(() => mockBox.get(UserPreferences.kLocale)).called(1);
      });

      test('should return null when locale is not set', () {
        // arrange
        when(() => mockBox.get(any())).thenReturn(null);

        // act
        final result = userPreferences.getLocaleCode();

        // assert
        expect(result, null);
      });

      test('should return null when locale is empty string', () {
        // arrange
        when(() => mockBox.get(any())).thenReturn('');

        // act
        final result = userPreferences.getLocaleCode();

        // assert
        expect(result, null);
      });

      test('should return null when locale is not a string', () {
        // arrange
        when(() => mockBox.get(any())).thenReturn(123);

        // act
        final result = userPreferences.getLocaleCode();

        // assert
        expect(result, null);
      });
    });
  });
}
