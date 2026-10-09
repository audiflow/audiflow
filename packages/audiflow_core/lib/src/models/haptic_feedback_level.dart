/// How much haptic feedback the app plays.
///
/// See `docs/design/haptics.md` section 5 for which tokens each level
/// keeps. OS-level haptic settings still apply on top of this.
enum HapticFeedbackLevel {
  /// Every catalog token plays.
  on,

  /// Only outcomes, gesture thresholds, and drag pick-up play.
  reduced,

  /// No haptic plays.
  off,
}
