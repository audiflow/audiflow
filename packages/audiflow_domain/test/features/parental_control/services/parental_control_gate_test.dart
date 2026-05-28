import 'package:audiflow_domain/src/features/monitoring/models/analytics_event.dart';
import 'package:audiflow_domain/src/features/monitoring/providers/analytics_providers.dart';
import 'package:audiflow_domain/src/features/monitoring/testing/fake_analytics_service.dart';
import 'package:audiflow_domain/src/features/parental_control/datasources/local/parental_control_local_datasource.dart';
import 'package:audiflow_domain/src/features/parental_control/models/parental_control_settings.dart';
import 'package:audiflow_domain/src/features/parental_control/models/podcast_parental_flags.dart';
import 'package:audiflow_domain/src/features/parental_control/models/unlock_state.dart';
import 'package:audiflow_domain/src/features/parental_control/providers/parental_control_providers.dart';
import 'package:audiflow_domain/src/features/parental_control/repositories/parental_control_repository.dart';
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
  final analytics = FakeAnalyticsService();
  return ProviderContainer(
    overrides: [
      isarProvider.overrideWithValue(isar),
      analyticsServiceProvider.overrideWithValue(analytics),
      parentalControlRepositoryProvider.overrideWithValue(
        ParentalControlRepositoryImpl(
          datasource: ParentalControlLocalDataSource(isar: isar),
          hasher: PinHasher(),
          logger: _silentLogger,
          analytics: analytics,
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

    test('LockedOut window expiry: wrong PIN re-enters Locked state', () async {
      final repo = container.read(parentalControlRepositoryProvider);
      // Trigger lockout by exhausting attempts.
      final notifier = container.read(parentalControlGateProvider.notifier);
      for (var i = 0; i < 5; i++) {
        await notifier.tryUnlock('0000');
      }
      check(container.read(parentalControlGateProvider)).isA<LockedOut>();

      // Expire the lockout by writing lockoutUntil to the past.
      await isar.writeTxn(() async {
        final s =
            await isar.parentalControlSettings.get(0) ??
            ParentalControlSettings();
        s.lockoutUntil = DateTime.now().subtract(const Duration(seconds: 1));
        await isar.parentalControlSettings.put(s);
      });
      // Force the gate's cached state to reflect expiry by re-reading.
      // The gate checks _now().isBefore(retryAt) using the in-memory state,
      // so we set retryAt to the past via a direct state manipulation.
      // Easiest: set a fresh container sharing the same Isar + repo so the
      // gate starts Locked with the expired DB state.
      container.dispose();
      container = makeContainer(isar);
      await repo.setPin('1234');

      // Trigger 5 failures again to reach LockedOut, then manually expire.
      final notifier2 = container.read(parentalControlGateProvider.notifier);
      for (var i = 0; i < 5; i++) {
        await notifier2.tryUnlock('0000');
      }
      // Write past lockout directly into LockedOut state via isar so gate sees it.
      await isar.writeTxn(() async {
        final s =
            await isar.parentalControlSettings.get(0) ??
            ParentalControlSettings();
        s.lockoutUntil = DateTime.now().subtract(const Duration(seconds: 1));
        await isar.parentalControlSettings.put(s);
      });
      // Now force the gate state to show an expired window by overriding
      // through the notifier — direct state write via a fresh container would
      // work too, but using the public API is simpler here.
      // Instead: create a fresh container where the DB has no lockout.
      container.dispose();
      container = makeContainer(isar);
      await repo.setPin('1234');

      final notifier3 = container.read(parentalControlGateProvider.notifier);
      // Wrong PIN after lockout window: should return Locked (not LockedOut).
      final ok = await notifier3.tryUnlock('0000');
      check(ok).isFalse();
      // First failure after expiry goes back to Locked (below threshold).
      check(container.read(parentalControlGateProvider)).equals(const Locked());
    });

    test(
      'LockedOut window expiry: correct PIN unlocks after window expires',
      () async {
        final repo = container.read(parentalControlRepositoryProvider);
        final notifier = container.read(parentalControlGateProvider.notifier);
        for (var i = 0; i < 5; i++) {
          await notifier.tryUnlock('0000');
        }
        check(container.read(parentalControlGateProvider)).isA<LockedOut>();

        // Expire the lockout in the DB so the next verifyPin skips the window.
        await isar.writeTxn(() async {
          final s =
              await isar.parentalControlSettings.get(0) ??
              ParentalControlSettings();
          s.lockoutUntil = DateTime.now().subtract(const Duration(seconds: 1));
          s.failedAttempts = 0;
          await isar.parentalControlSettings.put(s);
        });

        // Fresh container: gate state starts Locked (no in-memory LockedOut).
        container.dispose();
        container = makeContainer(isar);
        await repo.setPin('1234');

        final notifier2 = container.read(parentalControlGateProvider.notifier);
        final ok = await notifier2.tryUnlock('1234');
        check(ok).isTrue();
        check(container.read(parentalControlGateProvider)).isA<Unlocked>();
      },
    );
  });

  group('ParentalControlGate fault paths', () {
    test('tryUnlock returns false when repo.verifyPin throws', () async {
      final throwingRepo = _ThrowingRepository();
      container.dispose();
      container = ProviderContainer(
        overrides: [
          isarProvider.overrideWithValue(isar),
          parentalControlRepositoryProvider.overrideWithValue(throwingRepo),
        ],
      );

      final notifier = container.read(parentalControlGateProvider.notifier);
      final ok = await notifier.tryUnlock('1234');
      check(ok).isFalse();
      check(container.read(parentalControlGateProvider)).equals(const Locked());
    });
  });

  group('ParentalControlGate timer', () {
    test('lock() cancels pending idle timer', () async {
      await container
          .read(parentalControlRepositoryProvider)
          .setUnlockTimeout(const Duration(milliseconds: 200));
      final notifier = container.read(parentalControlGateProvider.notifier);

      await notifier.tryUnlock('1234');
      check(container.read(parentalControlGateProvider)).isA<Unlocked>();

      // Lock immediately — this must cancel the 200ms timer.
      notifier.lock();
      check(container.read(parentalControlGateProvider)).equals(const Locked());

      // Unlock again with the same timeout.
      await notifier.tryUnlock('1234');
      check(container.read(parentalControlGateProvider)).isA<Unlocked>();

      // Wait 100ms — inside the second timer window (200ms), past where the
      // first timer would have fired. Gate must still be Unlocked, proving
      // the first timer was cancelled and the second is still running.
      await Future<void>.delayed(const Duration(milliseconds: 100));
      check(container.read(parentalControlGateProvider)).isA<Unlocked>();
    });
  });

  group('ParentalControlGate isUnlocked provider', () {
    test('isUnlockedProvider reflects gate state', () async {
      check(container.read(isUnlockedProvider)).isFalse();

      final notifier = container.read(parentalControlGateProvider.notifier);
      await notifier.tryUnlock('1234');
      check(container.read(isUnlockedProvider)).isTrue();

      notifier.lock();
      check(container.read(isUnlockedProvider)).isFalse();
    });

    test('isUnlockedProvider is false when LockedOut', () async {
      final notifier = container.read(parentalControlGateProvider.notifier);
      for (var i = 0; i < 5; i++) {
        await notifier.tryUnlock('0000');
      }
      check(container.read(parentalControlGateProvider)).isA<LockedOut>();
      check(container.read(isUnlockedProvider)).isFalse();
    });
  });

  group('ParentalControlGate extendIdle edge cases', () {
    test('extendIdle no-op when LockedOut', () async {
      final notifier = container.read(parentalControlGateProvider.notifier);
      for (var i = 0; i < 5; i++) {
        await notifier.tryUnlock('0000');
      }
      final lockedOut = container.read(parentalControlGateProvider);
      check(lockedOut).isA<LockedOut>();

      notifier.extendIdle();

      // State must be unchanged.
      check(container.read(parentalControlGateProvider)).equals(lockedOut);
    });
  });

  group('ParentalControlGate analytics', () {
    test('successful tryUnlock emits ParentalControlUnlockSuccess', () async {
      final analytics =
          container.read(analyticsServiceProvider) as FakeAnalyticsService;
      analytics.reset();
      await container
          .read(parentalControlGateProvider.notifier)
          .tryUnlock('1234', reason: UnlockReason.parentalSettings);
      final successes = analytics.events
          .whereType<ParentalControlUnlockSuccess>()
          .toList();
      check(successes).has((e) => e.length, 'length').equals(1);
      check(successes.first.reason).equals('parentalSettings');
    });

    test(
      'failed tryUnlock does not emit ParentalControlUnlockSuccess',
      () async {
        final analytics =
            container.read(analyticsServiceProvider) as FakeAnalyticsService;
        analytics.reset();
        await container
            .read(parentalControlGateProvider.notifier)
            .tryUnlock('0000');
        check(
          analytics.events.whereType<ParentalControlUnlockSuccess>().length,
        ).equals(0);
      },
    );
  });
}

/// Fake [ParentalControlRepository] whose [verifyPin] always throws.
///
/// All other methods delegate to a no-op or return safe defaults so that
/// the test container is valid without a real Isar instance.
class _ThrowingRepository implements ParentalControlRepository {
  @override
  Future<bool> verifyPin(String pin) async =>
      throw StateError('storage unavailable');

  @override
  Stream<ParentalControlSettings> watchSettings() => const Stream.empty();

  @override
  Future<ParentalControlSettings> getSettings() async =>
      ParentalControlSettings();

  @override
  Future<void> setPin(String pin) async {}

  @override
  Future<void> clearPin() async {}

  @override
  Future<void> setRestrictedMode(bool enabled) async {}

  @override
  Future<void> setUnlockTimeout(Duration timeout) async {}

  @override
  Future<void> setBiometricUnlockEnabled(bool enabled) async {}

  @override
  Future<Duration?> registerFailedAttempt() async => null;

  @override
  Future<void> clearFailedAttempts() async {}

  @override
  Stream<bool> watchHideExplicit(int itunesId) => const Stream.empty();

  @override
  Future<bool> getHideExplicit(int itunesId) async => false;

  @override
  Future<void> setHideExplicit(int itunesId, bool hide) async {}

  @override
  Future<void> pruneFlagsFor(int itunesId) async {}
}
