import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late QueueLocalDatasource queue;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar(isarSchemas);
    queue = QueueLocalDatasource(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  Future<Subscription> putPodcast({String? podcastKey = 'pk'}) async {
    final sub = Subscription()
      ..itunesId = 'it'
      ..feedUrl = 'https://example.com/feed'
      ..title = 'Show'
      ..artistName = 'Artist'
      ..subscribedAt = DateTime(2026)
      ..podcastKey = podcastKey;
    await isar.writeTxn(() => isar.subscriptions.put(sub));
    return sub;
  }

  Future<Episode> putEpisode(
    Subscription sub,
    String guid, {
    bool keyed = true,
  }) async {
    final episode = Episode()
      ..podcastId = sub.id
      ..guid = guid
      ..title = guid
      ..audioUrl = 'https://example.com/$guid.mp3'
      ..episodeKey = keyed ? 'ek-$guid' : null;
    await isar.writeTxn(() => isar.episodes.put(episode));
    return episode;
  }

  QueueItem item(Episode e, int position, {bool adhoc = false}) => QueueItem()
    ..episodeId = e.id
    ..position = position
    ..isAdhoc = adhoc
    ..addedAt = DateTime(2026, 3);

  Future<List<QueueEntry>> live() async {
    final entries = await isar.queueEntrys
        .filter()
        .deletedEqualTo(false)
        .findAll();
    entries.sort((a, b) {
      final byRank = a.rank.compareTo(b.rank);
      return byRank != 0 ? byRank : a.entryId.compareTo(b.entryId);
    });
    return entries;
  }

  test('rank strings order like the positions', () {
    final positions = [-1000000, -10, -1, 0, 1, 9, 10, 35, 36, 999999999];
    final ranks = positions.map(rankForPosition).toList();
    check(ranks.toSet()).length.equals(positions.length);
    check([...ranks]..sort()).deepEquals(ranks);
  });

  test('inserts write an entry linked by entryId', () async {
    final sub = await putPodcast();
    final a = await putEpisode(sub, 'a');
    final b = await putEpisode(sub, 'b');

    await queue.insert(item(a, 0, adhoc: true)..sourceContext = 'ctx');
    await queue.insertManualRange([b.id], atFront: false, spacing: 10);

    final items = await queue.getAll();
    final entries = await live();
    check(entries.map((e) => e.episodeKey)).deepEquals(['ek-a', 'ek-b']);
    check(
      entries.map((e) => e.entryId),
    ).deepEquals([for (final i in items) i.entryId!]);
    check(entries.first.isAdhoc).isTrue();
    check(entries.first.sourceContext).equals('ctx');
    check(entries.first.rankHlc).not((it) => it.equals(0));
  });

  test('reorders and shifts restamp only the moved ranks', () async {
    final sub = await putPodcast();
    final a = await putEpisode(sub, 'a');
    final b = await putEpisode(sub, 'b');
    await queue.insertManualRange([a.id, b.id], atFront: false, spacing: 10);
    final before = await live();

    final second = (await queue.getAll()).last;
    await queue.updatePosition(second.id, -5);
    var after = await live();
    check(after.map((e) => e.episodeKey)).deepEquals(['ek-b', 'ek-a']);
    check(after.last.rankHlc).equals(before.first.rankHlc);
    check(after.last.isAdhocHlc).equals(before.first.isAdhocHlc);

    await queue.shiftPositions(100);
    after = await live();
    check(after.map((e) => e.episodeKey)).deepEquals(['ek-b', 'ek-a']);
    check(after.first.rank).equals(rankForPosition(95));
  });

  test('tied positions read in the order the entries describe', () async {
    final sub = await putPodcast(podcastKey: null);
    final a = await putEpisode(sub, 'a', keyed: false);
    final b = await putEpisode(sub, 'b', keyed: false);
    final c = await putEpisode(sub, 'c', keyed: false);
    // Inserted first but keyed last, so its entry id is the newest.
    await queue.insert(item(a, 5));
    await isar.writeTxn(() async {
      await isar.episodes.put(b..episodeKey = 'ek-b');
      await isar.episodes.put(c..episodeKey = 'ek-c');
    });
    await queue.insert(item(b, 5));
    await queue.insert(item(c, 5));

    await SubscriptionLocalDatasource(isar).assignStableKeys(sub.id);

    final items = await queue.getAll();
    final entries = await live();
    check(entries).length.equals(3);
    check(
      items.map((i) => i.entryId),
    ).deepEquals(entries.map((e) => e.entryId));
    final watched = await queue.watchAll().first;
    check(
      watched.map((i) => i.entryId),
    ).deepEquals(entries.map((e) => e.entryId));
  });

  test('deletes leave stamped tombstones', () async {
    final sub = await putPodcast();
    final a = await putEpisode(sub, 'a');
    final b = await putEpisode(sub, 'b');
    final c = await putEpisode(sub, 'c');
    await queue.insert(item(a, 0, adhoc: true));
    await queue.insertManualRange([b.id, c.id], atFront: false, spacing: 10);

    await queue.deleteAllAdhoc();
    check((await live()).map((e) => e.episodeKey)).deepEquals(['ek-b', 'ek-c']);
    final first = (await queue.getAll()).first;
    await queue.deleteById(first.id);
    await queue.deleteAll();

    check(await live()).isEmpty();
    final all = await isar.queueEntrys.where().findAll();
    check(all).length.equals(3);
    check(all.every((e) => e.deleted && e.deletedHlc != 0)).isTrue();
    check(await isar.queueItems.count()).equals(0);
  });

  test('an episode without a key gets its entry when keyed', () async {
    final sub = await putPodcast(podcastKey: null);
    final a = await putEpisode(sub, 'a', keyed: false);
    await queue.insert(item(a, 0));
    check(await isar.queueEntrys.count()).equals(0);
    check((await queue.getAll()).single.entryId).isNull();

    await SubscriptionLocalDatasource(isar).assignStableKeys(sub.id);

    final entry = (await live()).single;
    check(entry.episodeKey).isNotEmpty();
    check((await queue.getAll()).single.entryId).equals(entry.entryId);
  });

  test('the backfill gives keyed items entries and is idempotent', () async {
    final sub = await putPodcast();
    final a = await putEpisode(sub, 'a');
    final b = await putEpisode(sub, 'b', keyed: false);
    await isar.writeTxn(
      () => isar.queueItems.putAll([item(a, 0), item(b, 10)]),
    );

    await const QueueEntryBackfill().run(isar);
    final first = await live();
    await const QueueEntryBackfill().run(isar);

    final second = await live();
    check(second).length.equals(1);
    check(second.single.entryId).equals(first.single.entryId);
    check(second.single.rankHlc).equals(first.single.rankHlc);
  });
}
