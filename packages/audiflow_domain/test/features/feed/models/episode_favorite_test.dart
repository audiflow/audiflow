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
    isar = await openTestIsar([EpisodeSchema]);
  });

  tearDown(() => isar.close());

  test('isFavorited defaults to false', () {
    final episode = Episode()
      ..podcastId = 1
      ..guid = 'ep-1'
      ..title = 'Test'
      ..audioUrl = 'https://example.com/ep.mp3';

    check(episode.isFavorited).isFalse();
    check(episode.favoritedAt).isNull();
  });

  test('isFavorited persists through Isar round-trip', () async {
    final episode = Episode()
      ..podcastId = 1
      ..guid = 'ep-1'
      ..title = 'Test'
      ..audioUrl = 'https://example.com/ep.mp3'
      ..isFavorited = true
      ..favoritedAt = DateTime(2026, 3, 20);

    await isar.writeTxn(() => isar.episodes.put(episode));

    final loaded = await isar.episodes.get(episode.id);
    check(loaded).isNotNull();
    check(loaded!.isFavorited).isTrue();
    check(loaded.favoritedAt).equals(DateTime(2026, 3, 20));
  });
}
