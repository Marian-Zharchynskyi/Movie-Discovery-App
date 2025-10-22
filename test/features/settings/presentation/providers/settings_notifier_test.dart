import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/preferences/user_preferences.dart';
import 'package:movie_discovery_app/features/settings/presentation/providers/settings_provider.dart';

class MockUserPreferences extends Mock implements UserPreferences {}

void main() {
  late SettingsNotifier settingsNotifier;
  late MockUserPreferences mockUserPreferences;

  setUp(() {
    mockUserPreferences = MockUserPreferences();
    settingsNotifier = SettingsNotifier(mockUserPreferences);
  });

  tearDown(() {
    settingsNotifier.dispose();
  });

  group('SettingsNotifier', () {
    test('initial state should have default values', () {
      expect(settingsNotifier.state.themeMode, ThemeMode.system);
      expect(settingsNotifier.state.locale, null);
      expect(settingsNotifier.state.isLoading, false);
      expect(settingsNotifier.state.error, null);
    });

    group('loadSettings', () {
      test('should load theme and locale from preferences', () async {
        // arrange
        when(() => mockUserPreferences.getThemeModeString()).thenReturn('dark');
        when(() => mockUserPreferences.getLocaleCode()).thenReturn('uk');

        // act
        await settingsNotifier.loadSettings();

        // assert
        expect(settingsNotifier.state.themeMode, ThemeMode.dark);
        expect(settingsNotifier.state.locale, const Locale('uk'));
        expect(settingsNotifier.state.isLoading, false);
        expect(settingsNotifier.state.error, null);
      });

      test('should use system theme when no preference is set', () async {
        // arrange
        when(() => mockUserPreferences.getThemeModeString()).thenReturn(null);
        when(() => mockUserPreferences.getLocaleCode()).thenReturn(null);

        // act
        await settingsNotifier.loadSettings();

        // assert
        expect(settingsNotifier.state.themeMode, ThemeMode.system);
        expect(settingsNotifier.state.locale, null);
      });

      test('should handle light theme', () async {
        // arrange
        when(() => mockUserPreferences.getThemeModeString()).thenReturn('light');
        when(() => mockUserPreferences.getLocaleCode()).thenReturn(null);

        // act
        await settingsNotifier.loadSettings();

        // assert
        expect(settingsNotifier.state.themeMode, ThemeMode.light);
      });

      test('should handle system theme explicitly', () async {
        // arrange
        when(() => mockUserPreferences.getThemeModeString()).thenReturn('system');
        when(() => mockUserPreferences.getLocaleCode()).thenReturn(null);

        // act
        await settingsNotifier.loadSettings();

        // assert
        expect(settingsNotifier.state.themeMode, ThemeMode.system);
      });

      test('should handle empty locale code', () async {
        // arrange
        when(() => mockUserPreferences.getThemeModeString()).thenReturn('dark');
        when(() => mockUserPreferences.getLocaleCode()).thenReturn('');

        // act
        await settingsNotifier.loadSettings();

        // assert
        expect(settingsNotifier.state.locale, null);
      });

      test('should set error when loading fails', () async {
        // arrange
        when(() => mockUserPreferences.getThemeModeString())
            .thenThrow(Exception('Storage error'));

        // act
        await settingsNotifier.loadSettings();

        // assert
        expect(settingsNotifier.state.isLoading, false);
        expect(settingsNotifier.state.error, contains('Failed to load settings'));
      });
    });

    group('setThemeMode', () {
      test('should set dark theme', () async {
        // arrange
        when(() => mockUserPreferences.setThemeModeString(any()))
            .thenAnswer((_) async => Future.value());

        // act
        await settingsNotifier.setThemeMode(ThemeMode.dark);

        // assert
        expect(settingsNotifier.state.themeMode, ThemeMode.dark);
        verify(() => mockUserPreferences.setThemeModeString('dark')).called(1);
      });

      test('should set light theme', () async {
        // arrange
        when(() => mockUserPreferences.setThemeModeString(any()))
            .thenAnswer((_) async => Future.value());

        // act
        await settingsNotifier.setThemeMode(ThemeMode.light);

        // assert
        expect(settingsNotifier.state.themeMode, ThemeMode.light);
        verify(() => mockUserPreferences.setThemeModeString('light')).called(1);
      });

      test('should set system theme', () async {
        // arrange
        when(() => mockUserPreferences.setThemeModeString(any()))
            .thenAnswer((_) async => Future.value());

        // act
        await settingsNotifier.setThemeMode(ThemeMode.system);

        // assert
        expect(settingsNotifier.state.themeMode, ThemeMode.system);
        verify(() => mockUserPreferences.setThemeModeString('system')).called(1);
      });

      test('should set error when saving theme fails', () async {
        // arrange
        when(() => mockUserPreferences.setThemeModeString(any()))
            .thenThrow(Exception('Storage error'));

        // act
        await settingsNotifier.setThemeMode(ThemeMode.dark);

        // assert
        expect(settingsNotifier.state.error, contains('Failed to save theme'));
      });
    });

    group('toggleTheme', () {
      test('should toggle from dark to light', () async {
        // arrange
        when(() => mockUserPreferences.setThemeModeString(any()))
            .thenAnswer((_) async => Future.value());
        when(() => mockUserPreferences.getThemeModeString()).thenReturn('dark');
        when(() => mockUserPreferences.getLocaleCode()).thenReturn(null);

        await settingsNotifier.loadSettings();

        // act
        await settingsNotifier.toggleTheme();

        // assert
        expect(settingsNotifier.state.themeMode, ThemeMode.light);
      });

      test('should toggle from light to dark', () async {
        // arrange
        when(() => mockUserPreferences.setThemeModeString(any()))
            .thenAnswer((_) async => Future.value());
        when(() => mockUserPreferences.getThemeModeString()).thenReturn('light');
        when(() => mockUserPreferences.getLocaleCode()).thenReturn(null);

        await settingsNotifier.loadSettings();

        // act
        await settingsNotifier.toggleTheme();

        // assert
        expect(settingsNotifier.state.themeMode, ThemeMode.dark);
      });
    });

    group('setLocale', () {
      test('should set locale', () async {
        // arrange
        when(() => mockUserPreferences.setLocaleCode(any()))
            .thenAnswer((_) async => Future.value());

        // act
        await settingsNotifier.setLocale(const Locale('uk'));

        // assert
        expect(settingsNotifier.state.locale, const Locale('uk'));
        verify(() => mockUserPreferences.setLocaleCode('uk')).called(1);
      });

      test('should clear locale when null', () async {
        // arrange
        when(() => mockUserPreferences.setLocaleCode(any()))
            .thenAnswer((_) async => Future.value());

        // act
        await settingsNotifier.setLocale(null);

        // assert
        expect(settingsNotifier.state.locale, null);
        verify(() => mockUserPreferences.setLocaleCode(null)).called(1);
      });

      test('should set error when saving locale fails', () async {
        // arrange
        when(() => mockUserPreferences.setLocaleCode(any()))
            .thenThrow(Exception('Storage error'));

        // act
        await settingsNotifier.setLocale(const Locale('en'));

        // assert
        expect(settingsNotifier.state.error, contains('Failed to save locale'));
      });
    });

    group('clearError', () {
      test('should clear error message', () async {
        // arrange
        when(() => mockUserPreferences.getThemeModeString())
            .thenThrow(Exception('Error'));
        await settingsNotifier.loadSettings();

        // act
        settingsNotifier.clearError();

        // assert
        expect(settingsNotifier.state.error, null);
      });
    });
  });
}
