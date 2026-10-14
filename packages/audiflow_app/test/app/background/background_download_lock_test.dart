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

    test('acquires when the holder releases mid-check', () async {
      // The holder deletes the lock after exists() but before the stat.
      final lockFile = File('${tempDir.path}/.background_download.lock');
      final acquired = await IOOverrides.runZoned(
        () => createLock().tryAcquire(),
        createFile: (_) => _VanishingLockFile(lockFile),
      );

      check(acquired).isTrue();
    });
  });
}

/// Reports the lock as present, then fails the stat as if it was deleted.
class _VanishingLockFile extends Fake implements File {
  _VanishingLockFile(this._real);

  final File _real;

  @override
  String get path => _real.path;

  @override
  Future<bool> exists() async => true;

  @override
  Future<DateTime> lastModified() async => throw PathNotFoundException(
    path,
    const OSError('No such file or directory', 2),
  );

  @override
  Future<File> create({bool recursive = false, bool exclusive = false}) =>
      _real.create(recursive: recursive, exclusive: exclusive);

  @override
  Future<void> setLastModified(DateTime time) => _real.setLastModified(time);
}
