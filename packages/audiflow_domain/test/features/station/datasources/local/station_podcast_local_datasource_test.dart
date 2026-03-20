import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late StationPodcastLocalDatasource datasource;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([StationPodcastSchema]);
    datasource = StationPodcastLocalDatasource(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  StationPodcast makeLink({required int stationId, required int podcastId}) {
    return StationPodcast()
      ..stationId = stationId
      ..podcastId = podcastId
      ..addedAt = DateTime(2026, 3, 20);
  }

  group('insert and getByStation', () {
    test('returns inserted links for station', () async {
      await datasource.insert(makeLink(stationId: 1, podcastId: 10));
      await datasource.insert(makeLink(stationId: 1, podcastId: 20));
      await datasource.insert(makeLink(stationId: 2, podcastId: 10));

      final links = await datasource.getByStation(1);

      check(links).length.equals(2);
      check(
        links.map((l) => l.podcastId).toList(),
      ).containsEqualInOrder([10, 20]);
    });

    test('duplicate insert is ignored', () async {
      await datasource.insert(makeLink(stationId: 1, podcastId: 10));
      await datasource.insert(makeLink(stationId: 1, podcastId: 10));

      final links = await datasource.getByStation(1);

      check(links).length.equals(1);
    });
  });

  group('delete', () {
    test('removes specific stationId+podcastId pair', () async {
      await datasource.insert(makeLink(stationId: 1, podcastId: 10));
      await datasource.insert(makeLink(stationId: 1, podcastId: 20));

      await datasource.delete(1, 10);

      final links = await datasource.getByStation(1);
      check(links).length.equals(1);
      check(links.first.podcastId).equals(20);
    });

    test('does not affect other station links', () async {
      await datasource.insert(makeLink(stationId: 1, podcastId: 10));
      await datasource.insert(makeLink(stationId: 2, podcastId: 10));

      await datasource.delete(1, 10);

      final station2Links = await datasource.getByStation(2);
      check(station2Links).length.equals(1);
    });
  });

  group('deleteAllForStation', () {
    test('removes all links for the specified station', () async {
      await datasource.insert(makeLink(stationId: 1, podcastId: 10));
      await datasource.insert(makeLink(stationId: 1, podcastId: 20));
      await datasource.insert(makeLink(stationId: 2, podcastId: 10));

      await datasource.deleteAllForStation(1);

      check(await datasource.getByStation(1)).isEmpty();
      check(await datasource.getByStation(2)).length.equals(1);
    });
  });

  group('getStationIdsForPodcast', () {
    test('returns correct station IDs for a podcast', () async {
      await datasource.insert(makeLink(stationId: 1, podcastId: 10));
      await datasource.insert(makeLink(stationId: 2, podcastId: 10));
      await datasource.insert(makeLink(stationId: 3, podcastId: 99));

      final ids = await datasource.getStationIdsForPodcast(10);

      check(ids).length.equals(2);
      check(ids).containsEqualInOrder([1, 2]);
    });

    test('returns empty list when podcast not linked to any station', () async {
      final ids = await datasource.getStationIdsForPodcast(999);

      check(ids).isEmpty();
    });
  });
}
