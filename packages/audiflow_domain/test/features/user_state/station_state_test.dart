import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late StationLocalDatasource stations;
  late StationPodcastLocalDatasource links;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar(isarSchemas);
    stations = StationLocalDatasource(isar);
    links = StationPodcastLocalDatasource(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  Station newStation(String name) => Station()
    ..name = name
    ..createdAt = DateTime(2026)
    ..updatedAt = DateTime(2026);

  Future<Subscription> putPodcast(String name, {bool keyed = true}) async {
    final sub = Subscription()
      ..itunesId = 'it-$name'
      ..feedUrl = 'https://example.com/$name'
      ..title = name
      ..artistName = 'Artist'
      ..subscribedAt = DateTime(2026)
      ..podcastKey = keyed ? 'pk-$name' : null;
    await isar.writeTxn(() => isar.subscriptions.put(sub));
    return sub;
  }

  StationPodcast link(Station s, Subscription sub, {int sortOrder = 0}) =>
      StationPodcast()
        ..stationId = s.id
        ..podcastId = sub.id
        ..addedAt = DateTime(2026, 2)
        ..sortOrder = sortOrder;

  Future<StationState> stateOf(Station s) async =>
      (await isar.stationStates.getByStationId(s.stationId!))!;

  test('insert gives the station an id and a stamped state', () async {
    final s = await stations.insert(
      newStation('Morning')
        ..hideCompleted = true
        ..durationFilter = (StationDurationFilter()..durationMinutes = 20),
    );

    check(s.stationId).isNotNull();
    final state = await stateOf(s);
    check(state.name).equals('Morning');
    check(state.hideCompleted).isTrue();
    check(state.durationOperator).equals('shorterThan');
    check(state.durationMinutes).equals(20);
    check(state.defaultEpisodeLimit).equals(3);
    check(state.nameHlc).not((it) => it.equals(0));
    // A default the station did not change is not stamped.
    check(state.filterFavoritedHlc).equals(0);
  });

  test('updates, plays, and reorders stamp only what changed', () async {
    final a = await stations.insert(newStation('A'));
    final b = await stations.insert(newStation('B')..sortOrder = 1);
    final before = await stateOf(a);

    await stations.update(a..groupByPodcast = true);
    await stations.markPlayed(a.id, at: DateTime(2026, 5));
    await stations.reorder([b.id, a.id]);

    final after = await stateOf(a);
    check(after.groupByPodcast).isTrue();
    check(after.lastPlayedAt!.isAtSameMomentAs(DateTime(2026, 5))).isTrue();
    check(after.sortOrder).equals(1);
    check(after.nameHlc).equals(before.nameHlc);
    check((await stateOf(b)).sortOrder).equals(0);
  });

  test('members follow links by podcast key', () async {
    final s = await stations.insert(newStation('S'));
    final p = await putPodcast('p');
    final q = await putPodcast('q');

    await links.insert(link(s, p));
    await links.insert(link(s, q, sortOrder: 1));
    await links.update(
      (await links.getByStation(s.id)).first..episodeLimit = 5,
    );
    await links.delete(s.id, q.id);

    final members = await isar.stationMembers.where().findAll();
    check(members).length.equals(2);
    final mp = members.firstWhere((m) => m.podcastKey == 'pk-p');
    final mq = members.firstWhere((m) => m.podcastKey == 'pk-q');
    check(mp.stationId).equals(s.stationId!);
    check(mp.episodeLimit).equals(5);
    check(mp.deleted).isFalse();
    check(mq.deleted).isTrue();
    check(mq.deletedHlc).not((it) => it.equals(0));
  });

  test('deleting a station tombstones it and its members', () async {
    final s = await stations.insert(newStation('S'));
    final p = await putPodcast('p');
    await links.insert(link(s, p));

    await links.deleteAllForStation(s.id);
    await stations.delete(s.id);

    check((await stateOf(s)).deleted).isTrue();
    final member = (await isar.stationMembers.where().findAll()).single;
    check(member.deleted).isTrue();
    check(await isar.stations.count()).equals(0);
  });

  test('the reconciler records removed links', () async {
    final s = await stations.insert(newStation('S'));
    final p = await putPodcast('p');
    await links.insert(link(s, p));

    await StationReconcilerService(isar: isar).onSubscriptionRemoved(p.id);

    check(await isar.stationPodcasts.count()).equals(0);
    check(
      (await isar.stationMembers.where().findAll()).single.deleted,
    ).isTrue();
  });

  test('a link to an unkeyed podcast is recorded when keyed', () async {
    final s = await stations.insert(newStation('S'));
    final p = await putPodcast('p', keyed: false);
    await links.insert(link(s, p));
    check(await isar.stationMembers.count()).equals(0);

    await SubscriptionLocalDatasource(isar).assignStableKeys(p.id);

    final member = (await isar.stationMembers.where().findAll()).single;
    check(member.podcastKey).equals(podcastKeyFor(feedUrl: p.feedUrl));
    check(member.addedAt!.isAtSameMomentAs(DateTime(2026, 2))).isTrue();
  });

  test('the backfill records old stations and is idempotent', () async {
    final p = await putPodcast('p');
    final old = newStation('Old');
    await isar.writeTxn(() async {
      await isar.stations.put(old);
      await isar.stationPodcasts.put(link(old, p));
    });

    await const StationStateBackfill().run(isar);
    final row = (await isar.stations.get(old.id))!;
    final first = await stateOf(row);
    await const StationStateBackfill().run(isar);

    final second = await stateOf((await isar.stations.get(old.id))!);
    check(second.nameHlc).equals(first.nameHlc);
    check(await isar.stationStates.count()).equals(1);
    check(await isar.stationMembers.count()).equals(1);
  });
}
