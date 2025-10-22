import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:movie_discovery_app/core/preferences/user_preferences.dart';
import 'package:movie_discovery_app/features/settings/presentation/providers/settings_provider.dart';

import 'settings_provider_test.mocks.dart';

@GenerateMocks([UserPreferences])
void main() {
  late SettingsNotifier notifier;
  late MockUserPreferences mockUserPreferences;

  setUp(() {
    mockUserPreferences = MockUserPreferences();
    notifier = SettingsNotifier(mockUserPreferences);
  });

  group('SettingsNotifier', () {
    test('initial state should be SettingsState.initial', () {
      expect(notifier.state, const SettingsState.initial());
    });

    test('should load settings successfully', () async {
      // arrange
      when(mockUserPreferences.getThemeModeString()).thenReturn('dark');
      when(mockUserPreferences.getLocaleCode()).thenReturn('en');

      // act
      await notifier.loadSettings();

      // assert
      expect(notifier.state.themeMode, ThemeMode.dark);
      expect(notifier.state.locale, const Locale('en'));
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, null);
    });

    test('should handle null theme mode and locale', () async {
      // arrange
      when(mockUserPreferences.getThemeModeString()).thenReturn(null);
      when(mockUserPreferences.getLocaleCode()).thenReturn(null);

      // act
      await notifier.loadSettings();

      // assert
      expect(notifier.state.themeMode, ThemeMode.system);
      expect(notifier.state.locale, null);
      expect(notifier.state.isLoading, false);
    });

    test('should set theme mode successfully', () async {
      // arrange
      when(mockUserPreferences.setThemeModeString(any))
          .thenAnswer((_) async => Future.value());

      // act
      await notifier.setThemeMode(ThemeMode.dark);

      // assert
      expect(notifier.state.themeMode, ThemeMode.dark);
      expect(notifier.state.isLoading, false);
      verify(mockUserPreferences.setThemeModeString('dark'));
    });

    test('should toggle theme from dark to light', () async {
      // arrange
      when(mockUserPreferences.getThemeModeString()).thenReturn('dark');
      when(mockUserPreferences.getLocaleCode()).thenReturn('en');
      when(mockUserPreferences.setThemeModeString(any))
          .thenAnswer((_) async => Future.value());
      await notifier.loadSettings();

      // act
      await notifier.toggleTheme();

      // assert
      expect(notifier.state.themeMode, ThemeMode.light);
      verify(mockUserPreferences.setThemeModeString('light'));
    });

    test('should toggle theme from light to dark', () async {
      // arrange
      when(mockUserPreferences.getThemeModeString()).thenReturn('light');
      when(mockUserPreferences.getLocaleCode()).thenReturn('en');
      when(mockUserPreferences.setThemeModeString(any))
          .thenAnswer((_) async => Future.value());
      await notifier.loadSettings();

      // act
      await notifier.toggleTheme();

      // assert
      expect(notifier.state.themeMode, ThemeMode.dark);
      verify(mockUserPreferences.setThemeModeString('dark'));
    });

    test('should set locale successfully', () async {
      // arrange
      when(mockUserPreferences.setLocaleCode(any))
          .thenAnswer((_) async => Future.value());

      // act
      await notifier.setLocale(const Locale('uk'));

      // assert
      expect(notifier.state.locale, const Locale('uk'));
      expect(notifier.state.isLoading, false);
      verify(mockUserPreferences.setLocaleCode('uk'));
    });

    test('should clear error', () async {
      // arrange
      when(mockUserPreferences.getThemeModeString()).thenThrow(Exception('Error'));
      await notifier.loadSettings();

      // act
      notifier.clearError();

      // assert
      expect(notifier.state.error, null);
    });
  });
}
