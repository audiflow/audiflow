import 'dart:async';

import 'package:audiflow_app/app/background/background_isar_lease.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDatabase {
  _FakeDatabase(this.id);

  final int id;
  bool isOpen = true;
}

void main() {
  late int openCount;
  late List<_FakeDatabase> closed;
  late Completer<void>? pendingOpen;

  BackgroundIsarLease<_FakeDatabase> createLease() => BackgroundIsarLease(
    open: () async {
      await pendingOpen?.future;
      return _FakeDatabase(++openCount);
    },
    close: (database) async {
      database.isOpen = false;
      closed.add(database);
    },
  );

  setUp(() {
    openCount = 0;
    closed = [];
    pendingOpen = null;
  });

  group('BackgroundIsarLease', () {
    test('second holder reuses the open instance', () async {
      final lease = createLease();

      final first = await lease.acquire();
      final second = await lease.acquire();

      check(identical(first, second)).isTrue();
      check(openCount).equals(1);
    });

    test('concurrent acquires share one open', () async {
      pendingOpen = Completer<void>();
      final lease = createLease();

      final first = lease.acquire();
      final second = lease.acquire();
      pendingOpen!.complete();

      check(identical(await first, await second)).isTrue();
      check(openCount).equals(1);
    });

    test('closes only when the last holder releases', () async {
      final lease = createLease();
      final database = await lease.acquire();
      await lease.acquire();

      await lease.release(database);
      check(database.isOpen).isTrue();

      await lease.release(database);
      check(database.isOpen).isFalse();
      check(closed).length.equals(1);
    });

    test('reopens after every holder released', () async {
      final lease = createLease();
      final first = await lease.acquire();
      await lease.release(first);

      final second = await lease.acquire();

      check(second.id).equals(2);
      check(second.isOpen).isTrue();
    });

    test('acquire just before the last release keeps it open', () async {
      final lease = createLease();
      final first = await lease.acquire();

      final reacquire = lease.acquire();
      await lease.release(first);
      final second = await reacquire;

      check(identical(first, second)).isTrue();
      check(second.isOpen).isTrue();
      check(closed).isEmpty();
    });

    test('acquire during a pending close reopens after it', () async {
      final closeGate = Completer<void>();
      final lease = BackgroundIsarLease<_FakeDatabase>(
        open: () async => _FakeDatabase(++openCount),
        close: (database) async {
          await closeGate.future;
          database.isOpen = false;
        },
      );
      final first = await lease.acquire();

      final release = lease.release(first);
      final reacquire = lease.acquire();
      closeGate.complete();
      await release;
      final second = await reacquire;

      check(first.isOpen).isFalse();
      check(second.id).equals(2);
      check(second.isOpen).isTrue();
    });

    test('failed open does not leave a holder behind', () async {
      var shouldFail = true;
      final lease = BackgroundIsarLease<_FakeDatabase>(
        open: () async {
          if (shouldFail) throw StateError('open failed');
          return _FakeDatabase(++openCount);
        },
        close: (database) async => database.isOpen = false,
      );

      await check(lease.acquire()).throws<StateError>();
      shouldFail = false;
      final database = await lease.acquire();
      await lease.release(database);

      check(database.isOpen).isFalse();
    });

    test('extra release is ignored', () async {
      final lease = createLease();
      final database = await lease.acquire();
      await lease.release(database);

      await lease.release(database);

      check(closed).length.equals(1);
    });
  });
}
