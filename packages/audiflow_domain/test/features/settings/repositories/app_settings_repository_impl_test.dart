import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/src/common/datasources/shared_preferences_datasource.dart';
import 'package:audiflow_domain/src/features/settings/repositories/app_settings_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferencesDataSource dataSource;
  late AppSettingsRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    dataSource = SharedPreferencesDataSource(prefs);
    repository = AppSettingsRepositoryImpl(dataSource);
  });

  group('ThemeMode', () {
    test('returns system as default when no value stored', () {
      expect(repository.getThemeMode(), ThemeMode.system);
    });

    test('persists and reads light mode', () async {
      await repository.setThemeMode(ThemeMode.light);
      expect(repository.getThemeMode(), ThemeMode.light);
    });

    test('persists and reads dark mode', () async {
      await repository.setThemeMode(ThemeMode.dark);
      expect(repository.getThemeMode(), ThemeMode.dark);
    });

    test('persists and reads system mode', () async {
      await repository.setThemeMode(ThemeMode.system);
      expect(repository.getThemeMode(), ThemeMode.system);
    });
  });

  group('Locale', () {
    test('returns null as default when no value stored', () {
      expect(repository.getLocale(), isNull);
    });

    test('persists and reads locale value', () async {
      await repository.setLocale('ja');
      expect(repository.getLocale(), 'ja');
    });

    test('clears locale when set to null', () async {
      await repository.setLocale('en');
      expect(repository.getLocale(), 'en');

      await repository.setLocale(null);
      expect(repository.getLocale(), isNull);
    });
  });

  group('TextScale', () {
    test('returns default when no value stored', () {
      expect(repository.getTextScale(), SettingsDefaults.textScale);
    });

    test('persists and reads text scale', () async {
      await repository.setTextScale(1.5);
      expect(repository.getTextScale(), 1.5);
    });
  });

  group('PlaybackSpeed', () {
    test('returns default when no value stored', () {
      expect(repository.getPlaybackSpeed(), SettingsDefaults.playbackSpeed);
    });

    test('persists and reads playback speed', () async {
      await repository.setPlaybackSpeed(2.0);
      expect(repository.getPlaybackSpeed(), 2.0);
    });
  });

  group('SkipForwardSeconds', () {
    test('returns default when no value stored', () {
      expect(
        repository.getSkipForwardSeconds(),
        SettingsDefaults.skipForwardSeconds,
      );
    });

    test('persists and reads skip forward seconds', () async {
      await repository.setSkipForwardSeconds(15);
      expect(repository.getSkipForwardSeconds(), 15);
    });
  });

  group('SkipBackwardSeconds', () {
    test('returns default when no value stored', () {
      expect(
        repository.getSkipBackwardSeconds(),
        SettingsDefaults.skipBackwardSeconds,
      );
    });

    test('persists and reads skip backward seconds', () async {
      await repository.setSkipBackwardSeconds(5);
      expect(repository.getSkipBackwardSeconds(), 5);
    });
  });

  group('AutoCompleteThreshold', () {
    test('returns default when no value stored', () {
      expect(
        repository.getAutoCompleteThreshold(),
        SettingsDefaults.autoCompleteThreshold,
      );
    });

    test('persists and reads threshold', () async {
      await repository.setAutoCompleteThreshold(0.9);
      expect(repository.getAutoCompleteThreshold(), 0.9);
    });
  });

  group('ContinuousPlayback', () {
    test('returns default when no value stored', () {
      expect(
        repository.getContinuousPlayback(),
        SettingsDefaults.continuousPlayback,
      );
    });

    test('persists and reads continuous playback', () async {
      await repository.setContinuousPlayback(false);
      expect(repository.getContinuousPlayback(), false);
    });
  });

  group('AutoPlayOrder', () {
    test('returns default when no value stored', () {
      expect(repository.getAutoPlayOrder(), SettingsDefaults.autoPlayOrder);
    });

    test('persists and reads oldestFirst', () async {
      await repository.setAutoPlayOrder(AutoPlayOrder.oldestFirst);
      expect(repository.getAutoPlayOrder(), AutoPlayOrder.oldestFirst);
    });

    test('persists and reads asDisplayed', () async {
      await repository.setAutoPlayOrder(AutoPlayOrder.asDisplayed);
      expect(repository.getAutoPlayOrder(), AutoPlayOrder.asDisplayed);
    });

    test('returns default for unknown stored value', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(SettingsKeys.autoPlayOrder, 'unknown');
      expect(repository.getAutoPlayOrder(), SettingsDefaults.autoPlayOrder);
    });
  });

  group('DuckInterruptionBehavior', () {
    test('returns default (duck) when no value stored', () {
      expect(
        repository.getDuckInterruptionBehavior(),
        SettingsDefaults.duckInterruptionBehavior,
      );
      expect(
        SettingsDefaults.duckInterruptionBehavior,
        DuckInterruptionBehavior.duck,
      );
    });

    test('persists and reads duck', () async {
      await repository.setDuckInterruptionBehavior(
        DuckInterruptionBehavior.duck,
      );
      expect(
        repository.getDuckInterruptionBehavior(),
        DuckInterruptionBehavior.duck,
      );
    });

    test('persists and reads pause', () async {
      await repository.setDuckInterruptionBehavior(
        DuckInterruptionBehavior.pause,
      );
      expect(
        repository.getDuckInterruptionBehavior(),
        DuckInterruptionBehavior.pause,
      );
    });

    test('returns default for unknown stored value', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        SettingsKeys.duckInterruptionBehavior,
        'something-else',
      );
      expect(
        repository.getDuckInterruptionBehavior(),
        SettingsDefaults.duckInterruptionBehavior,
      );
    });
  });

  group('WifiOnlyDownload', () {
    test('returns default when no value stored', () {
      expect(
        repository.getWifiOnlyDownload(),
        SettingsDefaults.wifiOnlyDownload,
      );
    });

    test('persists and reads wifi only download', () async {
      await repository.setWifiOnlyDownload(false);
      expect(repository.getWifiOnlyDownload(), false);
    });
  });

  group('AutoDeletePlayed', () {
    test('returns default when no value stored', () {
      expect(
        repository.getAutoDeletePlayed(),
        SettingsDefaults.autoDeletePlayed,
      );
    });

    test('persists and reads auto delete played', () async {
      await repository.setAutoDeletePlayed(true);
      expect(repository.getAutoDeletePlayed(), true);
    });
  });

  group('MaxConcurrentDownloads', () {
    test('returns default when no value stored', () {
      expect(
        repository.getMaxConcurrentDownloads(),
        SettingsDefaults.maxConcurrentDownloads,
      );
    });

    test('persists and reads max concurrent downloads', () async {
      await repository.setMaxConcurrentDownloads(3);
      expect(repository.getMaxConcurrentDownloads(), 3);
    });
  });

  group('AutoSync', () {
    test('returns default when no value stored', () {
      expect(repository.getAutoSync(), SettingsDefaults.autoSync);
    });

    test('persists and reads auto sync', () async {
      await repository.setAutoSync(false);
      expect(repository.getAutoSync(), false);
    });
  });

  group('SyncIntervalMinutes', () {
    test('returns default when no value stored', () {
      expect(
        repository.getSyncIntervalMinutes(),
        SettingsDefaults.syncIntervalMinutes,
      );
    });

    test('persists and reads sync interval', () async {
      await repository.setSyncIntervalMinutes(120);
      expect(repository.getSyncIntervalMinutes(), 120);
    });
  });

  group('WifiOnlySync', () {
    test('returns default when no value stored', () {
      expect(repository.getWifiOnlySync(), SettingsDefaults.wifiOnlySync);
    });

    test('persists and reads wifi only sync', () async {
      await repository.setWifiOnlySync(true);
      expect(repository.getWifiOnlySync(), true);
    });
  });

  group('notifyNewEpisodes', () {
    test('returns default true when no value stored', () {
      final result = repository.getNotifyNewEpisodes();
      expect(result, isTrue);
    });

    test('returns stored value', () async {
      await repository.setNotifyNewEpisodes(false);
      expect(repository.getNotifyNewEpisodes(), isFalse);
    });

    test('clearAll resets to default', () async {
      await repository.setNotifyNewEpisodes(false);
      await repository.clearAll();
      expect(repository.getNotifyNewEpisodes(), isTrue);
    });
  });

  group('Search country', () {
    test('getSearchCountry returns null when not set', () {
      expect(repository.getSearchCountry(), isNull);
    });

    test(
      'setSearchCountry persists and getSearchCountry retrieves it',
      () async {
        await repository.setSearchCountry('jp');
        expect(repository.getSearchCountry(), 'jp');
      },
    );

    test('setSearchCountry with null clears the value', () async {
      await repository.setSearchCountry('gb');
      await repository.setSearchCountry(null);
      expect(repository.getSearchCountry(), isNull);
    });

    test('setSearchCountry normalizes input to lowercase', () async {
      await repository.setSearchCountry(' JP ');
      expect(repository.getSearchCountry(), 'jp');
    });

    test('setSearchCountry ignores invalid codes', () async {
      await repository.setSearchCountry('jp');
      await repository.setSearchCountry('abc');
      expect(repository.getSearchCountry(), 'jp');

      await repository.setSearchCountry('');
      expect(repository.getSearchCountry(), 'jp');

      await repository.setSearchCountry('1');
      expect(repository.getSearchCountry(), 'jp');
    });

    test('clearAll removes search country', () async {
      await repository.setSearchCountry('de');
      await repository.clearAll();
      expect(repository.getSearchCountry(), isNull);
    });
  });

  group('clearAll', () {
    test('restores all settings to defaults', () async {
      // Set several values
      await repository.setThemeMode(ThemeMode.dark);
      await repository.setLocale('ja');
      await repository.setPlaybackSpeed(1.5);
      await repository.setSkipForwardSeconds(15);
      await repository.setWifiOnlyDownload(false);
      await repository.setAutoSync(false);

      // Verify they are persisted
      expect(repository.getThemeMode(), ThemeMode.dark);
      expect(repository.getLocale(), 'ja');
      expect(repository.getPlaybackSpeed(), 1.5);
      expect(repository.getSkipForwardSeconds(), 15);
      expect(repository.getWifiOnlyDownload(), false);
      expect(repository.getAutoSync(), false);

      // Clear all
      await repository.clearAll();

      // Verify defaults restored
      expect(repository.getThemeMode(), ThemeMode.system);
      expect(repository.getLocale(), isNull);
      expect(repository.getPlaybackSpeed(), SettingsDefaults.playbackSpeed);
      expect(
        repository.getSkipForwardSeconds(),
        SettingsDefaults.skipForwardSeconds,
      );
      expect(
        repository.getWifiOnlyDownload(),
        SettingsDefaults.wifiOnlyDownload,
      );
      expect(repository.getAutoSync(), SettingsDefaults.autoSync);
    });
  });
}
