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
    await ref.read(parentalControlRepositoryProvider).setupPin(pin);
    ref.read(parentalControlGateProvider.notifier).lock();
  }

  Future<void> setRestrictedMode(bool enabled) =>
      ref.read(parentalControlRepositoryProvider).setRestrictedMode(enabled);

  Future<void> setUnlockTimeout(Duration timeout) =>
      ref.read(parentalControlRepositoryProvider).setUnlockTimeout(timeout);
}
