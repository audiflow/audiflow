import 'package:audiflow_app/app/background/background_settings_repository.dart';
import 'package:audiflow_app/app/background/background_task_registrar.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackgroundSettingsRepository', () {
    group('with populated data', () {
      late BackgroundSettingsRepository repository;

      setUp(() {
        repository = BackgroundSettingsRepository({
          BackgroundInputKeys.autoSync: false,
          BackgroundInputKeys.wifiOnlySync: true,
          BackgroundInputKeys.syncIntervalMinutes: 120,
          BackgroundInputKeys.notifyNewEpisodes: false,
          BackgroundInputKeys.wifiOnlyDownload: false,
        });
      });

      test('getAutoSync returns value from data', () {
        check(repository.getAutoSync()).equals(false);
      });

      test('getWifiOnlySync returns value from data', () {
        check(repository.getWifiOnlySync()).equals(true);
      });

      test('getSyncIntervalMinutes returns value from data', () {
        check(repository.getSyncIntervalMinutes()).equals(120);
      });

      test('getNotifyNewEpisodes returns value from data', () {
        check(repository.getNotifyNewEpisodes()).equals(false);
      });

      test('getWifiOnlyDownload returns value from data', () {
        check(repository.getWifiOnlyDownload()).equals(false);
      });
    });

    group('with null data', () {
      late BackgroundSettingsRepository repository;

      setUp(() {
        repository = BackgroundSettingsRepository(null);
      });

      test('getAutoSync returns default', () {
        check(repository.getAutoSync()).equals(SettingsDefaults.autoSync);
      });

      test('getWifiOnlySync returns default', () {
        check(
          repository.getWifiOnlySync(),
        ).equals(SettingsDefaults.wifiOnlySync);
      });

      test('getSyncIntervalMinutes returns default', () {
        check(
          repository.getSyncIntervalMinutes(),
        ).equals(SettingsDefaults.syncIntervalMinutes);
      });

      test('getNotifyNewEpisodes returns default', () {
        check(
          repository.getNotifyNewEpisodes(),
        ).equals(SettingsDefaults.notifyNewEpisodes);
      });

      test('getWifiOnlyDownload returns default', () {
        check(
          repository.getWifiOnlyDownload(),
        ).equals(SettingsDefaults.wifiOnlyDownload);
      });
    });

    group('with empty data', () {
      late BackgroundSettingsRepository repository;

      setUp(() {
        repository = BackgroundSettingsRepository({});
      });

      test('getAutoSync falls back to default', () {
        check(repository.getAutoSync()).equals(SettingsDefaults.autoSync);
      });

      test('getSyncIntervalMinutes falls back to default', () {
        check(
          repository.getSyncIntervalMinutes(),
        ).equals(SettingsDefaults.syncIntervalMinutes);
      });
    });

    group('unused settings return defaults', () {
      late BackgroundSettingsRepository repository;

      setUp(() {
        repository = BackgroundSettingsRepository(null);
      });

      test('getTextScale returns default', () {
        check(repository.getTextScale()).equals(SettingsDefaults.textScale);
      });

      test('getPlaybackSpeed returns default', () {
        check(
          repository.getPlaybackSpeed(),
        ).equals(SettingsDefaults.playbackSpeed);
      });

      test('getSkipForwardSeconds returns default', () {
        check(
          repository.getSkipForwardSeconds(),
        ).equals(SettingsDefaults.skipForwardSeconds);
      });

      test('getSkipBackwardSeconds returns default', () {
        check(
          repository.getSkipBackwardSeconds(),
        ).equals(SettingsDefaults.skipBackwardSeconds);
      });

      test('getAutoCompleteThreshold returns default', () {
        check(
          repository.getAutoCompleteThreshold(),
        ).equals(SettingsDefaults.autoCompleteThreshold);
      });

      test('getContinuousPlayback returns default', () {
        check(
          repository.getContinuousPlayback(),
        ).equals(SettingsDefaults.continuousPlayback);
      });

      test('getAutoPlayOrder returns default', () {
        check(
          repository.getAutoPlayOrder(),
        ).equals(SettingsDefaults.autoPlayOrder);
      });

      test('getAutoDeletePlayed returns default', () {
        check(
          repository.getAutoDeletePlayed(),
        ).equals(SettingsDefaults.autoDeletePlayed);
      });

      test('getMaxConcurrentDownloads returns default', () {
        check(
          repository.getMaxConcurrentDownloads(),
        ).equals(SettingsDefaults.maxConcurrentDownloads);
      });

      test('getLastTabIndex returns default', () {
        check(
          repository.getLastTabIndex(),
        ).equals(SettingsDefaults.lastTabIndex);
      });

      test('getVoiceEnabled returns default', () {
        check(
          repository.getVoiceEnabled(),
        ).equals(SettingsDefaults.voiceEnabled);
      });

      test('getLocale returns null', () {
        check(repository.getLocale()).isNull();
      });

      test('getSearchCountry returns null', () {
        check(repository.getSearchCountry()).isNull();
      });
    });

    group('setters throw UnsupportedError', () {
      late BackgroundSettingsRepository repository;

      setUp(() {
        repository = BackgroundSettingsRepository(null);
      });

      test('setAutoSync throws', () {
        check(() => repository.setAutoSync(true)).throws<UnsupportedError>();
      });

      test('setSyncIntervalMinutes throws', () {
        check(
          () => repository.setSyncIntervalMinutes(30),
        ).throws<UnsupportedError>();
      });

      test('setWifiOnlySync throws', () {
        check(
          () => repository.setWifiOnlySync(true),
        ).throws<UnsupportedError>();
      });

      test('setNotifyNewEpisodes throws', () {
        check(
          () => repository.setNotifyNewEpisodes(false),
        ).throws<UnsupportedError>();
      });

      test('setThemeMode throws', () {
        check(
          () => repository.setThemeMode(ThemeMode.dark),
        ).throws<UnsupportedError>();
      });

      test('clearAll throws', () {
        check(() => repository.clearAll()).throws<UnsupportedError>();
      });
    });
  });
}
