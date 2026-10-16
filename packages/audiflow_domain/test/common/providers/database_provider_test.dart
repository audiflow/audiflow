import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';

class _FakeIsar implements Isar {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _eagain = 'Cannot open Environment: MdbxError (11): Try again';
const _noDelays = [Duration.zero, Duration.zero, Duration.zero];

void main() {
  late Directory directory;
  late File dbFile;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('isar_open_test');
    dbFile = File('${directory.path}/audiflow.isar')..writeAsStringSync('db');
  });

  tearDown(() async {
    await directory.delete(recursive: true);
  });

  test('retries transient EAGAIN and keeps database files', () async {
    final isar = _FakeIsar();
    var attempts = 0;

    final result = await openIsarWithRecovery(
      directory: directory.path,
      transientRetryDelays: _noDelays,
      opener: () async {
        attempts++;
        if (attempts < 3) throw IsarError(_eagain);
        return isar;
      },
    );

    check(result).identicalTo(isar);
    check(attempts).equals(3);
    check(dbFile.existsSync()).isTrue();
  });

  test('rethrows EAGAIN after retries are exhausted', () async {
    var attempts = 0;

    await check(
      openIsarWithRecovery(
        directory: directory.path,
        transientRetryDelays: _noDelays,
        opener: () async {
          attempts++;
          throw IsarError(_eagain);
        },
      ),
    ).throws<IsarError>();

    check(attempts).equals(_noDelays.length + 1);
    check(dbFile.existsSync()).isTrue();
  });

  test('does not retry other non-schema errors', () async {
    var attempts = 0;

    await check(
      openIsarWithRecovery(
        directory: directory.path,
        transientRetryDelays: _noDelays,
        opener: () async {
          attempts++;
          throw IsarError('No space left on device');
        },
      ),
    ).throws<IsarError>();

    check(attempts).equals(1);
    check(dbFile.existsSync()).isTrue();
  });

  for (final message in [
    'Cannot open Environment: MdbxError (110): Connection timed out',
    'Try again later',
  ]) {
    test('does not retry near-miss error "$message"', () async {
      var attempts = 0;

      await check(
        openIsarWithRecovery(
          directory: directory.path,
          transientRetryDelays: _noDelays,
          opener: () async {
            attempts++;
            throw IsarError(message);
          },
        ),
      ).throws<IsarError>();

      check(attempts).equals(1);
    });
  }

  test('retries EAGAIN on the reopen after schema recovery', () async {
    final isar = _FakeIsar();
    var attempts = 0;

    final result = await openIsarWithRecovery(
      directory: directory.path,
      transientRetryDelays: _noDelays,
      opener: () async {
        attempts++;
        if (attempts == 1) throw IsarError('Schema mismatch');
        if (attempts == 2) throw IsarError(_eagain);
        return isar;
      },
    );

    check(result).identicalTo(isar);
    check(attempts).equals(3);
    check(dbFile.existsSync()).isFalse();
  });

  test('deletes files and reopens on schema mismatch', () async {
    final isar = _FakeIsar();
    var attempts = 0;

    final result = await openIsarWithRecovery(
      directory: directory.path,
      transientRetryDelays: _noDelays,
      opener: () async {
        attempts++;
        if (attempts == 1) throw IsarError('Schema mismatch');
        return isar;
      },
    );

    check(result).identicalTo(isar);
    check(dbFile.existsSync()).isFalse();
  });
}
