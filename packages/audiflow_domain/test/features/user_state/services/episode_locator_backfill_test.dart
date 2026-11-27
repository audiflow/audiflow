import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar(isarSchemas);
  });

  tearDown(() => isar.close(deleteFromDisk: true));

  test('fills the locator from the catalog episode', () async {
    final published = DateTime.utc(2026, 11);
    await isar.writeTxn(() async {
      await isar.episodes.put(
        Episode()
          ..podcastId = 1
          ..guid = 'g1'
          ..title = 'Episode'
          ..audioUrl = 'https://example.com/1.mp3'
          ..publishedAt = published
          ..episodeKey = 'ek1',
      );
      await isar.episodeUserStates.putAll([
        EpisodeUserState()
          ..episodeKey = 'ek1'
          ..podcastKey = 'pk',
        // Its episode is not in the catalog.
        EpisodeUserState()
          ..episodeKey = 'ek2'
          ..podcastKey = 'pk',
      ]);
    });

    await const EpisodeLocatorBackfill(batchSize: 1).run(isar);

    final filled = (await isar.episodeUserStates.getByEpisodeKey('ek1'))!;
    check(filled.locatorGuid).equals('g1');
    check(filled.locatorAudioUrl).equals('https://example.com/1.mp3');
    check(filled.locatorPublishedAt?.toUtc()).equals(published);
    check(
      (await isar.episodeUserStates.getByEpisodeKey('ek2'))?.locatorGuid,
    ).isNull();
    // No change to send: the first sync sends every row whole.
    check(await isar.outboxOps.count()).equals(0);
  });
}
