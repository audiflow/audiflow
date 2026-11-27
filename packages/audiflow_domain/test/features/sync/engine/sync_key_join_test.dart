import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_podcast/audiflow_podcast.dart' show duplicateGuidKey;
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';

import '../../../helpers/in_memory_relay.dart';
import '../../../helpers/isar_test_helper.dart';

const _feedUrl = 'https://example.com/show.xml';
final _published = DateTime.utc(2026, 11, 1);
final _dup = duplicateGuidKey('g1', 'https://example.com/old.mp3');

/// One simulated device with a catalog of its own: the show and its
/// episodes keyed the way this device happened to key them.
class _Device {
  _Device(this.name, this.isar);

  final String name;
  final Isar isar;
  int now = DateTime.utc(2026, 11, 20).millisecondsSinceEpoch;
  late SyncSession session;
  SyncEngine? engine;
  final merged = <Set<String>>[];

  /// Runs as the engine's feed fetch.
  Future<void> Function(List<String> urls) fetch = (_) async {};

  UserStateStore get _store => UserStateStore(isar, nowMillis: () => now);

  Future<void> seedMeta() => isar.writeTxn(
    () => isar.syncMetas.put(
      SyncMeta()
        ..historyId = 'history-$name'
        ..deviceId = 'device-$name',
    ),
  );

  Future<int> addShow(String podcastKey) => isar.writeTxn(
    () => isar.subscriptions.put(
      Subscription()
        ..itunesId = 'it-$name'
        ..feedUrl = _feedUrl
        ..title = 'Show'
        ..artistName = 'Host'
        ..subscribedAt = DateTime.utc(2026)
        ..podcastKey = podcastKey,
    ),
  );

  Future<void> addEpisode(
    int podcastId, {
    required String episodeKey,
    required String guid,
  }) => isar.writeTxn(
    () => isar.episodes.put(
      Episode()
        ..podcastId = podcastId
        ..guid = guid
        ..title = 'Episode'
        ..audioUrl = 'https://example.com/e1.mp3'
        ..publishedAt = _published
        ..episodeKey = episodeKey,
    ),
  );

  Future<void> connect(
    InMemoryRelay relay,
    SyncOpening opening, {
    required SyncCredentials credentials,
  }) async {
    session = SyncSession(
      credentials: credentials,
      device: SyncDevice(
        deviceId: 'device-$name',
        name: name,
        platform: 'ios',
        publicKey: (await DeviceKeyPair.generate()).publicKey,
      ),
    );
    final e = engine = SyncEngine(
      isar: isar,
      session: session,
      transport: relay.connect(),
      syncFeeds: (urls) => fetch(urls),
      appVersion: '2.3.0',
      platform: 'ios',
      logger: Logger(level: Level.off),
      nowMillis: () => now,
      onEpisodesMerged: merged.add,
    );
    await e.connect(opening);
  }

  Future<void> goOffline() async {
    await engine?.close();
    engine = null;
  }

  Future<void> setSubscribed(String podcastKey, {required bool subscribed}) =>
      _store.write((txn) async {
        final state =
            await isar.podcastUserStates.getByPodcastKey(podcastKey) ??
            (PodcastUserState()..podcastKey = podcastKey);
        state
          ..subscribed = subscribed
          ..subscribedHlc = txn.stamp.packed
          ..feedUrl = _feedUrl
          ..feedUrlHlc = txn.stamp.packed;
        await isar.podcastUserStates.put(state);
        txn.touch(UserStateEntities.podcast, state);
      });

  /// Saves a position the way playback does: the row carries the
  /// locator of this device's catalog episode.
  Future<void> setPosition(String podcastKey, String episodeKey, int ms) =>
      _store.write((txn) async {
        final episode = await isar.episodes
            .where()
            .episodeKeyEqualTo(episodeKey)
            .findFirst();
        final state =
            await isar.episodeUserStates.getByEpisodeKey(episodeKey) ??
            (EpisodeUserState()
              ..episodeKey = episodeKey
              ..podcastKey = podcastKey
              ..locatorGuid = episode?.guid
              ..locatorAudioUrl = episode?.audioUrl
              ..locatorPublishedAt = episode?.publishedAt);
        state
          ..hasPlayback = true
          ..hasPlaybackHlc = txn.stamp.packed
          ..positionMs = ms
          ..positionHlc = txn.stamp.packed;
        await isar.episodeUserStates.put(state);
        txn.touch(UserStateEntities.episode, state);
      });

  Future<int?> position(String episodeKey) async =>
      (await isar.episodeUserStates.getByEpisodeKey(episodeKey))?.positionMs;

  Future<List<String>> episodeKeys() async => [
    for (final s in await isar.episodeUserStates.where().findAll())
      s.episodeKey,
  ];

  Future<List<String>> podcastKeys() async => [
    for (final s in await isar.podcastUserStates.where().findAll())
      s.podcastKey,
  ];
}

void main() {
  late InMemoryRelay relay;
  late _Device a;
  late _Device b;
  final credentials = SyncCredentials.generate();

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    relay = InMemoryRelay();
    a = _Device('A', await openTestIsar(isarSchemas));
    b = _Device('B', await openTestIsar(isarSchemas));
    await a.seedMeta();
    await b.seedMeta();
  });

  tearDown(() async {
    await a.goOffline();
    await b.goOffline();
    await a.isar.close(deleteFromDisk: true);
    await b.isar.close(deleteFromDisk: true);
  });

  Future<void> settle() async {
    for (var i = 0; i < 30; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 2));
      await a.engine?.settle();
      await b.engine?.settle();
    }
  }

  Future<void> pair() async {
    await a.connect(relay, SyncOpening.create, credentials: credentials);
    await settle();
    await b.connect(relay, SyncOpening.join, credentials: credentials);
    await settle();
  }

  Future<void> send(_Device device) async {
    device.engine!.sendSoon();
    await settle();
  }

  group('one episode under two keys', () {
    // A stored the item under a duplicate-guid key, B under its plain
    // guid: their fetch histories differed.
    Future<void> catalogs() async {
      final podA = await a.addShow('pk');
      await a.addEpisode(podA, episodeKey: 'ek-a', guid: _dup);
      final podB = await b.addShow('pk');
      await b.addEpisode(podB, episodeKey: 'ek-b', guid: 'g1');
    }

    test('a position joins the episode the locator finds', () async {
      await catalogs();
      await a.setPosition('pk', 'ek-a', 4000);

      await pair();

      check(await b.position('ek-b')).equals(4000);
      check(await b.episodeKeys()).deepEquals(['ek-b']);
      check(b.merged.expand((keys) => keys)).contains('ek-b');
    });

    test('later changes go straight to the joined episode', () async {
      await catalogs();
      await a.setPosition('pk', 'ek-a', 4000);
      await pair();

      a.now += 1000;
      await a.setPosition('pk', 'ek-a', 9000);
      await send(a);

      check(await b.position('ek-b')).equals(9000);
      check(await b.episodeKeys()).deepEquals(['ek-b']);
    });

    test('the newer side wins when both played it', () async {
      await catalogs();
      await a.setPosition('pk', 'ek-a', 4000);
      b.now += 5000;
      await b.setPosition('pk', 'ek-b', 7000);

      await pair();

      check(await b.position('ek-b')).equals(7000);
      // A keeps its own key and takes B's newer position into it.
      check(await a.position('ek-a')).equals(7000);
      check(await a.episodeKeys()).deepEquals(['ek-a']);
    });
  });

  group('one show under two keys', () {
    // A saw the feed's podcast:guid first, B keyed it by URL; their
    // episode keys differ with it.
    Future<void> catalogs() async {
      final podA = await a.addShow('pk-guid');
      await a.addEpisode(podA, episodeKey: 'ek-a', guid: 'g1');
      final podB = await b.addShow('pk-url');
      await b.addEpisode(podB, episodeKey: 'ek-b', guid: 'g1');
    }

    test('the show and its episodes are joined', () async {
      await catalogs();
      await a.setSubscribed('pk-guid', subscribed: true);
      await a.setPosition('pk-guid', 'ek-a', 4000);

      await pair();

      check(await b.podcastKeys()).deepEquals(['pk-url']);
      check(
        await b.isar.podcastUserStates.getByPodcastKey('pk-url'),
      ).isNotNull().has((s) => s.subscribed, 'subscribed').isTrue();
      check(await b.position('ek-b')).equals(4000);
      // No second library row for the show.
      check(await b.isar.subscriptions.count()).equals(1);
    });

    test('an unsubscribe on the other device reaches the show', () async {
      await catalogs();
      await a.setSubscribed('pk-guid', subscribed: true);
      await pair();

      a.now += 1000;
      await a.setSubscribed('pk-guid', subscribed: false);
      await send(a);

      check(
        await b.isar.podcastUserStates.getByPodcastKey('pk-url'),
      ).isNotNull().has((s) => s.subscribed, 'subscribed').isFalse();
      final sub = await b.isar.subscriptions.where().findFirst();
      check(sub).isNotNull().has((s) => s.isCached, 'isCached').isTrue();
    });
  });

  test('an episode fetched after its state arrived is joined', () async {
    final podA = await a.addShow('pk');
    await a.addEpisode(podA, episodeKey: 'ek-a', guid: _dup);
    await a.setSubscribed('pk', subscribed: true);
    await a.setPosition('pk', 'ek-a', 4000);
    // B knows the show but has not fetched its episodes yet.
    final podB = await b.addShow('pk');
    b.fetch = (_) => b.addEpisode(podB, episodeKey: 'ek-b', guid: 'g1');

    await pair();

    check(await b.position('ek-b')).equals(4000);
    check(await b.episodeKeys()).deepEquals(['ek-b']);
  });
}
