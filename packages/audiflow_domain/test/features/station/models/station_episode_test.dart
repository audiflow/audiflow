import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;

  setUp(() async {
    isar = await openTestIsar([StationEpisodeSchema]);
  });

  tearDown(() => isar.close());

  test('StationEpisode persists with sortKey', () async {
    final sortKey = DateTime(2026, 3, 20);
    final se = StationEpisode()
      ..stationId = 1
      ..episodeId = 100
      ..sortKey = sortKey;

    await isar.writeTxn(() => isar.stationEpisodes.put(se));

    final loaded = await isar.stationEpisodes.get(se.id);
    check(loaded).isNotNull();
    check(loaded!.stationId).equals(1);
    check(loaded.episodeId).equals(100);
    check(loaded.sortKey).equals(sortKey);
  });

  test(
    'composite unique index prevents duplicate stationId+episodeId',
    () async {
      final se1 = StationEpisode()
        ..stationId = 1
        ..episodeId = 100
        ..sortKey = DateTime(2026, 3, 20);

      await isar.writeTxn(() => isar.stationEpisodes.put(se1));

      final se2 = StationEpisode()
        ..stationId = 1
        ..episodeId = 100
        ..sortKey = DateTime(2026, 3, 21);

      // Isar unique index with replace:false throws on duplicate key.
      await check(
        isar.writeTxn(() => isar.stationEpisodes.put(se2)),
      ).throws<IsarError>();

      // Only the original record remains.
      final all = await isar.stationEpisodes.where().findAll();
      check(all.length).equals(1);
      check(all.first.sortKey).equals(DateTime(2026, 3, 20));
    },
  );
}
