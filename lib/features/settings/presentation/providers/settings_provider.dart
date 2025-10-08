import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_discovery_app/core/injection_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Keys for persistence
const _kThemeModeKey = 'settings.theme_mode'; // values: light|dark|system
const _kLocaleKey = 'settings.locale'; // e.g., en|uk|null

class SettingsState {
  final ThemeMode themeMode;
  final Locale? locale;
  final bool isLoading;
  final String? error;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale,
    this.isLoading = false,
    this.error,
  });

  const SettingsState.initial() : this();

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? isLoading,
    String? error,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final sharedPrefsProvider = Provider<SharedPreferences>((ref) => sl<SharedPreferences>());

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return SettingsNotifier(prefs)..loadSettings();
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs) : super(const SettingsState.initial());

  Future<void> loadSettings() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final themeString = _prefs.getString(_kThemeModeKey);
      final localeCode = _prefs.getString(_kLocaleKey);

      state = state.copyWith(
        themeMode: _parseTheme(themeString) ?? ThemeMode.system,
        locale: localeCode != null && localeCode.isNotEmpty ? Locale(localeCode) : null,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load settings: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _prefs.setString(_kThemeModeKey, _themeToString(mode));
      state = state.copyWith(themeMode: mode, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to save theme: $e');
    }
  }

  Future<void> toggleTheme() async {
    final next = state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }

  Future<void> setLocale(Locale? locale) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      if (locale == null) {
        await _prefs.remove(_kLocaleKey);
      } else {
        await _prefs.setString(_kLocaleKey, locale.languageCode);
      }
      state = state.copyWith(locale: locale, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to save locale: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  ThemeMode? _parseTheme(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }

  String _themeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
