import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late PlayOrderPreferenceLocalDatasource datasource;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([
      PodcastViewPreferenceSchema,
      SmartPlaylistUserPreferenceSchema,
      SmartPlaylistGroupUserPreferenceSchema,
    ]);
    datasource = PlayOrderPreferenceLocalDatasource(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('podcast play order', () {
    test('returns null when not set', () async {
      final result = await datasource.getPodcastPlayOrder(1);
      check(result).isNull();
    });

    test('stores and retrieves a value', () async {
      await datasource.setPodcastPlayOrder(1, 'oldestFirst');
      final result = await datasource.getPodcastPlayOrder(1);
      check(result).equals('oldestFirst');
    });

    test('updates existing value', () async {
      await datasource.setPodcastPlayOrder(1, 'oldestFirst');
      await datasource.setPodcastPlayOrder(1, 'asDisplayed');
      final result = await datasource.getPodcastPlayOrder(1);
      check(result).equals('asDisplayed');
    });

    test('clears value by setting null', () async {
      await datasource.setPodcastPlayOrder(1, 'oldestFirst');
      await datasource.setPodcastPlayOrder(1, null);
      final result = await datasource.getPodcastPlayOrder(1);
      check(result).isNull();
    });

    test('preserves other PodcastViewPreference fields when setting', () async {
      // Pre-populate with other fields.
      await isar.writeTxn(() async {
        await isar.podcastViewPreferences.put(
          PodcastViewPreference()
            ..podcastId = 1
            ..viewMode = 'seasons'
            ..episodeFilter = 'unplayed',
        );
      });

      await datasource.setPodcastPlayOrder(1, 'oldestFirst');

      final pref = await isar.podcastViewPreferences.getByPodcastId(1);
      check(pref).isNotNull();
      check(pref!.viewMode).equals('seasons');
      check(pref.episodeFilter).equals('unplayed');
      check(pref.autoPlayOrder).equals('oldestFirst');
    });

    test('independent preferences for different podcasts', () async {
      await datasource.setPodcastPlayOrder(1, 'oldestFirst');
      await datasource.setPodcastPlayOrder(2, 'asDisplayed');

      check(await datasource.getPodcastPlayOrder(1)).equals('oldestFirst');
      check(await datasource.getPodcastPlayOrder(2)).equals('asDisplayed');
    });
  });

  group('playlist play order', () {
    test('returns null when not set', () async {
      final result = await datasource.getPlaylistPlayOrder(1, 'pl1');
      check(result).isNull();
    });

    test('stores and retrieves a value', () async {
      await datasource.setPlaylistPlayOrder(1, 'pl1', 'oldestFirst');
      final result = await datasource.getPlaylistPlayOrder(1, 'pl1');
      check(result).equals('oldestFirst');
    });

    test('updates existing value', () async {
      await datasource.setPlaylistPlayOrder(1, 'pl1', 'oldestFirst');
      await datasource.setPlaylistPlayOrder(1, 'pl1', 'asDisplayed');
      final result = await datasource.getPlaylistPlayOrder(1, 'pl1');
      check(result).equals('asDisplayed');
    });

    test('clears value by setting null (deletes record)', () async {
      await datasource.setPlaylistPlayOrder(1, 'pl1', 'oldestFirst');
      await datasource.setPlaylistPlayOrder(1, 'pl1', null);
      final result = await datasource.getPlaylistPlayOrder(1, 'pl1');
      check(result).isNull();
    });

    test('independent preferences for different playlists', () async {
      await datasource.setPlaylistPlayOrder(1, 'pl1', 'oldestFirst');
      await datasource.setPlaylistPlayOrder(1, 'pl2', 'asDisplayed');

      check(
        await datasource.getPlaylistPlayOrder(1, 'pl1'),
      ).equals('oldestFirst');
      check(
        await datasource.getPlaylistPlayOrder(1, 'pl2'),
      ).equals('asDisplayed');
    });

    test('independent preferences for different podcasts', () async {
      await datasource.setPlaylistPlayOrder(1, 'pl1', 'oldestFirst');
      await datasource.setPlaylistPlayOrder(2, 'pl1', 'asDisplayed');

      check(
        await datasource.getPlaylistPlayOrder(1, 'pl1'),
      ).equals('oldestFirst');
      check(
        await datasource.getPlaylistPlayOrder(2, 'pl1'),
      ).equals('asDisplayed');
    });
  });

  group('group play order', () {
    test('returns null when not set', () async {
      final result = await datasource.getGroupPlayOrder(1, 'pl1', 'g1');
      check(result).isNull();
    });

    test('stores and retrieves a value', () async {
      await datasource.setGroupPlayOrder(1, 'pl1', 'g1', 'oldestFirst');
      final result = await datasource.getGroupPlayOrder(1, 'pl1', 'g1');
      check(result).equals('oldestFirst');
    });

    test('updates existing value', () async {
      await datasource.setGroupPlayOrder(1, 'pl1', 'g1', 'oldestFirst');
      await datasource.setGroupPlayOrder(1, 'pl1', 'g1', 'asDisplayed');
      final result = await datasource.getGroupPlayOrder(1, 'pl1', 'g1');
      check(result).equals('asDisplayed');
    });

    test('clears value by setting null (deletes record)', () async {
      await datasource.setGroupPlayOrder(1, 'pl1', 'g1', 'oldestFirst');
      await datasource.setGroupPlayOrder(1, 'pl1', 'g1', null);
      final result = await datasource.getGroupPlayOrder(1, 'pl1', 'g1');
      check(result).isNull();
    });

    test('independent preferences for different groups', () async {
      await datasource.setGroupPlayOrder(1, 'pl1', 'g1', 'oldestFirst');
      await datasource.setGroupPlayOrder(1, 'pl1', 'g2', 'asDisplayed');

      check(
        await datasource.getGroupPlayOrder(1, 'pl1', 'g1'),
      ).equals('oldestFirst');
      check(
        await datasource.getGroupPlayOrder(1, 'pl1', 'g2'),
      ).equals('asDisplayed');
    });

    test('independent preferences for different playlists', () async {
      await datasource.setGroupPlayOrder(1, 'pl1', 'g1', 'oldestFirst');
      await datasource.setGroupPlayOrder(1, 'pl2', 'g1', 'asDisplayed');

      check(
        await datasource.getGroupPlayOrder(1, 'pl1', 'g1'),
      ).equals('oldestFirst');
      check(
        await datasource.getGroupPlayOrder(1, 'pl2', 'g1'),
      ).equals('asDisplayed');
    });
  });
}
