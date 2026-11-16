import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  var now = 1000;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([SubscriptionSchema]);
    now = 1000;
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  UserStateStore store() => UserStateStore(
    isar,
    nowMillis: () => now,
    createHistoryId: () => 'history-1',
  );

  test('runs the body in a write transaction and returns its result', () async {
    final result = await store().write((_) async {
      await isar.subscriptions.put(
        Subscription()
          ..itunesId = 'a'
          ..feedUrl = 'https://example.com/a'
          ..title = 'A'
          ..artistName = 'Artist'
          ..subscribedAt = DateTime(2026),
      );
      return 42;
    });

    check(result).equals(42);
    check(await isar.subscriptions.count()).equals(1);
  });

  test('stamps each write with a new clock value and stores it', () async {
    final first = await store().write((stamp) async => stamp);
    final second = await store().write((stamp) async => stamp);

    check(first).equals(const Hlc(1000, 0));
    check(second).equals(const Hlc(1000, 1));
    final meta = await isar.syncMetas.get(SyncMeta.singletonId);
    check(Hlc.unpack(meta!.hlc)).equals(second);
  });

  test(
    'keeps the clock monotonic across instances and a clock set back',
    () async {
      final first = await store().write((stamp) async => stamp);
      now = 10;

      final second = await UserStateStore(
        isar,
        nowMillis: () => now,
      ).write((stamp) async => stamp);

      check(first.compareTo(second)).equals(-1);
    },
  );

  test('creates the history on the first write and keeps it', () async {
    await store().write((_) async {});
    await UserStateStore(
      isar,
      createHistoryId: () => 'history-2',
    ).write((_) async {});

    final meta = await isar.syncMetas.get(SyncMeta.singletonId);
    check(meta?.historyId).equals('history-1');
  });

  test('a failing body rolls back the clock advance', () async {
    await store().write((_) async {});

    await check(
      store().write<void>((_) async => throw StateError('boom')),
    ).throws<StateError>();

    final meta = await isar.syncMetas.get(SyncMeta.singletonId);
    check(Hlc.unpack(meta!.hlc)).equals(const Hlc(1000, 0));
  });

  test('newHistoryId is 22 base64url characters and random', () {
    final a = newHistoryId();
    final b = newHistoryId();

    check(a).matchesPattern(RegExp(r'^[A-Za-z0-9_-]{22}$'));
    check(a).not((it) => it.equals(b));
  });
}
