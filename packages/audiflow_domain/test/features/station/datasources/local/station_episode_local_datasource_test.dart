import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late StationEpisodeLocalDatasource datasource;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([StationEpisodeSchema]);
    datasource = StationEpisodeLocalDatasource(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  StationEpisode makeEntry({
    required int stationId,
    required int episodeId,
    DateTime? sortKey,
  }) {
    return StationEpisode()
      ..stationId = stationId
      ..episodeId = episodeId
      ..sortKey = sortKey ?? DateTime(2026, 3, episodeId);
  }

  group('putAll and countByStation', () {
    test('persists all entries and counts correctly', () async {
      final entries = [
        makeEntry(stationId: 1, episodeId: 1),
        makeEntry(stationId: 1, episodeId: 2),
        makeEntry(stationId: 2, episodeId: 3),
      ];

      await datasource.putAll(entries);

      check(await datasource.countByStation(1)).equals(2);
      check(await datasource.countByStation(2)).equals(1);
      check(await datasource.countByStation(99)).equals(0);
    });
  });

  group('watchByStation', () {
    test('emits episodes sorted by sortKey descending', () async {
      await datasource.putAll([
        makeEntry(stationId: 1, episodeId: 1, sortKey: DateTime(2026, 1, 1)),
        makeEntry(stationId: 1, episodeId: 2, sortKey: DateTime(2026, 6, 1)),
        makeEntry(stationId: 1, episodeId: 3, sortKey: DateTime(2026, 3, 1)),
      ]);

      final result = await datasource.watchByStation(1).first;

      check(result).length.equals(3);
      check(result[0].episodeId).equals(2);
      check(result[1].episodeId).equals(3);
      check(result[2].episodeId).equals(1);
    });

    test('applies limit', () async {
      await datasource.putAll([
        makeEntry(stationId: 1, episodeId: 1),
        makeEntry(stationId: 1, episodeId: 2),
        makeEntry(stationId: 1, episodeId: 3),
      ]);

      final result = await datasource.watchByStation(1, limit: 2).first;

      check(result).length.equals(2);
    });

    test('applies offset', () async {
      await datasource.putAll([
        makeEntry(stationId: 1, episodeId: 1, sortKey: DateTime(2026, 1, 1)),
        makeEntry(stationId: 1, episodeId: 2, sortKey: DateTime(2026, 6, 1)),
        makeEntry(stationId: 1, episodeId: 3, sortKey: DateTime(2026, 3, 1)),
      ]);

      // Sorted desc: ep2, ep3, ep1 — offset 1 skips ep2
      final result = await datasource.watchByStation(1, offset: 1).first;

      check(result).length.equals(2);
      check(result.first.episodeId).equals(3);
    });
  });

  group('deleteAllForStation', () {
    test('removes all episodes for the specified station', () async {
      await datasource.putAll([
        makeEntry(stationId: 1, episodeId: 1),
        makeEntry(stationId: 1, episodeId: 2),
        makeEntry(stationId: 2, episodeId: 3),
      ]);

      await datasource.deleteAllForStation(1);

      check(await datasource.countByStation(1)).equals(0);
      check(await datasource.countByStation(2)).equals(1);
    });
  });

  group('getByStationAndEpisode', () {
    test('returns correct entry', () async {
      await datasource.putAll([
        makeEntry(stationId: 1, episodeId: 10),
        makeEntry(stationId: 1, episodeId: 20),
      ]);

      final result = await datasource.getByStationAndEpisode(1, 10);

      check(result).isNotNull();
      check(result!.episodeId).equals(10);
      check(result.stationId).equals(1);
    });

    test('returns null when not found', () async {
      final result = await datasource.getByStationAndEpisode(1, 999);

      check(result).isNull();
    });
  });
}
