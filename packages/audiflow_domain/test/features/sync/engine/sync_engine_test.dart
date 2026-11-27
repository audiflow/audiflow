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
  final presences = <(String, SyncPresence)>[];
  final merged = <Set<String>>[];
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
    int maxRowsPerFrame = 500,
    int maxFramesPerPush = 100,
    Duration steadyInterval = const Duration(seconds: 30),
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
      maxRowsPerFrame: maxRowsPerFrame,
      maxFramesPerPush: maxFramesPerPush,
      steadyInterval: steadyInterval,
      onPresence: (deviceId, p) => presences.add((deviceId, p)),
      onEpisodesMerged: merged.add,
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

/// The code [session] failed with, or null when it did not fail.
Future<String?> _failureCode(Future<void> session) async {
  try {
    await session;
    return null;
  } on SyncRelayFailure catch (e) {
    return e.code;
  }
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

  group('pacing', () {
    // The episode exists on both sides, so later saves change only the
    // steady fields.
    Future<void> playing() async {
      await pair();
      a.now += 1000;
      await a.setPosition('ek1', 1000);
      await settle();
      check(await b.position('ek1')).equals(1000);
    }

    test('a position saved while playing waits for the interval', () async {
      await playing();

      a.now += 5000;
      await a.setPosition('ek1', 6000);
      await settle();

      check(await b.position('ek1')).equals(1000);
      check(await a.outbox()).not((n) => n.equals(0));
    });

    test('sendSoon sends the position at once', () async {
      await playing();

      a.now += 5000;
      a.engine!.sendSoon();
      await a.setPosition('ek1', 6000);
      await settle();

      check(await b.position('ek1')).equals(6000);
    });

    test('the waiting position goes once the interval passes', () async {
      await a.connect(
        relay,
        SyncOpening.create,
        credentials: credentials,
        steadyInterval: const Duration(milliseconds: 40),
      );
      await settle();
      await b.connect(relay, SyncOpening.join, credentials: credentials);
      await settle();
      a.now += 1000;
      await a.setPosition('ek1', 1000);
      await settle();

      a.now += 10;
      await a.setPosition('ek1', 2000);
      await settle();
      a.now += 40;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await settle();

      check(await b.position('ek1')).equals(2000);
    });

    test('any other change goes at once', () async {
      await playing();

      a.now += 5000;
      await a.setSubscribed('pk2', subscribed: true);
      await settle();

      check(await b.subscribed('pk2')).equals(true);
    });

    test('drain keeps going until every push is acknowledged', () async {
      await a.connect(
        relay,
        SyncOpening.create,
        credentials: credentials,
        maxOpsPerFrame: 1,
      );
      await settle();
      await b.connect(relay, SyncOpening.join, credentials: credentials);
      await settle();
      for (var i = 0; i < 3; i++) {
        a.now += 1000;
        await a.setPosition('ek-d$i', 1000 + i);
      }
      // Ops written behind a push still in flight wait for its ack.
      await a.engine!.drain();
      await a.goOffline();
      await settle();

      check(await a.outbox()).equals(0);
      for (var i = 0; i < 3; i++) {
        check(await b.position('ek-d$i')).equals(1000 + i);
      }
    });

    test('drain sends the waiting position before closing', () async {
      await playing();

      a.now += 5000;
      await a.setPosition('ek1', 6000);
      await settle();
      await a.engine!.drain();
      await settle();

      check(await b.position('ek1')).equals(6000);
    });
  });

  group('presence', () {
    const playingAt = SyncPresence(
      episodeKey: 'ek1',
      positionMs: 754000,
      durationMs: 3600000,
      playing: true,
      sentAt: 1700000000000,
    );

    test('reaches the other device and is not stored', () async {
      await pair();

      a.engine!.sendPresence(playingAt);
      await settle();

      check(b.presences).deepEquals([('device-A', playingAt)]);
      check(a.presences).isEmpty();
      check(relay.framesOf(credentials.accountIdText)).isEmpty();
    });

    test('the relay sees only a sealed blob', () async {
      await pair();
      relay.received.clear();

      a.engine!.sendPresence(playingAt);
      await settle();

      final sent = relay.received.single;
      check(sent).contains('"type":"presence"');
      check(sent).not((s) => s.contains('ek1'));
    });

    test('a message type from a newer relay is ignored', () async {
      await pair();

      relay.injectRaw(credentials.accountIdText, '{"type":"future-thing"}');
      a.now += 1000;
      await a.setSubscribed('pk4', subscribed: true);
      await settle();

      check(await b.subscribed('pk4')).equals(true);
    });

    test('an unreadable presence is ignored', () async {
      await pair();

      relay.injectPresence(
        credentials.accountIdText,
        'device-X',
        Uint8List.fromList(List.filled(64, 7)),
      );
      a.now += 1000;
      await a.setSubscribed('pk3', subscribed: true);
      await settle();

      check(b.presences).isEmpty();
      check(await b.subscribed('pk3')).equals(true);
    });
  });

  test('a merged episode change is reported after it is stored', () async {
    await pair();
    b.merged.clear();

    a.now += 1000;
    a.engine!.sendSoon();
    await a.setPosition('ek9', 9000);
    await settle();

    check(b.merged).deepEquals([
      {'ek9'},
    ]);
    check(a.merged).isEmpty();
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
      // Not about pacing: each save goes as it is made.
      a.engine!.sendSoon();
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
    // ':' is outside base64url, so ciphertext cannot contain the key by
    // chance, as a bare 'ek1' sometimes did.
    await a.setPosition('ek:1', 1234);
    await settle();

    final seen = relay.received.join('\n');
    check(seen).not((it) => it.contains('example.com'));
    check(seen).not((it) => it.contains('ek:1'));
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
      // What the cap does: the op is gone, a resend is requested.
      await b.isar.writeTxn(() async {
        await b.isar.outboxOps.clear();
        final meta = (await b.isar.syncMetas.get(SyncMeta.singletonId))!;
        await b.isar.syncMetas.put(meta..fullStateRequested += 1);
      });

      await b.connect(relay, SyncOpening.resume);
      await settle();

      check(await a.position('ek-dropped')).equals(555);
      final meta = await b.meta();
      check(meta.fullStateSent).equals(meta.fullStateRequested);
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

  test('a whole-state send cut short goes again next time', () async {
    await a.connect(relay, SyncOpening.create, credentials: credentials);
    await settle();
    await b.setPosition('ek-join', 444);
    relay.holdAcks = true;
    await b.connect(relay, SyncOpening.join, credentials: credentials);
    await settle();
    await b.goOffline();
    check(
      (await b.meta()).fullStateSent,
    ).isLessThan((await b.meta()).fullStateRequested);

    relay.holdAcks = false;
    await b.connect(relay, SyncOpening.resume);
    await settle();

    final meta = await b.meta();
    check(meta.fullStateSent).equals(meta.fullStateRequested);
    check(relay.snapshotOf(credentials.accountIdText)).isNotNull();
  });

  test('the whole state goes in pushes within the relay limit', () async {
    for (var i = 0; i < 5; i++) {
      await b.setPosition('ek-$i', i * 10);
    }
    relay.maxFramesPerPush = 2;
    await a.connect(relay, SyncOpening.create, credentials: credentials);
    await settle();
    await b.connect(
      relay,
      SyncOpening.join,
      credentials: credentials,
      maxRowsPerFrame: 1,
      maxFramesPerPush: 2,
    );
    await settle();

    for (var i = 0; i < 5; i++) {
      check(await a.position('ek-$i')).equals(i * 10);
    }
  });

  test('connect waits for the whole catch-up', () async {
    await pair();
    await b.goOffline();
    for (var i = 0; i < 4; i++) {
      a.now += 1000;
      // Not about pacing: each save goes as it is made.
      a.engine!.sendSoon();
      await a.setPosition('ek-c$i', 100 + i);
      await settle();
    }
    relay.catchUpPage = 1;

    await b.connect(relay, SyncOpening.resume);

    for (var i = 0; i < 4; i++) {
      check(await b.position('ek-c$i')).equals(100 + i);
    }
  });

  test('an unreadable frame ends the session before the cursor', () async {
    await pair();
    final before = (await b.meta()).serverCursor;
    final done = b.engine!.done;

    relay.inject(credentials.accountIdText, 'device-x', Uint8List(40));
    await settle();

    check(await _failureCode(done)).equals(SyncRelayFailure.unreadableFrame);
    check((await b.meta()).serverCursor).equals(before);
  });

  test('joining before the account has a snapshot is retried', () async {
    await a.setPosition('ek-a', 1);
    relay.holdAcks = true;
    await a.connect(relay, SyncOpening.create, credentials: credentials);
    await settle();

    final joining = b.connect(
      relay,
      SyncOpening.join,
      credentials: credentials,
    );

    check(await _failureCode(joining)).equals(SyncRelayFailure.accountNotReady);
    check(b.session.token).isNull();
  });

  test('joining takes the account horizon with its history', () async {
    await b.isar.writeTxn(() async {
      final meta = (await b.isar.syncMetas.get(SyncMeta.singletonId))!;
      await b.isar.syncMetas.put(meta..tombstoneHorizon = 1 << 60);
    });

    await pair();

    final meta = await b.meta();
    check(meta.historyId).equals((await a.meta()).historyId);
    check(meta.tombstoneHorizon).equals((await a.meta()).tombstoneHorizon);
  });

  test('joining keeps live rows older than the account horizon', () async {
    await a.setSubscribed('pk-old', subscribed: true);
    await a.connect(relay, SyncOpening.create, credentials: credentials);
    await settle();
    // The account purged tombstones past the subscription's clock; its
    // snapshot still carries the live subscription.
    await a.isar.writeTxn(() async {
      final meta = (await a.isar.syncMetas.get(SyncMeta.singletonId))!;
      await a.isar.syncMetas.put(meta..tombstoneHorizon = 1 << 60);
    });
    await a.goOffline();
    await a.connect(relay, SyncOpening.resume);
    await a.setPosition('ek-touch', 1);
    await a.isar.writeTxn(() async {
      await a.isar.outboxOps.clear();
      final meta = (await a.isar.syncMetas.get(SyncMeta.singletonId))!;
      await a.isar.syncMetas.put(meta..fullStateRequested += 1);
    });
    await settle();
    check(relay.snapshotOf(credentials.accountIdText)).isNotNull();

    await b.connect(relay, SyncOpening.join, credentials: credentials);
    await settle();

    check(await b.subscribed('pk-old')).equals(true);
    check((await b.meta()).tombstoneHorizon).equals(1 << 60);
  });

  test('a transport error ends the session', () async {
    await pair();
    final done = a.engine!.done;

    a.transport!.fail(StateError('socket'));
    await settle();

    check(await _failureCode(done)).equals(SyncRelayFailure.closed);
  });

  test('a podcast and its details travel in one frame', () async {
    await a.connect(relay, SyncOpening.create, credentials: credentials);
    await settle();
    await b.setSubscribed('pk2', subscribed: true);
    await b.isar.writeTxn(
      () => b.isar.subscriptions.put(
        Subscription()
          ..itunesId = '2'
          ..feedUrl = 'https://example.com/pk2.xml'
          ..title = 'Show Two'
          ..artistName = 'Host'
          ..subscribedAt = DateTime.utc(2026)
          ..podcastKey = 'pk2',
      ),
    );

    await b.connect(
      relay,
      SyncOpening.join,
      credentials: credentials,
      maxRowsPerFrame: 1,
    );
    await settle();

    final sub = await a.isar.subscriptions
        .filter()
        .podcastKeyEqualTo('pk2')
        .findFirst();
    check(sub).isNotNull().has((s) => s.title, 'title').equals('Show Two');
  });

  test('metadata from before sync reads its new counters as 0', () async {
    await a.isar.writeTxn(() async {
      final meta = (await a.isar.syncMetas.get(SyncMeta.singletonId))!;
      await a.isar.syncMetas.put(
        meta
          ..storedServerCursor = null
          ..storedFullStateRequested = null
          ..storedFullStateSent = null
          ..storedLastSnapshotHlc = null,
      );
    });

    final meta = await a.meta();
    check(meta.serverCursor).equals(0);
    check(meta.fullStateRequested).equals(0);
    check(meta.fullStateSent).equals(0);
    check(meta.lastSnapshotHlc).equals(0);
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

    test('only the last occurrence of a field decides', () async {
      await putOp('episode', 20);
      await a.isar.writeTxn(() async {
        final op = (await a.isar.outboxOps.where().findFirst())!;
        await a.isar.outboxOps.put(op..payload = [5]);
      });
      ReceivedField at(int byte) => (
        entity: 'episode',
        key: 'k',
        fieldId: 1,
        hlc: 20,
        value: Uint8List.fromList([byte]),
      );
      // 9 would beat the pending 5; the later 1 does not, and it is the one
      // the merge keeps.
      await dropBeatenOps(a.isar, [at(9), at(1)], nowMillis: a.now);
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
