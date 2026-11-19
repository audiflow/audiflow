import 'dart:convert';
import 'dart:typed_data';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';

import '../../../helpers/in_memory_relay.dart';
import '../../../helpers/isar_test_helper.dart';

/// One simulated device: its own database, clock, session, and engine.
class _Device {
  _Device(this.name, this.isar);

  final String name;
  final Isar isar;
  int now = DateTime.utc(2026, 11, 20).millisecondsSinceEpoch;
  late SyncSession session;
  SyncEngine? engine;
  InMemoryTransport? transport;

  UserStateStore get _store => UserStateStore(isar, nowMillis: () => now);

  Future<void> seedMeta() => isar.writeTxn(
    () => isar.syncMetas.put(
      SyncMeta()
        ..historyId = 'history-$name'
        ..deviceId = 'device-$name',
    ),
  );

  Future<void> connect(
    InMemoryRelay relay,
    SyncOpening opening, {
    SyncCredentials? credentials,
    int maxOpsPerFrame = 500,
  }) async {
    if (opening != SyncOpening.resume) {
      session = SyncSession(
        credentials: credentials!,
        device: SyncDevice(
          deviceId: 'device-$name',
          name: name,
          platform: 'ios',
          publicKey: (await DeviceKeyPair.generate()).publicKey,
        ),
      );
    }
    final t = transport = relay.connect();
    final e = engine = SyncEngine(
      isar: isar,
      session: session,
      transport: t,
      syncFeeds: (_) async {},
      appVersion: '2.3.0',
      platform: 'ios',
      logger: Logger(level: Level.off),
      nowMillis: () => now,
      maxOpsPerFrame: maxOpsPerFrame,
    );
    await e.connect(opening);
  }

  Future<void> goOffline() async {
    await engine?.close();
    engine = null;
  }

  Future<void> setSubscribed(String key, {required bool subscribed}) =>
      _store.write((txn) async {
        final state =
            await isar.podcastUserStates.getByPodcastKey(key) ??
            (PodcastUserState()..podcastKey = key);
        state
          ..subscribed = subscribed
          ..subscribedHlc = txn.stamp.packed
          ..feedUrl = 'https://example.com/$key.xml'
          ..feedUrlHlc = txn.stamp.packed;
        await isar.podcastUserStates.put(state);
        txn.touch(UserStateEntities.podcast, state);
      });

  Future<void> setPosition(String episodeKey, int ms) =>
      _store.write((txn) async {
        final state =
            await isar.episodeUserStates.getByEpisodeKey(episodeKey) ??
            (EpisodeUserState()
              ..episodeKey = episodeKey
              ..podcastKey = 'pk1');
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

  Future<bool?> subscribed(String key) async =>
      (await isar.podcastUserStates.getByPodcastKey(key))?.subscribed;

  Future<int> outbox() => isar.outboxOps.count();

  Future<SyncMeta> meta() async =>
      (await isar.syncMetas.get(SyncMeta.singletonId))!;
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

  /// Lets messages, watchers, and both engines' queues run dry.
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

  test(
    'a joining device receives the library and adopts the history',
    () async {
      await a.setSubscribed('pk1', subscribed: true);

      await pair();

      check(await b.subscribed('pk1')).equals(true);
      // Projected into the row the library screen reads.
      final sub = await b.isar.subscriptions
          .filter()
          .podcastKeyEqualTo('pk1')
          .findFirst();
      check(sub)
          .isNotNull()
          .has((s) => s.feedUrl, 'feedUrl')
          .equals('https://example.com/pk1.xml');
      check((await b.meta()).historyId).equals('history-A');
    },
  );

  test('a joining device carries its own data to the account', () async {
    await b.setPosition('ek-b', 777);

    await pair();

    check(await a.position('ek-b')).equals(777);
  });

  test('a live edit reaches the other device', () async {
    await pair();

    a.now += 1000;
    await a.setPosition('ek1', 42000);
    await settle();

    check(await b.position('ek1')).equals(42000);
  });

  test('concurrent offline edits converge on the newer one', () async {
    await pair();
    await a.goOffline();
    await b.goOffline();

    a.now += 1000;
    await a.setPosition('ek1', 10000);
    b.now += 2000;
    await b.setPosition('ek1', 20000);

    await a.connect(relay, SyncOpening.resume);
    await b.connect(relay, SyncOpening.resume);
    await settle();

    check(await a.position('ek1')).equals(20000);
    check(await b.position('ek1')).equals(20000);
  });

  test('an old device cannot resurrect an unsubscribed podcast', () async {
    await a.setSubscribed('pk1', subscribed: true);
    await pair();
    await b.goOffline();

    a.now += 60000;
    await a.setSubscribed('pk1', subscribed: false);
    await settle();
    // B's clock lags A's: its subscribe, made later in real time, carries
    // the older stamp.
    b.now += 1000;
    await b.setSubscribed('pk1', subscribed: true);

    await b.connect(relay, SyncOpening.resume);
    await settle();

    check(await a.subscribed('pk1')).equals(false);
    check(await b.subscribed('pk1')).equals(false);
  });

  test('the outbox drains and received changes are not sent back', () async {
    await pair();
    final before = relay.framesOf(credentials.accountIdText).length;

    a.now += 1000;
    await a.setPosition('ek1', 5000);
    await settle();

    check(await a.outbox()).equals(0);
    check(await b.outbox()).equals(0);
    check(relay.framesOf(credentials.accountIdText).length).equals(before + 1);
  });

  test('a device back online catches up from its cursor', () async {
    await pair();
    await b.goOffline();

    for (var i = 1; i <= 3; i++) {
      a.now += 1000;
      await a.setPosition('ek$i', i * 1000);
      await settle();
    }
    await b.connect(relay, SyncOpening.resume);
    await settle();

    for (var i = 1; i <= 3; i++) {
      check(await b.position('ek$i')).equals(i * 1000);
    }
    check((await b.meta()).serverCursor).equals((await a.meta()).serverCursor);
  });

  test('the relay never sees values or keys', () async {
    await a.setSubscribed('pk1', subscribed: true);
    await pair();
    a.now += 1000;
    await a.setPosition('ek1', 1234);
    await settle();

    final seen = relay.received.join('\n');
    check(seen).not((it) => it.contains('example.com'));
    check(seen).not((it) => it.contains('ek1'));
    check(seen).not(
      (it) => it.contains(
        base64Url.encode(credentials.syncKey).replaceAll('=', ''),
      ),
    );
  });

  test('a wrong sync key cannot join', () async {
    await pair();
    final forged = SyncCredentials(
      accountId: credentials.accountId,
      syncKey: Uint8List(32),
    );
    final c = _Device('C', await openTestIsar(isarSchemas));
    addTearDown(() async {
      await c.goOffline();
      await c.isar.close(deleteFromDisk: true);
    });
    await c.seedMeta();

    await check(
      c.connect(relay, SyncOpening.join, credentials: forged),
    ).throws<SyncRelayFailure>(
      (it) => it.has((f) => f.code, 'code').equals(RelayError.unauthorized),
    );
  });

  test('frames are compacted away by the joining device snapshot', () async {
    await a.connect(relay, SyncOpening.create, credentials: credentials);
    await settle();
    a.now += 1000;
    await a.setPosition('ek1', 1);
    await settle();
    check(relay.framesOf(credentials.accountIdText)).isNotEmpty();

    await b.connect(relay, SyncOpening.join, credentials: credentials);
    await settle();

    check(relay.framesOf(credentials.accountIdText)).isEmpty();
    check(relay.snapshotOf(credentials.accountIdText)).isNotNull();
  });

  test('a frame never splits a row', () async {
    await pair();
    await a.goOffline();
    // An episode B has never seen: its row needs podcastKey alongside.
    a.now += 1000;
    await a.setPosition('ek-new', 900);
    await a.connect(relay, SyncOpening.resume, maxOpsPerFrame: 2);
    await settle();

    check(await b.position('ek-new')).equals(900);
  });

  test('an edit right after joining still reaches the others', () async {
    await a.connect(relay, SyncOpening.create, credentials: credentials);
    await settle();
    await b.connect(relay, SyncOpening.join, credentials: credentials);
    // Before the full-state frames are acknowledged and the snapshot goes.
    b.now += 1000;
    await b.setPosition('ek-late', 321);
    await settle();

    check(await a.position('ek-late')).equals(321);
  });

  test(
    'after the outbox cap dropped ops, the whole state goes again',
    () async {
      await pair();
      await b.goOffline();
      b.now += 1000;
      await b.setPosition('ek-dropped', 555);
      // What the cap does: the op is gone, the mark is set.
      await b.isar.writeTxn(() async {
        await b.isar.outboxOps.clear();
        final meta = (await b.isar.syncMetas.get(SyncMeta.singletonId))!;
        await b.isar.syncMetas.put(meta..outboxOverflowed = true);
      });

      await b.connect(relay, SyncOpening.resume);
      await settle();

      check(await a.position('ek-dropped')).equals(555);
      check((await b.meta()).outboxOverflowed).isFalse();
    },
  );

  test('a joining device titles podcasts from the snapshot', () async {
    await a.setSubscribed('pk1', subscribed: true);
    await a.isar.writeTxn(
      () => a.isar.subscriptions.put(
        Subscription()
          ..itunesId = '1'
          ..feedUrl = 'https://example.com/pk1.xml'
          ..title = 'Show One'
          ..artistName = 'Host'
          ..subscribedAt = DateTime.utc(2026)
          ..podcastKey = 'pk1',
      ),
    );

    await pair();

    final sub = await b.isar.subscriptions
        .filter()
        .podcastKeyEqualTo('pk1')
        .findFirst();
    check(sub).isNotNull().has((s) => s.title, 'title').equals('Show One');
  });

  test('a dropped connection ends the session with a failure', () async {
    await pair();
    final done = a.engine!.done;

    await relay.disconnectAll();
    await settle();

    await check(done).throws<SyncRelayFailure>();
  });

  group('dropBeatenOps', () {
    Future<void> putOp(String entity, int hlc) => a.isar.writeTxn(
      () => a.isar.outboxOps.put(
        OutboxOp()
          ..opId = 'op-$entity'
          ..entity = entity
          ..key = 'k'
          ..fieldId = 1
          ..hlc = hlc
          ..payload = [],
      ),
    );

    ReceivedField field(String entity, int hlc) =>
        (entity: entity, key: 'k', fieldId: 1, hlc: hlc, value: Uint8List(0));

    test('drops an op an incoming newer clock beats', () async {
      await putOp('episode', 10);
      await dropBeatenOps(a.isar, [field('episode', 20)], nowMillis: a.now);
      check(await a.isar.outboxOps.count()).equals(0);
    });

    test('keeps a newer local op', () async {
      await putOp('episode', 30);
      await dropBeatenOps(a.isar, [field('episode', 20)], nowMillis: a.now);
      check(await a.isar.outboxOps.count()).equals(1);
    });

    test('keeps counter ops, which merge by maximum', () async {
      await putOp(UserStateEntities.episodeCounter.name, 10);
      await dropBeatenOps(a.isar, [
        field(UserStateEntities.episodeCounter.name, 20),
      ], nowMillis: a.now);
      check(await a.isar.outboxOps.count()).equals(1);
    });
  });
}
