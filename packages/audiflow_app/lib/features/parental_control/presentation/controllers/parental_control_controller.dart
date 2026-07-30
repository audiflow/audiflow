import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'parental_control_controller.g.dart';

/// Stateless action holder for parental control write operations.
///
/// For reads, watch [parentalControlSettingsStreamProvider] directly.
@riverpod
class ParentalControlController extends _$ParentalControlController {
  @override
  void build() {}

  Future<void> setPin(String pin) =>
      ref.read(parentalControlRepositoryProvider).setPin(pin);

  /// First-time setup: persists the PIN, enables Restricted Mode in the same
  /// atomic write, and locks the gate so the restriction applies immediately.
  Future<void> setupPin(String pin) async {
    // Callers reach this notifier through `read`, so nothing keeps this
    // auto-dispose provider alive across the await. Resolve both dependencies
    // up front; touching `ref` afterwards would throw on a disposed Ref and
    // surface as a save failure even though the PIN was persisted.
    final repository = ref.read(parentalControlRepositoryProvider);
    final gate = ref.read(parentalControlGateProvider.notifier);
    await repository.setupPin(pin);
    gate.lock();
  }

  Future<void> setRestrictedMode(bool enabled) =>
      ref.read(parentalControlRepositoryProvider).setRestrictedMode(enabled);

  Future<void> setUnlockTimeout(Duration timeout) =>
      ref.read(parentalControlRepositoryProvider).setUnlockTimeout(timeout);
}
