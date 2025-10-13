import 'package:movie_discovery_app/core/preferences/user_preferences.dart';

abstract class ProfileLocalDataSource {
  Future<void> setThemeMode(String mode);
  String? getThemeMode();
  Future<void> setLocaleCode(String? code);
  String? getLocaleCode();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final UserPreferences prefs;
  ProfileLocalDataSourceImpl({required this.prefs});

  @override
  String? getLocaleCode() => prefs.getLocaleCode();

  @override
  String? getThemeMode() => prefs.getThemeModeString();

  @override
  Future<void> setLocaleCode(String? code) => prefs.setLocaleCode(code);

  @override
  Future<void> setThemeMode(String mode) => prefs.setThemeModeString(mode);
}
