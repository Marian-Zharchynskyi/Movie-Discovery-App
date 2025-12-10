import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:movie_discovery_app/core/preferences/user_preferences.dart';
import 'package:movie_discovery_app/features/profile/data/datasources/profile_local_data_source.dart';

import 'profile_local_data_source_test.mocks.dart';

@GenerateMocks([UserPreferences])
void main() {
  late ProfileLocalDataSourceImpl dataSource;
  late MockUserPreferences mockPreferences;

  setUp(() {
    mockPreferences = MockUserPreferences();
    dataSource = ProfileLocalDataSourceImpl(prefs: mockPreferences);
  });

  group('ProfileLocalDataSource', () {
    const tThemeMode = 'dark';
    const tLocaleCode = 'uk';

    group('getThemeMode', () {
      test('should return theme mode from preferences', () {
        // arrange
        when(mockPreferences.getThemeModeString()).thenReturn(tThemeMode);

        // act
        final result = dataSource.getThemeMode();

        // assert
        expect(result, tThemeMode);
        verify(mockPreferences.getThemeModeString());
        verifyNoMoreInteractions(mockPreferences);
      });

      test('should return null when no theme mode is set', () {
        // arrange
        when(mockPreferences.getThemeModeString()).thenReturn(null);

        // act
        final result = dataSource.getThemeMode();

        // assert
        expect(result, null);
        verify(mockPreferences.getThemeModeString());
      });
    });

    group('setThemeMode', () {
      test('should call preferences to set theme mode', () async {
        // arrange
        when(mockPreferences.setThemeModeString(any))
            .thenAnswer((_) async => Future.value());

        // act
        await dataSource.setThemeMode(tThemeMode);

        // assert
        verify(mockPreferences.setThemeModeString(tThemeMode));
        verifyNoMoreInteractions(mockPreferences);
      });
    });

    group('getLocaleCode', () {
      test('should return locale code from preferences', () {
        // arrange
        when(mockPreferences.getLocaleCode()).thenReturn(tLocaleCode);

        // act
        final result = dataSource.getLocaleCode();

        // assert
        expect(result, tLocaleCode);
        verify(mockPreferences.getLocaleCode());
        verifyNoMoreInteractions(mockPreferences);
      });

      test('should return null when no locale code is set', () {
        // arrange
        when(mockPreferences.getLocaleCode()).thenReturn(null);

        // act
        final result = dataSource.getLocaleCode();

        // assert
        expect(result, null);
        verify(mockPreferences.getLocaleCode());
      });
    });

    group('setLocaleCode', () {
      test('should call preferences to set locale code', () async {
        // arrange
        when(mockPreferences.setLocaleCode(any))
            .thenAnswer((_) async => Future.value());

        // act
        await dataSource.setLocaleCode(tLocaleCode);

        // assert
        verify(mockPreferences.setLocaleCode(tLocaleCode));
        verifyNoMoreInteractions(mockPreferences);
      });

      test('should handle null locale code', () async {
        // arrange
        when(mockPreferences.setLocaleCode(null))
            .thenAnswer((_) async => Future.value());

        // act
        await dataSource.setLocaleCode(null);

        // assert
        verify(mockPreferences.setLocaleCode(null));
        verifyNoMoreInteractions(mockPreferences);
      });
    });
  });
}
