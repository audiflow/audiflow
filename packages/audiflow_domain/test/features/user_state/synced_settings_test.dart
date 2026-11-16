import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late SharedPreferences prefs;
  late AppSettingsRepositoryImpl repository;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  Future<void> start([Map<String, Object> stored = const {}]) async {
    SharedPreferences.setMockInitialValues(stored);
    prefs = await SharedPreferences.getInstance();
    repository = AppSettingsRepositoryImpl(
      SharedPreferencesDataSource(prefs),
      isar: isar,
    );
  }

  setUp(() async {
    isar = await openTestIsar(isarSchemas);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  Future<SyncedSetting?> row(String key) => isar.syncedSettings.getByKey(key);

  test('synced settings are written to Isar and preferences', () async {
    await start();

    await repository.setPlaybackSpeed(1.5);
    await repository.setSkipForwardSeconds(45);
    await repository.setContinuousPlayback(false);
    await repository.setAutoPlayOrder(AutoPlayOrder.asDisplayed);

    check((await row(SettingsKeys.playbackSpeed))!.value).equals('1.5');
    check(
      (await row(SettingsKeys.skipForwardSeconds))!.hlc,
    ).not((it) => it.equals(0));
    check(prefs.getDouble(SettingsKeys.playbackSpeed)).equals(1.5);
    check(repository.getSkipForwardSeconds()).equals(45);
    check(repository.getContinuousPlayback()).isFalse();
    check(repository.getAutoPlayOrder()).equals(AutoPlayOrder.asDisplayed);
  });

  test('reads come from Isar once a row exists', () async {
    await start({SettingsKeys.skipBackwardSeconds: 15});
    check(repository.getSkipBackwardSeconds()).equals(15);

    // As a change arriving from another device would land.
    await isar.writeTxn(
      () => isar.syncedSettings.put(
        SyncedSetting()
          ..key = SettingsKeys.skipBackwardSeconds
          ..value = '20'
          ..hlc = 1,
      ),
    );

    check(repository.getSkipBackwardSeconds()).equals(20);
  });

  test('interruption behavior and sleep timer values sync', () async {
    await start();
    final sleep = SleepTimerPreferencesDatasource(
      SharedPreferencesDataSource(prefs),
      isar: isar,
    );

    await repository.setDuckInterruptionBehavior(
      DuckInterruptionBehavior.values.last,
    );
    await sleep.setLastMinutes(45);
    await sleep.setLastEpisodes(2);

    check(await row(SettingsKeys.duckInterruptionBehavior)).isNotNull();
    check(
      (await row(SleepTimerPreferencesDatasource.lastMinutesKey))!.value,
    ).equals('45');
    check(
      (await row(SleepTimerPreferencesDatasource.lastEpisodesKey))!.value,
    ).equals('2');

    // Reads come from Isar, not the SharedPreferences copy.
    await prefs.setInt(SleepTimerPreferencesDatasource.lastMinutesKey, 5);
    await prefs.setInt(SleepTimerPreferencesDatasource.lastEpisodesKey, 9);
    check(sleep.getLastMinutes()).equals(45);
    check(sleep.getLastEpisodes()).equals(2);
  });

  test('device-scoped settings stay out of Isar', () async {
    await start();

    await repository.setThemeMode(ThemeMode.dark);
    await repository.setWifiOnlyDownload(false);

    check(await isar.syncedSettings.count()).equals(0);
    check(repository.getThemeMode()).equals(ThemeMode.dark);
  });

  test('removing a synced setting keeps a stamped removal', () async {
    await start();
    await repository.setSearchCountry('jp');
    final before = (await row(SettingsKeys.searchCountry))!.hlc;

    await repository.setSearchCountry(null);

    final removed = (await row(SettingsKeys.searchCountry))!;
    check(removed.present).isFalse();
    check(Hlc.unpack(before).compareTo(Hlc.unpack(removed.hlc))).equals(-1);
    check(repository.getSearchCountry()).isNull();
    check(prefs.getString(SettingsKeys.searchCountry)).isNull();
  });

  test('an unchanged write keeps its stamp', () async {
    await start();
    await repository.setVoiceBoost(true);
    final first = (await row(SettingsKeys.voiceBoost))!.hlc;

    await repository.setVoiceBoost(true);

    check((await row(SettingsKeys.voiceBoost))!.hlc).equals(first);
  });

  test('the launch copy moves stored values once', () async {
    await start({
      SettingsKeys.playbackSpeed: 1.5,
      SettingsKeys.recentPlaybackSpeeds: '[1.5,2.0]',
      SettingsKeys.notifyNewEpisodes: false,
      SettingsKeys.themeMode: 'dark',
    });
    final store = SyncedSettingsStore(
      SharedPreferencesDataSource(prefs),
      isar: isar,
    );

    await store.copyFromPreferences(prefs.getKeys());
    final speed = (await row(SettingsKeys.playbackSpeed))!;
    await store.copyFromPreferences(prefs.getKeys());

    check(await isar.syncedSettings.count()).equals(3);
    check((await row(SettingsKeys.playbackSpeed))!.hlc).equals(speed.hlc);
    check(repository.getPlaybackSpeed()).equals(1.5);
    check(repository.getRecentPlaybackSpeeds()).deepEquals([1.5, 2.0]);
    check(repository.getNotifyNewEpisodes()).isFalse();
  });

  test('whole-number doubles read back as ints and doubles', () async {
    await start();
    await repository.setPlaybackSpeed(2);

    check(repository.getPlaybackSpeed()).equals(2.0);
    await repository.setAutoDownloadKeepCount(5);
    check(repository.getAutoDownloadKeepCount()).equals(5);
  });

  test('an int setting stored as a whole double reads as an int', () async {
    await start();
    // JSON from another platform may write 5 as 5.0.
    await isar.writeTxn(
      () => isar.syncedSettings.put(
        SyncedSetting()
          ..key = SettingsKeys.autoDownloadKeepCount
          ..value = '5.0'
          ..hlc = 1,
      ),
    );

    check(repository.getAutoDownloadKeepCount()).equals(5);
  });
}
