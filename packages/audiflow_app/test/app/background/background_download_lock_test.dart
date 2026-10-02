import 'dart:io';

import 'package:audiflow_app/app/background/background_download_lock.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late DateTime now;

  BackgroundDownloadLock createLock() =>
      BackgroundDownloadLock(directory: tempDir.path, now: () => now);

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('bg_download_lock_');
    now = DateTime.now();
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('BackgroundDownloadLock', () {
    test('acquires when no other worker holds it', () async {
      check(await createLock().tryAcquire()).isTrue();
    });

    test('refuses while another worker holds it', () async {
      await createLock().tryAcquire();

      check(await createLock().tryAcquire()).isFalse();
    });

    test('acquires again after release', () async {
      final first = createLock();
      await first.tryAcquire();
      await first.release();

      check(await createLock().tryAcquire()).isTrue();
    });

    test('takes over a lock left stale by a crashed worker', () async {
      await createLock().tryAcquire();
      now = now.add(BackgroundDownloadLock.staleAfter);

      check(await createLock().tryAcquire()).isTrue();
    });

    test('release by a worker that never acquired keeps the lock', () async {
      await createLock().tryAcquire();
      await createLock().release();

      check(await createLock().tryAcquire()).isFalse();
    });
  });
}
