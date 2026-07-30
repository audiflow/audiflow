import 'package:audiflow_app/features/parental_control/presentation/controllers/parental_control_controller.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repository whose writes span at least one event-loop turn, mirroring the
/// real implementation (PBKDF2 hashing plus an Isar transaction).
class _SlowRepo implements ParentalControlRepository {
  final setupPinCalls = <String>[];

  @override
  Future<void> setupPin(String pin) async {
    await Future<void>.delayed(Duration.zero);
    setupPinCalls.add(pin);
  }

  @override
  Future<void> setPin(String pin) async {
    await Future<void>.delayed(Duration.zero);
  }

  @override
  Future<bool> verifyPin(String pin) async => false;

  @override
  Future<void> clearPin() async {}

  @override
  Future<ParentalControlSettings> getSettings() async =>
      ParentalControlSettings();

  @override
  Stream<ParentalControlSettings> watchSettings() => const Stream.empty();

  @override
  Future<void> setRestrictedMode(bool enabled) async {}

  @override
  Future<void> setUnlockTimeout(Duration timeout) async {}

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

void main() {
  group('ParentalControlController', () {
    test(
      'setupPin locks the gate when the controller is only read, not watched',
      () async {
        final repo = _SlowRepo();
        final container = ProviderContainer(
          overrides: [
            parentalControlRepositoryProvider.overrideWithValue(repo),
          ],
        );
        addTearDown(container.dispose);

        // Screens call the controller through `read`, so nothing keeps the
        // auto-dispose provider alive across the await inside setupPin.
        await container
            .read(parentalControlControllerProvider.notifier)
            .setupPin('4321');

        check(repo.setupPinCalls).deepEquals(['4321']);
        check(container.read(parentalControlGateProvider)).isA<Locked>();
      },
    );
  });
}
