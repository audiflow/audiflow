import 'package:audiflow_domain/src/features/parental_control/datasources/local/parental_control_local_datasource.dart';
import 'package:audiflow_domain/src/features/parental_control/models/parental_control_settings.dart';
import 'package:audiflow_domain/src/features/parental_control/models/podcast_parental_flags.dart';
import 'package:audiflow_domain/src/features/parental_control/repositories/parental_control_repository_impl.dart';
import 'package:audiflow_domain/src/features/parental_control/services/pin_hasher.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';

import '../../../helpers/isar_test_helper.dart';

/// A [PinHasher] wrapper that records whether [verify] was called.
class _SpyPinHasher extends PinHasher {
  bool verifyCalled = false;

  @override
  bool verify({
    required String pin,
    required ParentalControlSettings settings,
  }) {
    verifyCalled = true;
    return super.verify(pin: pin, settings: settings);
  }
}

final _silentLogger = Logger(level: Level.off);

ParentalControlRepositoryImpl _buildRepo(
  Isar isar, {
  PinHasher? hasher,
  DateTime Function()? clock,
}) {
  return ParentalControlRepositoryImpl(
    datasource: ParentalControlLocalDataSource(isar: isar),
    hasher: hasher ?? PinHasher(),
    logger: _silentLogger,
    clock: clock,
  );
}

void main() {
  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  late Isar isar;
  late ParentalControlRepositoryImpl repo;

  setUp(() async {
    isar = await openTestIsar([
      ParentalControlSettingsSchema,
      PodcastParentalFlagsSchema,
    ]);
    repo = _buildRepo(isar);
  });

  tearDown(() async {
    if (isar.isOpen) await isar.close(deleteFromDisk: true);
  });

  group('ParentalControlRepositoryImpl', () {
    test('setPin / verifyPin round-trip succeeds', () async {
      await repo.setPin('1234');
      check(await repo.verifyPin('1234')).isTrue();
      check(await repo.verifyPin('0000')).isFalse();
    });

    test('setPin clears failedAttempts and lockoutUntil', () async {
      await repo.registerFailedAttempt();
      await repo.registerFailedAttempt();
      await repo.setPin('1234');
      final s = await repo.getSettings();
      check(s.failedAttempts).equals(0);
      check(s.lockoutUntil).isNull();
    });

    test('setPin rotates salt', () async {
      await repo.setPin('1234');
      final salt1 = (await repo.getSettings()).pinSaltBase64;
      await repo.setPin('5678');
      final salt2 = (await repo.getSettings()).pinSaltBase64;
      check(salt2).not((s) => s.equals(salt1));
    });

    test('clearPin removes hash, salt, and failedAttempts', () async {
      await repo.setPin('1234');
      await repo.clearPin();
      final s = await repo.getSettings();
      check(s.pinHashBase64).isNull();
      check(s.pinSaltBase64).isNull();
      check(s.failedAttempts).equals(0);
    });

    test(
      'registerFailedAttempt increments counter; returns lockout at 5th',
      () async {
        check(await repo.registerFailedAttempt()).isNull();
        check(await repo.registerFailedAttempt()).isNull();
        check(await repo.registerFailedAttempt()).isNull();
        check(await repo.registerFailedAttempt()).isNull();
        final fifth = await repo.registerFailedAttempt();
        check(fifth).isNotNull();
        check(fifth!.inSeconds).equals(30);
      },
    );

    test(
      'registerFailedAttempt backoff sequence: 30s, 60s, 120s, 240s, 300s cap',
      () async {
        for (var i = 0; i < 4; i++) {
          await repo.registerFailedAttempt();
        }
        check((await repo.registerFailedAttempt())!.inSeconds).equals(30);
        check((await repo.registerFailedAttempt())!.inSeconds).equals(60);
        check((await repo.registerFailedAttempt())!.inSeconds).equals(120);
        check((await repo.registerFailedAttempt())!.inSeconds).equals(240);
        check((await repo.registerFailedAttempt())!.inSeconds).equals(300);
        check((await repo.registerFailedAttempt())!.inSeconds).equals(300);
      },
    );

    test('clearFailedAttempts resets counter and lockoutUntil', () async {
      for (var i = 0; i < 6; i++) {
        await repo.registerFailedAttempt();
      }
      await repo.clearFailedAttempts();
      final s = await repo.getSettings();
      check(s.failedAttempts).equals(0);
      check(s.lockoutUntil).isNull();
    });

    test('setRestrictedMode and setUnlockTimeout persist', () async {
      await repo.setRestrictedMode(true);
      await repo.setUnlockTimeout(const Duration(minutes: 10));
      final s = await repo.getSettings();
      check(s.restrictedModeEnabled).isTrue();
      check(s.unlockTimeoutMs).equals(600000);
    });

    test('setHideExplicit and getHideExplicit round-trip', () async {
      check(await repo.getHideExplicit(99)).isFalse();
      await repo.setHideExplicit(99, true);
      check(await repo.getHideExplicit(99)).isTrue();
    });

    test('lockoutUntil persists exact timestamp on 5th failure', () async {
      // Use local time — Isar stores DateTime without timezone and returns
      // it as local, so a UTC instant would compare unequal after round-trip.
      final fixedNow = DateTime(2025, 1, 1, 12);
      final timedRepo = _buildRepo(isar, clock: () => fixedNow);
      for (var i = 0; i < 4; i++) {
        await timedRepo.registerFailedAttempt();
      }
      await timedRepo.registerFailedAttempt();
      final s = await timedRepo.getSettings();
      check(s.lockoutUntil).equals(fixedNow.add(const Duration(seconds: 30)));
    });

    test(
      'singleton row stays unique under repeated getSettings calls',
      () async {
        await repo.getSettings();
        await repo.getSettings();
        await repo.getSettings();
        final count = await isar.parentalControlSettings.count();
        check(count).equals(1);
      },
    );

    test(
      'verifyPin returns false during active lockout window without invoking hasher',
      () async {
        // Use local time — Isar strips timezone and returns local DateTime.
        final fixedNow = DateTime(2025, 1, 1, 12);
        final spy = _SpyPinHasher();
        // Build a repo whose clock is frozen inside the lockout window.
        final lockedRepo = _buildRepo(isar, hasher: spy, clock: () => fixedNow);

        // Trigger lockout via 5 failures using the same frozen clock.
        for (var i = 0; i < 5; i++) {
          await lockedRepo.registerFailedAttempt();
        }
        spy.verifyCalled = false; // reset after setup calls

        final result = await lockedRepo.verifyPin('1234');
        check(result).isFalse();
        check(spy.verifyCalled).isFalse();
      },
    );

    test('verifyPin clears failedAttempts on success', () async {
      await repo.setPin('9999');
      for (var i = 0; i < 3; i++) {
        await repo.registerFailedAttempt();
      }
      final ok = await repo.verifyPin('9999');
      check(ok).isTrue();
      final s = await repo.getSettings();
      check(s.failedAttempts).equals(0);
      check(s.lockoutUntil).isNull();
    });

    test(
      'verify rejects when stored pinIterations differs from hash-time value',
      () async {
        await repo.setPin('1234');
        // Mutate the iteration count after hashing — the hash was computed
        // with 100 000 iterations but verification will now use 1001.
        final ds = ParentalControlLocalDataSource(isar: isar);
        await ds.updateSettings((s) {
          s.pinIterations = 1001;
          return s;
        });
        check(await repo.verifyPin('1234')).isFalse();
      },
    );

    test(
      'failedAttempts and lockoutUntil survive a close/reopen cycle',
      () async {
        // Get the directory path before closing.
        final dirPath = isar.directory;
        final name = isar.name;

        for (var i = 0; i < 5; i++) {
          await repo.registerFailedAttempt();
        }
        final beforeClose = await repo.getSettings();
        final expectedLockout = beforeClose.lockoutUntil;

        await isar.close(); // do NOT delete from disk

        // Reopen with same directory and name.
        final isar2 = await Isar.open(
          [ParentalControlSettingsSchema, PodcastParentalFlagsSchema],
          directory: dirPath!,
          name: name,
        );
        addTearDown(() async {
          if (isar2.isOpen) await isar2.close(deleteFromDisk: true);
        });

        final repo2 = _buildRepo(isar2);
        final s = await repo2.getSettings();
        check(s.failedAttempts).equals(5);
        check(s.lockoutUntil).equals(expectedLockout);
        // isar2 is closed by addTearDown above; the outer tearDown guards with
        // isOpen so no double-close occurs.
      },
    );
  });
}
