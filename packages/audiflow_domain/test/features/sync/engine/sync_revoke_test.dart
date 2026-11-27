import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';

import '../../../helpers/in_memory_relay.dart';
import '../../../helpers/isar_test_helper.dart';

const _feedUrl = 'https://example.com/show.xml';

/// One simulated device that keeps its session across connections, as the
/// controller does with its stored enrollment.
class _Device {
  _Device(this.name, this.isar);

  final String name;
  final Isar isar;
  int now = DateTime.utc(2026, 11, 20).millisecondsSinceEpoch;
  SyncSession? session;
  SyncEngine? engine;

  /// How the last session ended: null while running or after a clean close.
  String? endedWith;

  /// Sessions the engine reported as changed, as the controller stores them.
  int sessionChanges = 0;

  String get deviceId => 'device-$name';

  UserStateStore get _store => UserStateStore(isar, nowMillis: () => now);

  Future<void> seedMeta() => isar.writeTxn(
    () => isar.syncMetas.put(
      SyncMeta()
        ..historyId = 'history-$name'
        ..deviceId = deviceId,
    ),
  );

  Future<void> connect(
    InMemoryRelay relay,
    SyncOpening opening, {
    SyncCredentials? credentials,
  }) async {
    final existing = session;
    final SyncSession s;
    if (existing == null) {
      final keyPair = await DeviceKeyPair.generate();
      s = session = SyncSession(
        credentials: credentials!,
        device: SyncDevice(
          deviceId: deviceId,
          name: name,
          platform: 'ios',
          publicKey: keyPair.publicKey,
        ),
        keyPair: keyPair,
      );
    } else {
      s = existing;
    }
    endedWith = null;
    final e = engine = SyncEngine(
      isar: isar,
      session: s,
      transport: relay.connect(),
      syncFeeds: (_) async {},
      appVersion: '2.3.0',
      platform: 'ios',
      logger: Logger(level: Level.off),
      nowMillis: () => now,
      onSessionChanged: (_) => sessionChanges++,
    );
    unawaited(
      e.done.then(
        (_) {},
        onError: (Object error) {
          if (error is SyncRelayFailure) endedWith = error.code;
        },
      ),
    );
    await e.connect(opening);
  }

  Future<void> goOffline() async {
    await engine?.close();
    engine = null;
  }

  Future<void> subscribe(String podcastKey) => _store.write((txn) async {
    final state = PodcastUserState()
      ..podcastKey = podcastKey
      ..subscribed = true
      ..subscribedHlc = txn.stamp.packed
      ..feedUrl = _feedUrl
      ..feedUrlHlc = txn.stamp.packed;
    await isar.podcastUserStates.put(state);
    txn.touch(UserStateEntities.podcast, state);
  });

  Future<List<String>> podcastKeys() async => [
    for (final s in await isar.podcastUserStates.where().findAll())
      s.podcastKey,
  ]..sort();
}

void main() {
  late InMemoryRelay relay;
  late _Device a;
  late _Device b;
  late _Device c;
  late SyncCredentials credentials;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    relay = InMemoryRelay();
    credentials = SyncCredentials.generate();
    a = _Device('A', await openTestIsar(isarSchemas));
    b = _Device('B', await openTestIsar(isarSchemas));
    c = _Device('C', await openTestIsar(isarSchemas));
    for (final d in [a, b, c]) {
      await d.seedMeta();
    }
  });

  tearDown(() async {
    for (final d in [a, b, c]) {
      await d.goOffline();
      await d.isar.close(deleteFromDisk: true);
    }
  });

  Future<void> settle() async {
    for (var i = 0; i < 30; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 2));
      for (final d in [a, b, c]) {
        await d.engine?.settle();
      }
    }
  }

  Future<void> pairAll() async {
    await a.connect(relay, SyncOpening.create, credentials: credentials);
    await settle();
    await b.connect(relay, SyncOpening.join, credentials: credentials);
    await settle();
    await c.connect(relay, SyncOpening.join, credentials: credentials);
    await settle();
    // A learns of C on its next welcome.
    await a.goOffline();
    await a.connect(relay, SyncOpening.resume);
    await settle();
  }

  Future<void> send(_Device device) async {
    device.engine!.sendSoon();
    await settle();
  }

  test('rotates the keys and cuts the revoked device off', () async {
    await pairAll();

    await a.engine!.revoke(c.deviceId);
    await settle();

    final rotated = a.session!.credentials;
    check(rotated).not((it) => it.equals(credentials));
    check(rotated.accountIdText).equals(credentials.accountIdText);
    check(a.session!.dataKey!.version).equals(2);
    check(c.endedWith).equals(RelayError.revoked);
    check(b.endedWith).equals(RelayError.rekeyed);

    // B reconnects and takes the keys sealed to it.
    await b.connect(relay, SyncOpening.resume);
    await settle();
    check(b.session!.credentials).equals(rotated);
    check(b.session!.dataKey!.key).deepEquals(a.session!.dataKey!.key);
    check(b.sessionChanges).isGreaterThan(0);

    // C can neither resume nor join again with the sync key it holds.
    await c.goOffline();
    await check(c.connect(relay, SyncOpening.resume)).throws<SyncRelayFailure>(
      (it) => it.has((f) => f.code, 'code').equals(RelayError.revoked),
    );
    final stranger = _Device('D', await openTestIsar(isarSchemas));
    addTearDown(() => stranger.isar.close(deleteFromDisk: true));
    await stranger.seedMeta();
    await check(
      stranger.connect(relay, SyncOpening.join, credentials: credentials),
    ).throws<SyncRelayFailure>(
      (it) => it.has((f) => f.code, 'code').equals(RelayError.unauthorized),
    );
  });

  test('changes after the revocation reach the remaining devices', () async {
    await pairAll();
    await a.engine!.revoke(c.deviceId);
    await settle();
    await b.connect(relay, SyncOpening.resume);
    await settle();

    a.now += 1000;
    await a.subscribe('pk-after');
    await send(a);

    check(await b.podcastKeys()).contains('pk-after');
    final frames = relay.framesOf(credentials.accountIdText);
    check(frames).isNotEmpty();
    for (final f in frames) {
      check(SyncCipher.keyVersionOf(f.blob)).equals(2);
    }
  });

  test('a device offline during the revocation catches up on return', () async {
    await pairAll();
    await b.goOffline();
    a.now += 1000;
    await a.subscribe('pk-before');
    await send(a);

    await a.engine!.revoke(c.deviceId);
    await settle();
    // Nothing the relay keeps needs the retired key.
    check(relay.framesOf(credentials.accountIdText)).isEmpty();

    await b.connect(relay, SyncOpening.resume);
    await settle();
    check(b.endedWith).isNull();
    check(await b.podcastKeys()).contains('pk-before');
  });

  test(
    'a change waiting to go out is kept and goes under the new key',
    () async {
      await pairAll();
      a.now += 1000;
      await a.subscribe('pk-pending');

      // Asked while the change is still queued: it goes first, then the
      // revocation, whose snapshot covers it.
      await a.engine!.revoke(c.deviceId);
      await settle();
      await b.connect(relay, SyncOpening.resume);
      await settle();

      check(await b.podcastKeys()).contains('pk-pending');
    },
  );

  test('a revoker that never heard back recovers its keys', () async {
    await pairAll();
    relay.dropRevokeResults = true;

    final revoking = a.engine!.revoke(c.deviceId);
    await settle();
    check(relay.revocations).equals(1);
    // Listened to first: closing fails it at once.
    final failed = check(revoking).throws<SyncRelayFailure>();
    await a.goOffline();
    await failed;
    // Still on the retired keys: the answer never came.
    check(a.session!.dataKey!.version).equals(1);

    relay.dropRevokeResults = false;
    await a.connect(relay, SyncOpening.resume);
    await settle();
    check(a.session!.dataKey!.version).equals(2);
    check(a.session!.credentials).not((it) => it.equals(credentials));
  });

  test('a refused revocation changes nothing', () async {
    await pairAll();

    await check(a.engine!.revoke('device-Z')).throws<SyncRevokeFailure>(
      (it) => it.has((f) => f.code, 'code').equals(RevokeResult.unknownDevice),
    );
    await check(a.engine!.revoke(a.deviceId)).throws<SyncRevokeFailure>();

    check(a.session!.credentials).equals(credentials);
    check(relay.revocations).equals(0);
    // Sends still flow.
    a.now += 1000;
    await a.subscribe('pk-still');
    await send(a);
    check(await b.podcastKeys()).contains('pk-still');
  });

  test('a change another device sent meanwhile is kept', () async {
    await pairAll();
    b.now += 2000;
    await b.subscribe('pk-from-b');
    b.engine!.sendSoon();

    // B's frame may land between A's last frame and its revocation; then
    // the relay says A is behind, and A tries again once it has the frame.
    await a.engine!.revoke(c.deviceId);
    await settle();
    await b.connect(relay, SyncOpening.resume);
    await settle();

    check(await a.podcastKeys()).contains('pk-from-b');
    check(await b.podcastKeys()).contains('pk-from-b');
    check(relay.revocations).equals(1);
  });

  group('against a relay that forges', () {
    test('a device wrap it made up is not taken', () async {
      await pairAll();
      await b.goOffline();
      // The relay knows B's public key, but not the sync key the wrap
      // must be bound to.
      final forged = await KeyWraps.sealDeviceWrap(
        SyncCipher(credentials.accountId),
        recipientPublicKey: b.session!.device.publicKey,
        rekeyKey: SyncCipher.generateKey(),
        syncKey: SyncCipher.generateKey(),
        keys: DataKey(SyncCipher.generateKey(), version: 2),
      );
      relay.injectDeviceWrap(credentials.accountIdText, b.deviceId, forged);

      await b.connect(relay, SyncOpening.resume);
      await settle();

      check(b.session!.credentials).equals(credentials);
      check(b.session!.dataKey!.version).equals(1);
    });

    test('a device it made up gets no keys', () async {
      await pairAll();
      relay.injectDevice(
        credentials.accountIdText,
        SyncDevice(
          deviceId: 'device-Z',
          name: 'Z',
          platform: 'ios',
          publicKey: (await DeviceKeyPair.generate()).publicKey,
          tag: SyncCipher.generateKey(),
        ),
      );
      await a.goOffline();
      await a.connect(relay, SyncOpening.resume);
      await settle();

      await check(a.engine!.revoke(c.deviceId)).throws<SyncRevokeFailure>(
        (it) => it
            .has((f) => f.code, 'code')
            .equals(SyncRevokeFailure.untrustedDevice),
      );
      check(relay.revocations).equals(0);
      check(a.session!.credentials).equals(credentials);
    });
  });

  test('a device that enrolled meanwhile gets the keys too', () async {
    await pairAll();
    final d = _Device('D', await openTestIsar(isarSchemas));
    addTearDown(() async {
      await d.goOffline();
      await d.isar.close(deleteFromDisk: true);
    });
    await d.seedMeta();
    // A, connected before D, does not list it.
    await d.connect(relay, SyncOpening.join, credentials: credentials);
    await settle();

    await a.engine!.revoke(c.deviceId);
    await settle();
    check(relay.revocations).equals(1);

    await d.connect(relay, SyncOpening.resume);
    await settle();
    check(d.session!.credentials).equals(a.session!.credentials);
  });
}
