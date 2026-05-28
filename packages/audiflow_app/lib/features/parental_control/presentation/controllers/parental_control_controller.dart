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

  Future<void> setRestrictedMode(bool enabled) =>
      ref.read(parentalControlRepositoryProvider).setRestrictedMode(enabled);

  Future<void> setUnlockTimeout(Duration timeout) =>
      ref.read(parentalControlRepositoryProvider).setUnlockTimeout(timeout);
}
