import 'package:audiflow_domain/src/features/parental_control/datasources/local/parental_control_local_datasource.dart';
import 'package:audiflow_domain/src/features/parental_control/models/parental_control_settings.dart';
import 'package:audiflow_domain/src/features/parental_control/models/podcast_parental_flags.dart';
import 'package:audiflow_domain/src/features/parental_control/repositories/parental_control_repository_impl.dart';
import 'package:audiflow_domain/src/features/parental_control/services/pin_hasher.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../helpers/isar_test_helper.dart';

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
    final ds = ParentalControlLocalDataSource(isar: isar);
    repo = ParentalControlRepositoryImpl(datasource: ds, hasher: PinHasher());
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
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
      check(s.unlockTimeoutSeconds).equals(600);
    });

    test('setHideExplicit and getHideExplicit round-trip', () async {
      check(await repo.getHideExplicit(99)).isFalse();
      await repo.setHideExplicit(99, true);
      check(await repo.getHideExplicit(99)).isTrue();
    });
  });
}
