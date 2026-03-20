import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;

  setUp(() async {
    isar = await openTestIsar([StationPodcastSchema]);
  });

  tearDown(() => isar.close());

  test(
    'StationPodcast persists and composite unique index allows different pairs',
    () async {
      final now = DateTime(2026, 3, 20);
      final sp1 = StationPodcast()
        ..stationId = 1
        ..podcastId = 10
        ..addedAt = now;
      final sp2 = StationPodcast()
        ..stationId = 1
        ..podcastId = 20
        ..addedAt = now;

      await isar.writeTxn(() async {
        await isar.stationPodcasts.put(sp1);
        await isar.stationPodcasts.put(sp2);
      });

      final all = await isar.stationPodcasts.where().findAll();
      check(all.length).equals(2);
    },
  );

  test(
    'composite unique index: duplicate stationId+podcastId throws',
    () async {
      final now = DateTime(2026, 3, 20);
      final sp1 = StationPodcast()
        ..stationId = 1
        ..podcastId = 10
        ..addedAt = now;

      await isar.writeTxn(() => isar.stationPodcasts.put(sp1));

      final later = DateTime(2026, 3, 21);
      final sp2 = StationPodcast()
        ..stationId = 1
        ..podcastId = 10
        ..addedAt = later;

      // Isar unique index with replace:false throws on duplicate key.
      await check(
        isar.writeTxn(() => isar.stationPodcasts.put(sp2)),
      ).throws<IsarError>();

      // Only the original record remains.
      final all = await isar.stationPodcasts.where().findAll();
      check(all.length).equals(1);
      check(all.first.addedAt).equals(now);
    },
  );
}
