import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_change_payload.freezed.dart';

/// Direction of a relative settings change.
enum ChangeDirection {
  /// The setting should increase.
  increase,

  /// The setting should decrease.
  decrease,
}

/// Magnitude of a relative settings change.
enum ChangeMagnitude {
  /// A small adjustment.
  small,

  /// A moderate adjustment.
  medium,

  /// A large adjustment.
  large,
}

/// A single candidate interpretation when the AI is uncertain which setting
/// the user intends to change.
@freezed
sealed class SettingsCandidate with _$SettingsCandidate {
  const factory SettingsCandidate({
    /// The settings key this candidate targets.
    required String key,

    /// The resolved value for this candidate.
    required String value,

    /// Confidence score in [0.0, 1.0] for this candidate.
    required double confidence,
  }) = _SettingsCandidate;
}

/// Structured AI output representing a voice-commanded settings change.
///
/// Three variants capture the full range of AI certainty:
/// - [SettingsChangePayloadAbsolute]: confident key and exact value.
/// - [SettingsChangePayloadRelative]: direction/magnitude only.
/// - [SettingsChangePayloadAmbiguous]: multiple plausible interpretations.
@freezed
sealed class SettingsChangePayload with _$SettingsChangePayload {
  /// The AI is confident about the exact new value.
  const factory SettingsChangePayload.absolute({
    /// Settings key to change.
    required String key,

    /// The resolved absolute value.
    required String value,

    /// Confidence score in [0.0, 1.0].
    required double confidence,
  }) = SettingsChangePayloadAbsolute;

  /// The AI knows the direction and magnitude but not the precise value.
  const factory SettingsChangePayload.relative({
    /// Settings key to change.
    required String key,

    /// Whether to increase or decrease the current value.
    required ChangeDirection direction,

    /// How much to adjust the current value.
    required ChangeMagnitude magnitude,

    /// Confidence score in [0.0, 1.0].
    required double confidence,
  }) = SettingsChangePayloadRelative;

  /// The AI found multiple plausible settings targets.
  const factory SettingsChangePayload.ambiguous({
    /// All plausible interpretations, ordered by descending confidence.
    required List<SettingsCandidate> candidates,
  }) = SettingsChangePayloadAmbiguous;
}
