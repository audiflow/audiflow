import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';

import '../../../helpers/in_memory_relay.dart';
import '../../../helpers/isar_test_helper.dart';

/// One device's key store. [synced] stands in for the credentials that
/// iCloud Keychain shares between stores built on the same map.
class _MemoryStore implements SyncKeyStore {
  _MemoryStore([Map<String, (SyncCredentials, int)>? synced])
    : synced = synced ?? {};

  final Map<String, (SyncCredentials, int)> synced;
  StoredSyncDevice? device;
  bool optedOut = false;
  int _clock = 0;

  @override
  Future<SyncCredentials?> readCredentials(String accountId) async =>
      synced[accountId]?.$1;

  @override
  Future<SyncCredentials?> readLatestCredentials() async {
    final all = synced.values.toList()..sort((a, b) => a.$2.compareTo(b.$2));
    return all.lastOrNull?.$1;
  }

  @override
  Future<void> writeCredentials(SyncCredentials c) async =>
      synced[c.accountIdText] = (c, ++_clock + synced.length);

  @override
  Future<StoredSyncDevice?> readDevice() async => device;

  @override
  Future<void> writeDevice(StoredSyncDevice d) async => device = d;

  @override
  Future<void> deleteDevice() async => device = null;

  @override
  Future<bool> readOptedOut() async => optedOut;

  @override
  Future<void> writeOptedOut({required bool optedOut}) async =>
      this.optedOut = optedOut;
}

void main() {
  late InMemoryRelay relay;
  final isars = <Isar>[];
  final controllers = <SyncController>[];
  final relayUrl = Uri.parse('https://relay.test');

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() {
    relay = InMemoryRelay();
  });

  tearDown(() async {
    for (final c in controllers) {
      await c.dispose();
    }
    controllers.clear();
    for (final isar in isars) {
      await isar.close(deleteFromDisk: true);
    }
    isars.clear();
  });

  Future<Isar> newIsar(String name) async {
    final isar = await openTestIsar(isarSchemas);
    await isar.writeTxn(
      () => isar.syncMetas.put(SyncMeta()..historyId = 'history-$name'),
    );
    isars.add(isar);
    return isar;
  }

  SyncController controller(
    Isar isar,
    _MemoryStore store, {
    String deviceId = 'device-a',
    bool noRelay = false,
  }) {
    final c = SyncController(
      isar: isar,
      store: store,
      relayUrl: noRelay ? null : relayUrl,
      deviceId: () async => deviceId,
      deviceName: deviceId,
      platform: 'ios',
      appVersion: () => '2.3.0',
      syncFeeds: (_) async {},
      logger: Logger(level: Level.off),
      openTransport: (_, _) async => relay.connect(),
      retryDelay: (_) => Duration.zero,
    );
    controllers.add(c);
    return c;
  }

  Future<void> reach(SyncController c, SyncPhase phase) async {
    if (c.status.phase == phase) return;
    await c.statusChanges
        .firstWhere((s) => s.phase == phase)
        .timeout(const Duration(seconds: 5));
  }

  test('without a relay sync is unavailable and stays so', () async {
    final c = controller(await newIsar('a'), _MemoryStore(), noRelay: true);
    await c.load();

    check(c.status.phase).equals(SyncPhase.unavailable);
    await check(c.turnOn()).throws<StateError>();
  });

  test('turning on creates the account and stores the session', () async {
    final store = _MemoryStore();
    final c = controller(await newIsar('a'), store);
    await c.load();
    check(c.status.phase).equals(SyncPhase.off);

    c.setActive(true);
    await c.turnOn();
    await reach(c, SyncPhase.connected);

    check(store.synced).length.equals(1);
    check(store.device).isNotNull()
      ..has((d) => d.token, 'token').isNotNull()
      ..has((d) => d.dataKey, 'dataKey').isNotNull();
  });

  test('another device joins with the credentials', () async {
    final a = controller(await newIsar('a'), _MemoryStore());
    await a.load();
    a.setActive(true);
    await a.turnOn();
    await reach(a, SyncPhase.connected);

    final storeB = _MemoryStore();
    final b = controller(await newIsar('b'), storeB, deviceId: 'device-b');
    await b.load();
    b.setActive(true);
    await b.join(a.credentials!);
    await reach(b, SyncPhase.connected);

    check(storeB.device).isNotNull().has((d) => d.token, 'token').isNotNull();
    check(
      b.devices.map((d) => d.deviceId).toSet(),
    ).deepEquals({'device-a', 'device-b'});
    check(b.deviceId).equals('device-b');
  });

  test('a later launch resumes with the stored token', () async {
    final store = _MemoryStore();
    final isar = await newIsar('a');
    final first = controller(isar, store);
    await first.load();
    first.setActive(true);
    await first.turnOn();
    await reach(first, SyncPhase.connected);
    await first.dispose();
    controllers.remove(first);
    relay.received.clear();

    final again = controller(isar, store);
    await again.load();
    again.setActive(true);
    await reach(again, SyncPhase.connected);

    check(relay.received.single).contains('"type":"hello"');
  });

  test('credentials from another install join again', () async {
    final a = controller(await newIsar('a'), _MemoryStore());
    await a.load();
    a.setActive(true);
    await a.turnOn();
    await reach(a, SyncPhase.connected);

    // As iCloud Keychain brings the credentials, and a device record of
    // the old install, to a reinstalled app with a new device id.
    final store = _MemoryStore()
      ..synced[a.credentials!.accountIdText] = (a.credentials!, 1)
      ..device = StoredSyncDevice(
        accountId: a.credentials!.accountIdText,
        deviceId: 'old-install',
        name: 'old',
        platform: 'ios',
        privateKey: (await DeviceKeyPair.generate()).privateKey,
        token: 'stale',
      );
    relay.received.clear();
    final b = controller(await newIsar('b'), store, deviceId: 'device-b');
    await b.load();
    b.setActive(true);
    await reach(b, SyncPhase.connected);

    check(relay.received.first).contains('"type":"enroll"');
    check(store.device!.deviceId).equals('device-b');
  });

  test('a new install joins the account its other devices share', () async {
    final synced = <String, (SyncCredentials, int)>{};
    final a = controller(await newIsar('a'), _MemoryStore(synced));
    await a.load();
    a.setActive(true);
    await a.turnOn();
    await reach(a, SyncPhase.connected);

    final b = controller(
      await newIsar('b'),
      _MemoryStore(synced),
      deviceId: 'device-b',
    );
    await b.load();
    b.setActive(true);
    await reach(b, SyncPhase.connected);

    check(b.credentials!.accountIdText).equals(a.credentials!.accountIdText);
  });

  test('turning off on one device leaves the others on', () async {
    final synced = <String, (SyncCredentials, int)>{};
    final storeA = _MemoryStore(synced);
    final isarA = await newIsar('a');
    final a = controller(isarA, storeA);
    await a.load();
    a.setActive(true);
    await a.turnOn();
    await reach(a, SyncPhase.connected);
    final storeB = _MemoryStore(synced);
    final b = controller(await newIsar('b'), storeB, deviceId: 'device-b');
    await b.load();
    b.setActive(true);
    await reach(b, SyncPhase.connected);

    await b.turnOff();

    check(synced).length.equals(1);
    check(storeB.optedOut).isTrue();
    // A starts again and still resumes.
    await a.dispose();
    controllers.remove(a);
    final again = controller(isarA, storeA);
    await again.load();
    again.setActive(true);
    await reach(again, SyncPhase.connected);
  });

  test('a device that turned sync off stays off', () async {
    final synced = <String, (SyncCredentials, int)>{};
    final a = controller(await newIsar('a'), _MemoryStore(synced));
    await a.load();
    a.setActive(true);
    await a.turnOn();
    await reach(a, SyncPhase.connected);

    final b = controller(
      await newIsar('b'),
      _MemoryStore(synced)..optedOut = true,
      deviceId: 'device-b',
    );
    await b.load();

    check(b.status.phase).equals(SyncPhase.off);
    check(b.isOn).isFalse();
  });

  test('a new account survives a restart before reaching the relay', () async {
    final store = _MemoryStore();
    final isar = await newIsar('a');
    final first = controller(isar, store);
    await first.load();
    // Inactive: nothing is sent before the app stops.
    await first.turnOn();
    await first.dispose();
    controllers.remove(first);

    final again = controller(isar, store);
    await again.load();
    again.setActive(true);
    await reach(again, SyncPhase.connected);

    check(relay.received.first).contains('"type":"create"');
  });

  test('joining starts from cursor 0', () async {
    final isarB = await newIsar('b');
    await isarB.writeTxn(() async {
      final meta = (await isarB.syncMetas.get(SyncMeta.singletonId))!;
      await isarB.syncMetas.put(meta..serverCursor = 100);
    });
    final a = controller(await newIsar('a'), _MemoryStore());
    await a.load();
    a.setActive(true);
    await a.turnOn();
    await reach(a, SyncPhase.connected);

    final b = controller(isarB, _MemoryStore(), deviceId: 'device-b');
    await b.load();
    await b.join(a.credentials!);

    check(
      (await isarB.syncMetas.get(SyncMeta.singletonId))!.serverCursor,
    ).equals(0);
  });

  test('a second setup while one runs is refused', () async {
    final store = _MemoryStore();
    final c = controller(await newIsar('a'), store);
    await c.load();

    final first = c.turnOn();
    await check(c.join(SyncCredentials.generate())).throws<StateError>();
    await first;

    check(store.synced).length.equals(1);
    check(c.credentials!.accountIdText).equals(store.synced.keys.single);
  });

  test('active again while closing reconnects', () async {
    final c = controller(await newIsar('a'), _MemoryStore());
    await c.load();
    c.setActive(true);
    await c.turnOn();
    await reach(c, SyncPhase.connected);

    c
      ..setActive(false)
      ..setActive(true);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await reach(c, SyncPhase.connected);
  });

  test('turning off during the startup load stays off', () async {
    final store = _MemoryStore();
    final isar = await newIsar('a');
    final first = controller(isar, store);
    await first.load();
    first.setActive(true);
    await first.turnOn();
    await reach(first, SyncPhase.connected);
    await first.dispose();
    controllers.remove(first);

    final again = controller(isar, store)..setActive(true);
    final loading = again.load();
    await again.turnOff();
    await loading;
    await Future<void>.delayed(const Duration(milliseconds: 20));

    check(again.isOn).isFalse();
    check(again.status.phase).equals(SyncPhase.off);
    check(store.device).isNull();
  });

  test('a dropped connection is retried', () async {
    final c = controller(await newIsar('a'), _MemoryStore());
    await c.load();
    c.setActive(true);
    await c.turnOn();
    await reach(c, SyncPhase.connected);

    await relay.disconnectAll();
    await reach(c, SyncPhase.retrying);
    await reach(c, SyncPhase.connected);
  });

  test('going inactive closes the connection without retrying', () async {
    final c = controller(await newIsar('a'), _MemoryStore());
    await c.load();
    c.setActive(true);
    await c.turnOn();
    await reach(c, SyncPhase.connected);

    c.setActive(false);
    await reach(c, SyncPhase.idle);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    check(c.status.phase).equals(SyncPhase.idle);
  });

  test('a refused device stops until it is active again', () async {
    final a = controller(await newIsar('a'), _MemoryStore());
    await a.load();
    a.setActive(true);
    await a.turnOn();
    await reach(a, SyncPhase.connected);

    // Wrong sync key for the account.
    final forged = SyncCredentials(
      accountId: a.credentials!.accountId,
      syncKey: List.filled(32, 7),
    );
    final b = controller(await newIsar('b'), _MemoryStore(), deviceId: 'b');
    await b.load();
    b.setActive(true);
    await b.join(forged);
    await reach(b, SyncPhase.failed);

    check(b.status.failure).equals(RelayError.unauthorized);

    // Playback can keep it active; coming to the foreground retries.
    b.onForeground();
    await reach(b, SyncPhase.failed);
  });

  test('turning off forgets the secrets', () async {
    final store = _MemoryStore();
    final c = controller(await newIsar('a'), store);
    await c.load();
    c.setActive(true);
    await c.turnOn();
    await reach(c, SyncPhase.connected);

    await c.turnOff();

    check(c.status.phase).equals(SyncPhase.off);
    check(store.device).isNull();
    check(store.optedOut).isTrue();
    check(c.isOn).isFalse();
  });
}
