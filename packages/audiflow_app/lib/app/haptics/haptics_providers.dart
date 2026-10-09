import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'method_channel_haptic_player.dart';

part 'haptics_providers.g.dart';

/// Controls the user's haptic feedback level (on, reduced, off).
@Riverpod(keepAlive: true)
class HapticFeedbackLevelController extends _$HapticFeedbackLevelController {
  @override
  HapticFeedbackLevel build() {
    final repo = ref.watch(appSettingsRepositoryProvider);
    return repo.getHapticFeedbackLevel();
  }

  /// Persists [level] and updates the reactive state.
  Future<void> setLevel(HapticFeedbackLevel level) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    await repo.setHapticFeedbackLevel(level);
    state = level;
  }
}

/// The native haptic player, before the user's level is applied.
@Riverpod(keepAlive: true)
HapticPlayer platformHapticPlayer(Ref ref) => const MethodChannelHapticPlayer();

/// Whether the device has haptic hardware. Asked once per launch.
@Riverpod(keepAlive: true)
Future<bool> hapticsSupported(Ref ref) =>
    const MethodChannelHapticPlayer().isSupported();

/// The level in effect: the user's choice, or off on a device without
/// haptics. Assumes support until the device answers.
@Riverpod(keepAlive: true)
HapticFeedbackLevel effectiveHapticFeedbackLevel(Ref ref) {
  final supported = ref.watch(hapticsSupportedProvider).value ?? true;
  if (!supported) return HapticFeedbackLevel.off;
  return ref.watch(hapticFeedbackLevelControllerProvider);
}

/// The player the app injects into `HapticsScope`, gated by the effective
/// level. Rebuilds when the level changes.
@Riverpod(keepAlive: true)
HapticPlayer hapticPlayer(Ref ref) => LevelGatedHapticPlayer(
  level: ref.watch(effectiveHapticFeedbackLevelProvider),
  inner: ref.watch(platformHapticPlayerProvider),
);
