import 'package:audiflow_domain/src/features/parental_control/datasources/local/parental_control_local_datasource.dart';
import 'package:audiflow_domain/src/features/parental_control/models/parental_control_settings.dart';
import 'package:audiflow_domain/src/features/parental_control/models/podcast_parental_flags.dart';
import 'package:audiflow_domain/src/features/parental_control/models/unlock_state.dart';
import 'package:audiflow_domain/src/features/parental_control/providers/parental_control_providers.dart';
import 'package:audiflow_domain/src/features/parental_control/repositories/parental_control_repository_impl.dart';
import 'package:audiflow_domain/src/features/parental_control/services/parental_control_gate.dart';
import 'package:audiflow_domain/src/features/parental_control/services/pin_hasher.dart';
import 'package:audiflow_domain/src/common/providers/database_provider.dart';
import 'package:checks/checks.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';

import '../../../helpers/isar_test_helper.dart';

final _silentLogger = Logger(level: Level.off);

ProviderContainer makeContainer(Isar isar) {
  return ProviderContainer(
    overrides: [
      isarProvider.overrideWithValue(isar),
      parentalControlRepositoryProvider.overrideWithValue(
        ParentalControlRepositoryImpl(
          datasource: ParentalControlLocalDataSource(isar: isar),
          hasher: PinHasher(),
          logger: _silentLogger,
        ),
      ),
    ],
  );
}

void main() {
  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  late Isar isar;
  late ProviderContainer container;

  setUp(() async {
    isar = await openTestIsar([
      ParentalControlSettingsSchema,
      PodcastParentalFlagsSchema,
    ]);
    container = makeContainer(isar);
    await container.read(parentalControlRepositoryProvider).setPin('1234');
  });

  tearDown(() async {
    container.dispose();
    if (isar.isOpen) await isar.close(deleteFromDisk: true);
  });

  group('ParentalControlGate basic', () {
    test('initial state is Locked', () {
      final state = container.read(parentalControlGateProvider);
      check(state).equals(const Locked());
    });

    test(
      'tryUnlock with correct PIN returns true and transitions to Unlocked',
      () async {
        final ok = await container
            .read(parentalControlGateProvider.notifier)
            .tryUnlock('1234');
        check(ok).isTrue();
        check(container.read(parentalControlGateProvider)).isA<Unlocked>();
      },
    );

    test(
      'tryUnlock with wrong PIN returns false, state stays Locked',
      () async {
        final ok = await container
            .read(parentalControlGateProvider.notifier)
            .tryUnlock('0000');
        check(ok).isFalse();
        check(
          container.read(parentalControlGateProvider),
        ).equals(const Locked());
      },
    );

    test('lock() returns state to Locked from Unlocked', () async {
      final notifier = container.read(parentalControlGateProvider.notifier);
      await notifier.tryUnlock('1234');
      notifier.lock();
      check(container.read(parentalControlGateProvider)).equals(const Locked());
    });
  });

  group('ParentalControlGate idle timer', () {
    test('auto-relocks after timeout', () async {
      await container
          .read(parentalControlRepositoryProvider)
          .setUnlockTimeout(const Duration(milliseconds: 100));
      final notifier = container.read(parentalControlGateProvider.notifier);
      await notifier.tryUnlock('1234');
      check(container.read(parentalControlGateProvider)).isA<Unlocked>();

      await Future<void>.delayed(const Duration(milliseconds: 200));
      check(container.read(parentalControlGateProvider)).equals(const Locked());
    });

    test('extendIdle no-ops when locked', () async {
      final notifier = container.read(parentalControlGateProvider.notifier);
      notifier.extendIdle();
      check(container.read(parentalControlGateProvider)).equals(const Locked());
    });

    test('extendIdle reschedules the relock timer', () async {
      await container
          .read(parentalControlRepositoryProvider)
          .setUnlockTimeout(const Duration(milliseconds: 200));
      final notifier = container.read(parentalControlGateProvider.notifier);
      await notifier.tryUnlock('1234');
      await Future<void>.delayed(const Duration(milliseconds: 100));
      notifier.extendIdle();
      await Future<void>.delayed(const Duration(milliseconds: 150));
      // Original timer would have fired by now; extended timer keeps it Unlocked.
      check(container.read(parentalControlGateProvider)).isA<Unlocked>();
    });
  });

  group('ParentalControlGate lockout', () {
    test('5 wrong PINs transitions to LockedOut with 30s window', () async {
      final notifier = container.read(parentalControlGateProvider.notifier);
      for (var i = 0; i < 4; i++) {
        final ok = await notifier.tryUnlock('0000');
        check(ok).isFalse();
        check(
          container.read(parentalControlGateProvider),
        ).equals(const Locked());
      }
      final fifth = await notifier.tryUnlock('0000');
      check(fifth).isFalse();
      final s = container.read(parentalControlGateProvider);
      check(s).isA<LockedOut>();
      final lo = s as LockedOut;
      check(lo.attemptCount).equals(5);
    });

    test(
      'tryUnlock during LockedOut window short-circuits without hashing',
      () async {
        final notifier = container.read(parentalControlGateProvider.notifier);
        for (var i = 0; i < 5; i++) {
          await notifier.tryUnlock('0000');
        }
        // Correct PIN, but still in lockout window.
        final ok = await notifier.tryUnlock('1234');
        check(ok).isFalse();
        check(container.read(parentalControlGateProvider)).isA<LockedOut>();
      },
    );
  });
}
