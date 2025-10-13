import 'package:hive_flutter/hive_flutter.dart';

/// A lightweight wrapper around a Hive box for storing user preferences.
/// Uses a single box named 'user_prefs' and string keys for values.
class UserPreferences {
  static const String boxName = 'user_prefs';

  // Keys
  static const String kThemeMode = 'settings.theme_mode'; // light|dark|system
  static const String kLocale = 'settings.locale'; // e.g. en|uk|null

  final Box _box;

  UserPreferences(this._box);

  // Theme
  Future<void> setThemeModeString(String value) async {
    await _box.put(kThemeMode, value);
  }

  String? getThemeModeString() {
    final v = _box.get(kThemeMode);
    return (v is String) ? v : null;
  }

  // Locale
  Future<void> setLocaleCode(String? code) async {
    if (code == null || code.isEmpty) {
      await _box.delete(kLocale);
    } else {
      await _box.put(kLocale, code);
    }
  }

  String? getLocaleCode() {
    final v = _box.get(kLocale);
    return (v is String && v.isNotEmpty) ? v : null;
  }
}
