import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late PlaybackHistoryLocalDatasource history;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar(isarSchemas);
    history = PlaybackHistoryLocalDatasource(isar);
    await isar.writeTxn(
      () => isar.syncMetas.put(
        SyncMeta()
          ..historyId = 'h'
          ..deviceId = 'this-device',
      ),
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  Future<Subscription> putPodcast({String? podcastKey = 'pk'}) async {
    final sub = Subscription()
      ..itunesId = 'it-${podcastKey ?? 'none'}'
      ..feedUrl = 'https://example.com/${podcastKey ?? 'none'}'
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
    bool favorited = false,
  }) async {
    final episode = Episode()
      ..podcastId = sub.id
      ..guid = guid
      ..title = guid
      ..audioUrl = 'https://example.com/$guid.mp3'
      ..episodeKey = keyed ? 'ek-$guid' : null
      ..isFavorited = favorited
      ..favoritedAt = favorited ? DateTime(2026, 2) : null;
    await isar.writeTxn(() => isar.episodes.put(episode));
    return episode;
  }

  Future<EpisodeUserState?> stateOf(String key) =>
      isar.episodeUserStates.getByEpisodeKey(key);

  group('playback writes', () {
    test('write the old row and the keyed state together', () async {
      final episode = await putEpisode(await putPodcast(), 'g1');

      await history.updateProgress(
        episodeId: episode.id,
        positionMs: 1200,
        durationMs: 60000,
        listenedDeltaMs: 1000,
        realtimeDeltaMs: 800,
      );

      final legacy = await isar.playbackHistorys.getByEpisodeId(episode.id);
      check(legacy?.positionMs).equals(1200);
      final state = await stateOf('ek-g1');
      check(state).isNotNull();
      check(state!.podcastKey).equals('pk');
      check(state.hasPlayback).isTrue();
      check(state.positionMs).equals(1200);
      check(state.positionHlc).not((it) => it.equals(0));
      check(state.durationMs).equals(60000);
      check(state.counters.single.deviceId).equals('this-device');
      check(state.counters.single.playCount).equals(1);
      check(state.counters.single.listenedMs).equals(1000);
      check(state.counters.single.realtimeMs).equals(800);
      // So a device keying the episode differently can find it.
      check(state.locatorGuid).equals('g1');
      check(state.locatorAudioUrl).equals('https://example.com/g1.mp3');
    });

    test('fill the locator of a row made without one', () async {
      final episode = await putEpisode(await putPodcast(), 'g1');
      await isar.writeTxn(
        () => isar.episodeUserStates.put(
          EpisodeUserState()
            ..episodeKey = 'ek-g1'
            ..podcastKey = 'pk',
        ),
      );

      await history.updateProgress(
        episodeId: episode.id,
        positionMs: 1200,
        durationMs: 60000,
        listenedDeltaMs: 1000,
        realtimeDeltaMs: 800,
      );

      check((await stateOf('ek-g1'))?.locatorGuid).equals('g1');
    });

    test('stamp only the fields that changed', () async {
      final episode = await putEpisode(await putPodcast(), 'g1');
      await history.updateProgress(
        episodeId: episode.id,
        positionMs: 1000,
        durationMs: 60000,
      );
      final first = await stateOf('ek-g1');

      await history.updateProgress(episodeId: episode.id, positionMs: 2000);

      final second = await stateOf('ek-g1');
      check(second!.durationHlc).equals(first!.durationHlc);
      check(
        Hlc.unpack(first.positionHlc).compareTo(Hlc.unpack(second.positionHlc)),
      ).equals(-1);
    });

    test('add to this device counters and keep the other ones', () async {
      final episode = await putEpisode(await putPodcast(), 'g1');
      await history.updateProgress(episodeId: episode.id, positionMs: 1000);
      final seeded = await stateOf('ek-g1');
      seeded!.counters = [
        ...seeded.counters,
        EpisodePlayCounters()
          ..deviceId = 'other-device'
          ..playCount = 4
          ..completedCount = 2,
      ];
      await isar.writeTxn(() => isar.episodeUserStates.put(seeded));

      await history.incrementPlayCount(episode.id);
      await history.markCompleted(episode.id);

      final read = await history.getByEpisodeId(episode.id);
      check(read!.playCount).equals(6);
      check(read.completedCount).equals(3);
      final state = await stateOf('ek-g1');
      final own = state!.counters.firstWhere(
        (c) => c.deviceId == 'this-device',
      );
      final other = state.counters.firstWhere(
        (c) => c.deviceId == 'other-device',
      );
      check(own.playCount).equals(2);
      check(own.completedCount).equals(1);
      check(other.playCount).equals(4);
      check(other.completedCount).equals(2);
    });

    test('leave an episode of an unkeyed podcast on the old row', () async {
      final sub = await putPodcast(podcastKey: null);
      final episode = await putEpisode(sub, 'g1', keyed: false);

      await history.updateProgress(episodeId: episode.id, positionMs: 1000);

      check(await isar.episodeUserStates.count()).equals(0);
      check(
        (await history.getByEpisodeId(episode.id))?.positionMs,
      ).equals(1000);
    });
  });

  group('playback reads', () {
    test('come from the keyed state', () async {
      final episode = await putEpisode(await putPodcast(), 'g1');
      await history.updateProgress(episodeId: episode.id, positionMs: 1000);
      final state = await stateOf('ek-g1');
      await isar.writeTxn(
        () => isar.episodeUserStates.put(state!..positionMs = 7777),
      );

      check(
        (await history.getByEpisodeId(episode.id))?.positionMs,
      ).equals(7777);
    });

    test('hide keyed state whose episode is not in the catalog', () async {
      final sub = await putPodcast();
      final kept = await putEpisode(sub, 'kept');
      await history.updateProgress(episodeId: kept.id, positionMs: 1000);
      await isar.writeTxn(
        () => isar.episodeUserStates.put(
          EpisodeUserState()
            ..episodeKey = 'ek-elsewhere'
            ..podcastKey = 'pk'
            ..hasPlayback = true
            ..positionMs = 500
            ..lastPlayedAt = DateTime(2026, 3),
        ),
      );

      final inProgress = await history.getInProgress();

      check(inProgress.map((h) => h.episodeId)).deepEquals([kept.id]);
      check(await stateOf('ek-elsewhere')).isNotNull();
    });

    test('merge keyed and unkeyed episodes in recency order', () async {
      final keyedSub = await putPodcast();
      final keyed = await putEpisode(keyedSub, 'k');
      final plainSub = await putPodcast(podcastKey: null);
      final plain = await putEpisode(plainSub, 'p', keyed: false);
      await history.updateProgress(episodeId: plain.id, positionMs: 1000);
      await history.updateProgress(episodeId: keyed.id, positionMs: 1000);

      final inProgress = await history.getInProgress();

      check(
        inProgress.map((h) => h.episodeId),
      ).deepEquals([keyed.id, plain.id]);
    });
  });

  group('in-progress paging', () {
    Future<void> putOrphans(int count, DateTime newest) => isar.writeTxn(
      () => isar.episodeUserStates.putAll([
        for (var i = 0; i < count; i++)
          EpisodeUserState()
            ..episodeKey = 'orphan-$i'
            ..podcastKey = 'pk'
            ..hasPlayback = true
            ..positionMs = 100
            ..lastPlayedAt = newest.subtract(Duration(minutes: i)),
      ]),
    );

    Future<void> putLegacyAt(int episodeId, DateTime at) => isar.writeTxn(
      () => isar.playbackHistorys.put(
        PlaybackHistory()
          ..episodeId = episodeId
          ..positionMs = 100
          ..lastPlayedAt = at,
      ),
    );

    test('reads past pages of hidden rows to fill the limit', () async {
      final sub = await putPodcast();
      final visible = await putEpisode(sub, 'v');
      await history.updateProgress(episodeId: visible.id, positionMs: 1000);
      await isar.writeTxn(() async {
        final state = await stateOf('ek-v');
        await isar.episodeUserStates.put(
          state!..lastPlayedAt = DateTime(2026, 1, 1),
        );
      });
      // More hidden rows than one page, all newer than the visible one.
      await putOrphans(50, DateTime(2026, 6));

      final inProgress = await history.getInProgress(limit: 1);

      check(inProgress.map((h) => h.episodeId)).deepEquals([visible.id]);
    });

    test('orders across both collections beyond the first page', () async {
      final plainSub = await putPodcast(podcastKey: null);
      final plain = <Episode>[];
      for (var i = 0; i < 25; i++) {
        final e = await putEpisode(plainSub, 'p$i', keyed: false);
        plain.add(e);
        // Old rows, newest first: p0 at day 25 down to p24 at day 1.
        await putLegacyAt(e.id, DateTime(2026, 1, 25 - i));
      }
      // Hidden keyed rows push the keyed pager to page through.
      await putOrphans(30, DateTime(2026, 3));
      final keyedSub = await putPodcast();
      final keyed = await putEpisode(keyedSub, 'k');
      await history.updateProgress(episodeId: keyed.id, positionMs: 1000);
      await isar.writeTxn(() async {
        final state = await stateOf('ek-k');
        // Between p2 (day 23) and p3 (day 22).
        await isar.episodeUserStates.put(
          state!..lastPlayedAt = DateTime(2026, 1, 22, 12),
        );
      });

      final inProgress = await history.getInProgress(limit: 5);

      check(inProgress.map((h) => h.episodeId)).deepEquals([
        plain[0].id,
        plain[1].id,
        plain[2].id,
        keyed.id,
        plain[3].id,
      ]);
    });

    test('watching emits again when a hidden episode arrives', () async {
      await isar.writeTxn(
        () => isar.episodeUserStates.put(
          EpisodeUserState()
            ..episodeKey = 'ek-late'
            ..podcastKey = 'pk'
            ..hasPlayback = true
            ..positionMs = 100
            ..lastPlayedAt = DateTime(2026, 3),
        ),
      );
      final lengths = <int>[];
      final first = Completer<void>();
      final second = Completer<void>();
      final subscription = history.watchInProgress().listen((list) {
        lengths.add(list.length);
        if (lengths.length == 1) first.complete();
        if (lengths.length == 2) second.complete();
      });
      addTearDown(subscription.cancel);
      // The episode must arrive after the first result, or both results
      // would be equal and the second never emitted.
      await first.future;

      await putEpisode(await putPodcast(), 'late');
      await second.future;

      check(lengths).deepEquals([0, 1]);
    });
  });

  group('favorites', () {
    test('toggle writes the keyed state and reads it back', () async {
      final episode = await putEpisode(await putPodcast(), 'g1');
      final repo = EpisodeFavoriteRepositoryImpl(
        isar: isar,
        reconcilerService: StationReconcilerService(isar: isar),
      );
      final access = EpisodeUserStateAccess(isar);

      await repo.toggleFavorite(episode.id);

      final state = await stateOf('ek-g1');
      check(state?.favoritedAt).isNotNull();
      check(state?.hasPlayback).equals(false);
      final stored = await isar.episodes.get(episode.id);
      check(stored!.isFavorited).isTrue();
      check(await access.isFavorited(stored)).isTrue();

      await repo.toggleFavorite(episode.id);

      check((await stateOf('ek-g1'))?.favoritedAt).isNull();
      check(
        await access.isFavorited((await isar.episodes.get(episode.id))!),
      ).isFalse();
    });
  });

  group('when a podcast gets its key', () {
    test('its episodes carry their old state over', () async {
      final sub = await putPodcast(podcastKey: null);
      final played = await putEpisode(sub, 'g1', keyed: false);
      await putEpisode(sub, 'g2', keyed: false, favorited: true);
      await history.updateProgress(
        episodeId: played.id,
        positionMs: 4000,
        listenedDeltaMs: 4000,
      );

      await SubscriptionLocalDatasource(isar).assignStableKeys(sub.id);

      final podcastKey = podcastKeyFor(feedUrl: sub.feedUrl);
      final playedState = await stateOf(episodeKeyFor(podcastKey, 'g1'));
      check(playedState?.positionMs).equals(4000);
      check(playedState?.counters.single.listenedMs).equals(4000);
      final favoriteState = await stateOf(episodeKeyFor(podcastKey, 'g2'));
      check(favoriteState?.favoritedAt).equals(DateTime(2026, 2));
      check(favoriteState?.hasPlayback).equals(false);
      check((await history.getByEpisodeId(played.id))?.positionMs).equals(4000);
    });
  });

  group('backfill', () {
    Future<void> putLegacy(int episodeId, {int positionMs = 1000}) =>
        isar.writeTxn(
          () => isar.playbackHistorys.put(
            PlaybackHistory()
              ..episodeId = episodeId
              ..positionMs = positionMs
              ..playCount = 3
              ..completedCount = 1
              ..totalListenedMs = 9000
              ..lastPlayedAt = DateTime(2026, 1, 5),
          ),
        );

    test('copies history and favorites of keyed episodes', () async {
      final sub = await putPodcast();
      final played = await putEpisode(sub, 'g1');
      await putEpisode(sub, 'g2', favorited: true);
      await putLegacy(played.id);

      await const EpisodeUserStateBackfill(batchSize: 1).run(isar);

      final state = await stateOf('ek-g1');
      check(state?.positionMs).equals(1000);
      check(state?.lastPlayedAt).equals(DateTime(2026, 1, 5));
      check(state?.counters.single.playCount).equals(3);
      check(state?.counters.single.completedCount).equals(1);
      check(state?.counters.single.listenedMs).equals(9000);
      check((await stateOf('ek-g2'))?.favoritedAt).equals(DateTime(2026, 2));
    });

    test('is idempotent', () async {
      final played = await putEpisode(await putPodcast(), 'g1');
      await putLegacy(played.id);

      await const EpisodeUserStateBackfill().run(isar);
      await const EpisodeUserStateBackfill().run(isar);

      final state = await stateOf('ek-g1');
      check(state?.counters.single.playCount).equals(3);
      check(await isar.episodeUserStates.count()).equals(1);
    });

    test('keeps state already written over the old row', () async {
      final played = await putEpisode(await putPodcast(), 'g1');
      await history.updateProgress(episodeId: played.id, positionMs: 5000);
      // An old row that fell behind, as after a rollback and an upgrade.
      await isar.writeTxn(() async {
        final row = await isar.playbackHistorys.getByEpisodeId(played.id);
        await isar.playbackHistorys.put(row!..positionMs = 10);
      });

      await const EpisodeUserStateBackfill().run(isar);

      check((await stateOf('ek-g1'))?.positionMs).equals(5000);
    });

    test('skips missing and unkeyed episodes', () async {
      final plain = await putEpisode(
        await putPodcast(podcastKey: null),
        'p',
        keyed: false,
      );
      await putLegacy(plain.id);
      await putLegacy(999);

      await const EpisodeUserStateBackfill().run(isar);

      check(await isar.episodeUserStates.count()).equals(0);
      check((await history.getByEpisodeId(plain.id))?.positionMs).equals(1000);
    });
  });
}
