import 'package:audiflow_core/audiflow_core.dart';

import 'haptic_token.dart';

/// Plays catalog haptics.
///
/// Widgets get one from `HapticsScope.of` and never call a platform haptic
/// API directly, so the catalog stays the single place that decides what
/// each interaction feels like.
abstract interface class HapticPlayer {
  /// Plays [token] immediately. Never throws; a device without haptics
  /// simply plays nothing.
  void play(HapticToken token);

  /// Warms up the hardware for [token] so a later [play] has less latency.
  ///
  /// Call it when a gesture that may play [token] begins (drag start,
  /// long-press down), not immediately before [play]: preparing right
  /// before playing does not reduce latency on iOS.
  void prepare(HapticToken token);
}

/// A [HapticPlayer] that plays nothing.
///
/// The default when no `HapticsScope` is present, which keeps widget tests
/// and previews silent without extra setup.
class NoopHapticPlayer implements HapticPlayer {
  const NoopHapticPlayer();

  @override
  void play(HapticToken token) {}

  @override
  void prepare(HapticToken token) {}
}

/// Applies the user's [HapticFeedbackLevel] before delegating to [inner].
class LevelGatedHapticPlayer implements HapticPlayer {
  const LevelGatedHapticPlayer({required this.level, required this.inner});

  final HapticFeedbackLevel level;
  final HapticPlayer inner;

  @override
  void play(HapticToken token) {
    if (!_allows(token)) return;
    inner.play(token);
  }

  @override
  void prepare(HapticToken token) {
    if (!_allows(token)) return;
    inner.prepare(token);
  }

  bool _allows(HapticToken token) => switch (level) {
    HapticFeedbackLevel.on => true,
    HapticFeedbackLevel.reduced => token.playsInReducedMode,
    HapticFeedbackLevel.off => false,
  };
}
