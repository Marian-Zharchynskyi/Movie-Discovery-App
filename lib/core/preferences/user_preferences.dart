import 'package:hive_flutter/hive_flutter.dart';

class UserPreferences {
  static const String boxName = 'user_prefs';
  static const String kThemeMode = 'settings.theme_mode';
  static const String kLocale = 'settings.locale';

  final Box _box;

  UserPreferences(this._box);

  Future<void> setThemeModeString(String value) async {
    await _box.put(kThemeMode, value);
  }

  String? getThemeModeString() {
    final v = _box.get(kThemeMode);
    return (v is String) ? v : null;
  }

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
