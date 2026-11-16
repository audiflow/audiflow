import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_domain/src/features/feed/datasources/local/podcast_view_preference_local_datasource.dart';
import 'package:audiflow_domain/src/features/parental_control/datasources/local/parental_control_local_datasource.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late PodcastViewPreferenceLocalDatasource views;
  late PlayOrderPreferenceLocalDatasource playOrders;
  late PodcastAudioPreferenceLocalDatasource audio;
  late ParentalControlLocalDataSource parental;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar(isarSchemas);
    views = PodcastViewPreferenceLocalDatasource(isar);
    playOrders = PlayOrderPreferenceLocalDatasource(isar);
    audio = PodcastAudioPreferenceLocalDatasource(isar);
    parental = ParentalControlLocalDataSource(isar: isar);
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

  Future<PodcastUserState?> state([String key = 'pk']) =>
      isar.podcastUserStates.getByPodcastKey(key);

  group('view', () {
    test('writes the old row and the keyed state together', () async {
      final sub = await putPodcast();

      await views.upsertPreference(
        PodcastViewPreference()
          ..podcastId = sub.id
          ..viewMode = 'seasons'
          ..episodeSortOrder = 'asc',
      );

      final legacy = await isar.podcastViewPreferences.getByPodcastId(sub.id);
      check(legacy?.viewMode).equals('seasons');
      final s = await state();
      check(s!.hasView).isTrue();
      check(s.viewMode).equals('seasons');
      check(s.viewModeHlc).not((it) => it.equals(0));
      check(s.episodeSortOrder).equals('asc');
      // Unchanged defaults are not stamped.
      check(s.episodeFilterHlc).equals(0);
    });

    test('reads come from the keyed state', () async {
      final sub = await putPodcast();
      await views.upsertPreference(PodcastViewPreference()..podcastId = sub.id);
      final s = await state();
      await isar.writeTxn(
        () => isar.podcastUserStates.put(s!..viewMode = 'grid'),
      );

      check((await views.getPreference(sub.id))?.viewMode).equals('grid');
    });

    test('delete keeps a stamped removal', () async {
      final sub = await putPodcast();
      await views.upsertPreference(PodcastViewPreference()..podcastId = sub.id);
      final before = (await state())!.hasViewHlc;

      check(await views.deletePreference(sub.id)).equals(1);

      final s = await state();
      check(s!.hasView).isFalse();
      check(Hlc.unpack(before).compareTo(Hlc.unpack(s.hasViewHlc))).equals(-1);
      check(await views.getPreference(sub.id)).isNull();
      check(await isar.podcastViewPreferences.count()).equals(0);
    });

    test('the podcast play order creates a view with defaults', () async {
      final sub = await putPodcast();

      await playOrders.setPodcastPlayOrder(sub.id, 'oldestFirst');

      check(await playOrders.getPodcastPlayOrder(sub.id)).equals('oldestFirst');
      final view = await views.getPreference(sub.id);
      check(view?.viewMode).equals('episodes');
      check((await state())!.autoPlayOrder).equals('oldestFirst');
    });

    test('watching emits on change and on deletion', () async {
      final sub = await putPodcast();
      final modes = <String?>[];
      final changes = [Completer<void>(), Completer<void>(), Completer<void>()];
      final subscription = views.watchPreference(sub.id).listen((pref) {
        modes.add(pref?.viewMode);
        changes[modes.length - 1].complete();
      });
      addTearDown(subscription.cancel);
      await changes[0].future;

      await views.upsertPreference(
        PodcastViewPreference()
          ..podcastId = sub.id
          ..viewMode = 'seasons',
      );
      await changes[1].future;
      await views.deletePreference(sub.id);
      await changes[2].future;

      check(modes).deepEquals([null, 'seasons', null]);
    });
  });

  group('watching follows the keyed state', () {
    /// Collects [stream] and lets the test wait for the nth value.
    ({List<T> values, Future<void> Function(int) waitFor}) collect<T>(
      Stream<T> stream,
    ) {
      final values = <T>[];
      final waiters = <int, Completer<void>>{};
      final subscription = stream.listen((v) {
        values.add(v);
        waiters.remove(values.length)?.complete();
      });
      addTearDown(subscription.cancel);
      return (
        values: values,
        waitFor: (n) {
          if (n <= values.length) return Future.value();
          return (waiters[n] = Completer<void>()).future;
        },
      );
    }

    test('a change to the keyed state alone re-reads', () async {
      final sub = await putPodcast();
      await views.upsertPreference(PodcastViewPreference()..podcastId = sub.id);
      await parental.setHideExplicit(itunesId: sub.id, hide: false);
      final view = collect(views.watchPreference(sub.id));
      final hide = collect(parental.watchHideExplicit(sub.id));
      await view.waitFor(1);
      await hide.waitFor(1);

      // As a change arriving from another device would land.
      final s = await state();
      await isar.writeTxn(
        () => isar.podcastUserStates.put(
          s!
            ..viewMode = 'grid'
            ..hideExplicitEpisodes = true,
        ),
      );
      await view.waitFor(2);
      await hide.waitFor(2);

      check(
        view.values.map((p) => p?.viewMode),
      ).deepEquals(['episodes', 'grid']);
      check(hide.values).deepEquals([false, true]);
    });

    test('assigning the key switches to keyed state already stored', () async {
      final sub = await putPodcast(podcastKey: null);
      await views.upsertPreference(
        PodcastViewPreference()
          ..podcastId = sub.id
          ..viewMode = 'seasons',
      );
      await parental.setHideExplicit(itunesId: sub.id, hide: false);
      // Keyed state that is already there, for example from another device.
      await isar.writeTxn(
        () => isar.podcastUserStates.put(
          PodcastUserState()
            ..podcastKey = podcastKeyFor(feedUrl: sub.feedUrl)
            ..hasView = true
            ..hasViewHlc = 1
            ..viewMode = 'grid'
            ..hasParental = true
            ..hasParentalHlc = 1
            ..hideExplicitEpisodes = true,
        ),
      );
      final view = collect(views.watchPreference(sub.id));
      final hide = collect(parental.watchHideExplicit(sub.id));
      await view.waitFor(1);
      await hide.waitFor(1);

      await SubscriptionLocalDatasource(isar).assignStableKeys(sub.id);
      await view.waitFor(2);
      await hide.waitFor(2);

      check(
        view.values.map((p) => p?.viewMode),
      ).deepEquals(['seasons', 'grid']);
      check(hide.values).deepEquals([false, true]);
    });
  });

  group('subscription', () {
    test('user field writes are recorded on the keyed state', () async {
      final sub = await putPodcast();
      final ds = SubscriptionLocalDatasource(isar);

      await ds.updateAutoDownload(sub.id, autoDownload: true);
      await ds.updateAutoDownloadKeepCount(sub.id, 3);

      final s = await state();
      check(s!.subscribed).isTrue();
      check(s.subscribedAt!.isAtSameMomentAs(sub.subscribedAt)).isTrue();
      check(s.feedUrl).equals(sub.feedUrl);
      check(s.itunesId).equals(sub.itunesId);
      check(s.autoDownload).isTrue();
      check(s.autoDownloadKeepCount).equals(3);
      check(s.autoDownloadHlc).not((it) => it.equals(0));
    });

    test('device-scoped writes leave the state alone', () async {
      final sub = await putPodcast();
      final ds = SubscriptionLocalDatasource(isar);
      await ds.updateAutoDownload(sub.id, autoDownload: true);
      final before = (await state())!;

      await ds.updateLastAccessed(sub.id, DateTime(2026, 6));
      await ds.updateHttpCacheHeaders(sub.id, etag: 'e');
      await ds.recordAutoDownloads(
        sub.id,
        2,
        pauseThreshold: 10,
        at: DateTime(2026, 6),
      );

      final after = (await state())!;
      check(after.subscribedHlc).equals(before.subscribedHlc);
      check(after.autoDownloadHlc).equals(before.autoDownloadHlc);
      check(after.feedUrlHlc).equals(before.feedUrlHlc);
    });

    test('unsubscribe, resubscribe, and delete are stamped', () async {
      final sub = await putPodcast();
      final ds = SubscriptionLocalDatasource(isar);
      await ds.updateAutoDownload(sub.id, autoDownload: false);
      final first = (await state())!.subscribedHlc;

      await ds.demoteToCached(sub.itunesId);
      final demoted = (await state())!;
      check(demoted.subscribed).isFalse();
      check(
        Hlc.unpack(first).compareTo(Hlc.unpack(demoted.subscribedHlc)),
      ).equals(-1);

      await ds.promoteToSubscribed(sub.itunesId);
      check((await state())!.subscribed).isTrue();

      await ds.deleteById(sub.id);
      check((await state())!.subscribed).isFalse();
    });

    test('a podcast without a key gets no state until keyed', () async {
      final sub = await putPodcast(podcastKey: null);
      final ds = SubscriptionLocalDatasource(isar);
      await ds.updateAutoDownload(sub.id, autoDownload: true);
      check(await isar.podcastUserStates.count()).equals(0);

      await ds.assignStableKeys(sub.id);

      final s = await state(podcastKeyFor(feedUrl: sub.feedUrl));
      check(s!.subscribed).isTrue();
      check(s.autoDownload).isTrue();
    });

    test('a recreated row takes up the choices its key kept', () async {
      final sub = await putPodcast(podcastKey: null);
      final ds = SubscriptionLocalDatasource(isar);
      await ds.assignStableKeys(sub.id);
      await ds.updateAutoDownload(sub.id, autoDownload: true);
      await ds.updateAutoDownloadKeepCount(sub.id, 4);
      final kept = (await state(podcastKeyFor(feedUrl: sub.feedUrl)))!;
      // Unsubscribed and evicted: the row is gone, the state stays.
      await ds.deleteById(sub.id);

      final again = await ds.getOrCreateCached(
        itunesId: sub.itunesId,
        feedUrl: sub.feedUrl,
        title: 'Show',
        artistName: 'Artist',
      );
      await ds.assignStableKeys(again.id);

      final row = (await ds.getById(again.id))!;
      check(row.autoDownload).isTrue();
      check(row.autoDownloadKeepCount).equals(4);
      final s = (await state(podcastKeyFor(feedUrl: sub.feedUrl)))!;
      check(s.autoDownload).isTrue();
      check(s.autoDownloadKeepCount).equals(4);
      check(s.autoDownloadHlc).equals(kept.autoDownloadHlc);
      check(s.autoDownloadKeepCountHlc).equals(kept.autoDownloadKeepCountHlc);
    });

    test(
      'upgrading from step 2 adds the subscription and keeps the rest',
      () async {
        final sub = await putPodcast();
        // A state row as step 2 left it, before the subscription section.
        await isar.writeTxn(() async {
          await isar.syncMetas.put(
            SyncMeta()
              ..historyId = 'h'
              ..schemaVersion = 2,
          );
          await isar.podcastUserStates.put(
            PodcastUserState()
              ..podcastKey = 'pk'
              ..hasView = true
              ..hasViewHlc = 7
              ..viewMode = 'seasons'
              ..viewModeHlc = 7,
          );
        });

        await DataMigrationRunner(isar, steps: dataMigrationSteps).run();

        final s = (await state())!;
        check(s.subscribed).isTrue();
        check(s.feedUrl).equals(sub.feedUrl);
        check(s.subscribedHlc).not((it) => it.equals(0));
        check(s.viewMode).equals('seasons');
        check(s.viewModeHlc).equals(7);
        check(s.hasViewHlc).equals(7);
        check(
          (await isar.syncMetas.get(SyncMeta.singletonId))!.schemaVersion,
        ).equals(3);
      },
    );

    test('compare logs keep feed credentials out', () {
      check(
        redactFeedUrl('https://user:pw@example.com:8443/feed.xml?token=t'),
      ).equals('https://***@example.com:8443/feed.xml?***');
      check(
        redactFeedUrl('https://example.com/feed'),
      ).equals('https://example.com/feed');
    });

    test('the backfill copies the subscription of keyed podcasts', () async {
      await putPodcast();
      final sub = (await isar.subscriptions.where().findFirst())!;
      await isar.writeTxn(
        () => isar.subscriptions.put(sub..autoDownloadKeepCount = 5),
      );

      await const PodcastUserStateBackfill(version: 3).run(isar);

      final s = await state();
      check(s!.subscribed).isTrue();
      check(s.autoDownloadKeepCount).equals(5);
    });
  });

  group('play order per playlist and group', () {
    test('set, read, and clear keep a stamped entry', () async {
      final sub = await putPodcast();

      await playOrders.setPlaylistPlayOrder(sub.id, 'pl', 'newestFirst');
      await playOrders.setGroupPlayOrder(sub.id, 'pl', 'g1', 'oldestFirst');

      check(
        await playOrders.getPlaylistPlayOrder(sub.id, 'pl'),
      ).equals('newestFirst');
      check(
        await playOrders.getGroupPlayOrder(sub.id, 'pl', 'g1'),
      ).equals('oldestFirst');
      check((await state())!.playOrders).length.equals(2);

      await playOrders.setPlaylistPlayOrder(sub.id, 'pl', null);

      check(await playOrders.getPlaylistPlayOrder(sub.id, 'pl')).isNull();
      final cleared = (await state())!.playOrders.firstWhere(
        (e) => e.groupId == null,
      );
      check(cleared.order).isNull();
      check(cleared.hlc).not((it) => it.equals(0));
      check(await isar.smartPlaylistUserPreferences.count()).equals(0);
    });
  });

  group('audio override', () {
    test('upsert and delete', () async {
      final sub = await putPodcast();

      await audio.upsert(
        sub.id,
        speed: 1.5,
        skipSilence: true,
        voiceBoost: false,
      );

      check((await audio.get(sub.id))?.speed).equals(1.5);
      final s = await state();
      check(s!.hasAudio).isTrue();
      check(s.skipSilence).equals(true);

      await audio.delete(sub.id);

      check(await audio.get(sub.id)).isNull();
      check((await state())!.hasAudio).isFalse();
      check(await isar.podcastAudioPreferences.count()).equals(0);
    });
  });

  group('parental flags', () {
    test('set, watch, and prune', () async {
      final sub = await putPodcast();
      final values = <bool>[];
      final changes = [Completer<void>(), Completer<void>(), Completer<void>()];
      final subscription = parental.watchHideExplicit(sub.id).listen((v) {
        values.add(v);
        changes[values.length - 1].complete();
      });
      addTearDown(subscription.cancel);
      await changes[0].future;

      await parental.setHideExplicit(itunesId: sub.id, hide: true);
      await changes[1].future;
      check(
        (await parental.getFlags(sub.id))?.hideExplicitEpisodes,
      ).equals(true);
      await parental.pruneFlagsFor(sub.id);
      await changes[2].future;

      check(values).deepEquals([false, true, false]);
      check(await parental.getFlags(sub.id)).isNull();
      check((await state())!.hasParental).isFalse();
    });
  });

  test('a podcast without a key stays on the old rows', () async {
    final sub = await putPodcast(podcastKey: null);

    await views.upsertPreference(
      PodcastViewPreference()
        ..podcastId = sub.id
        ..viewMode = 'seasons',
    );
    await audio.upsert(sub.id, speed: 2, skipSilence: false, voiceBoost: true);
    await playOrders.setPlaylistPlayOrder(sub.id, 'pl', 'newestFirst');

    check(await isar.podcastUserStates.count()).equals(0);
    check((await views.getPreference(sub.id))?.viewMode).equals('seasons');
    check((await audio.get(sub.id))?.speed).equals(2);
    check(
      await playOrders.getPlaylistPlayOrder(sub.id, 'pl'),
    ).equals('newestFirst');
  });

  Future<void> putLegacyPrefs(Subscription sub) => isar.writeTxn(() async {
    await isar.podcastViewPreferences.put(
      PodcastViewPreference()
        ..podcastId = sub.id
        ..viewMode = 'seasons'
        ..autoPlayOrder = 'oldestFirst',
    );
    await isar.podcastAudioPreferences.put(
      PodcastAudioPreference()
        ..podcastId = sub.id
        ..speed = 1.25,
    );
    await isar.podcastParentalFlags.put(
      PodcastParentalFlags()
        ..itunesId = sub.id
        ..hideExplicitEpisodes = true,
    );
    await isar.smartPlaylistUserPreferences.put(
      SmartPlaylistUserPreference()
        ..podcastId = sub.id
        ..playlistId = 'pl'
        ..autoPlayOrder = 'newestFirst',
    );
    await isar.smartPlaylistGroupUserPreferences.put(
      SmartPlaylistGroupUserPreference()
        ..podcastId = sub.id
        ..playlistId = 'pl'
        ..groupId = 'g1'
        ..autoPlayOrder = 'oldestFirst',
    );
  });

  void checkCopied(PodcastUserState? s) {
    check(s).isNotNull();
    check(s!.viewMode).equals('seasons');
    check(s.autoPlayOrder).equals('oldestFirst');
    check(s.hasAudio).isTrue();
    check(s.speed).equals(1.25);
    check(s.hideExplicitEpisodes).isTrue();
    check(s.playOrders).length.equals(2);
  }

  test('keying a podcast carries its old preferences over', () async {
    final sub = await putPodcast(podcastKey: null);
    await putLegacyPrefs(sub);

    await SubscriptionLocalDatasource(isar).assignStableKeys(sub.id);

    checkCopied(await state(podcastKeyFor(feedUrl: sub.feedUrl)));
    check((await views.getPreference(sub.id))?.viewMode).equals('seasons');
  });

  group('backfill', () {
    test('copies every section of keyed podcasts', () async {
      final sub = await putPodcast();
      await putLegacyPrefs(sub);
      await putPodcast(podcastKey: null);

      await const PodcastUserStateBackfill(batchSize: 1).run(isar);

      checkCopied(await state());
      check(await isar.podcastUserStates.count()).equals(1);
    });

    test('is idempotent and keeps sections already written', () async {
      final sub = await putPodcast();
      await putLegacyPrefs(sub);
      await audio.upsert(
        sub.id,
        speed: 3,
        skipSilence: false,
        voiceBoost: false,
      );
      // An old row that fell behind, as after a rollback and an upgrade.
      await isar.writeTxn(() async {
        final row = await isar.podcastAudioPreferences.getByPodcastId(sub.id);
        await isar.podcastAudioPreferences.put(row!..speed = 0.5);
      });

      await const PodcastUserStateBackfill().run(isar);
      await const PodcastUserStateBackfill().run(isar);

      final s = await state();
      check(s!.speed).equals(3);
      check(s.viewMode).equals('seasons');
      check(s.playOrders).length.equals(2);
    });
  });
}
