import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([StationSchema]);
  });

  tearDown(() => isar.close(deleteFromDisk: true));

  test('Station persists with default filter values', () async {
    final now = DateTime(2026, 3, 20);
    final station = Station()
      ..name = 'My Station'
      ..createdAt = now
      ..updatedAt = now;

    await isar.writeTxn(() => isar.stations.put(station));

    final loaded = await isar.stations.get(station.id);
    check(loaded).isNotNull();
    check(loaded!.name).equals('My Station');
    check(loaded.sortOrder).equals(0);
    check(loaded.episodeSortType).equals('newest');
    check(loaded.hideCompleted).isFalse();
    check(loaded.filterDownloaded).isFalse();
    check(loaded.filterFavorited).isFalse();
    check(loaded.durationFilter).isNull();
    check(loaded.publishedWithinDays).isNull();
    check(loaded.episodeSort).equals(StationEpisodeSort.newest);
  });

  test('Station persists with all filters configured', () async {
    final now = DateTime(2026, 3, 20);
    final station = Station()
      ..name = 'Filtered Station'
      ..hideCompleted = true
      ..filterDownloaded = true
      ..filterFavorited = true
      ..durationFilter = (StationDurationFilter()
        ..durationOperator = 'shorterThan'
        ..durationMinutes = 15)
      ..publishedWithinDays = 7
      ..createdAt = now
      ..updatedAt = now;

    await isar.writeTxn(() => isar.stations.put(station));

    final loaded = await isar.stations.get(station.id);
    check(loaded).isNotNull();
    check(loaded!.hideCompleted).isTrue();
    check(loaded.filterDownloaded).isTrue();
    check(loaded.filterFavorited).isTrue();
    check(loaded.durationFilter).isNotNull();
    check(loaded.durationFilter!.durationOperator).equals('shorterThan');
    check(loaded.durationFilter!.durationMinutes).equals(15);
    check(loaded.publishedWithinDays).equals(7);
  });

  test('Station persists v2 fields with defaults', () async {
    final now = DateTime(2026, 3, 20);
    final station = Station()
      ..name = 'V2 Station'
      ..createdAt = now
      ..updatedAt = now;

    await isar.writeTxn(() => isar.stations.put(station));
    final loaded = await isar.stations.get(station.id);
    check(loaded).isNotNull();
    check(loaded!.defaultEpisodeLimit).equals(3);
    check(loaded.groupByPodcast).isFalse();
    check(loaded.podcastSortType).equals('manual');
    check(loaded.podcastSort).equals(StationPodcastSort.manual);
  });

  test('Station persists v2 fields configured', () async {
    final now = DateTime(2026, 3, 20);
    final station = Station()
      ..name = 'Configured'
      ..defaultEpisodeLimit = 10
      ..groupByPodcast = true
      ..podcastSort = StationPodcastSort.nameAsc
      ..createdAt = now
      ..updatedAt = now;

    await isar.writeTxn(() => isar.stations.put(station));
    final loaded = await isar.stations.get(station.id);
    check(loaded).isNotNull();
    check(loaded!.defaultEpisodeLimit).equals(10);
    check(loaded.groupByPodcast).isTrue();
    check(loaded.podcastSort).equals(StationPodcastSort.nameAsc);
  });

  test('Station persists null defaultEpisodeLimit for all', () async {
    final now = DateTime(2026, 3, 20);
    final station = Station()
      ..name = 'All Eps'
      ..defaultEpisodeLimit = null
      ..createdAt = now
      ..updatedAt = now;

    await isar.writeTxn(() => isar.stations.put(station));
    final loaded = await isar.stations.get(station.id);
    check(loaded).isNotNull();
    check(loaded!.defaultEpisodeLimit).isNull();
  });
}
