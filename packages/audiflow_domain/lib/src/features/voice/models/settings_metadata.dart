import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_metadata.freezed.dart';

/// Describes the data type of a voice-controllable setting.
enum SettingType {
  /// A true/false toggle setting.
  boolean,

  /// An integer value setting.
  intValue,

  /// A floating-point value setting.
  doubleValue,

  /// A setting with a fixed set of named options.
  enumValue,
}

/// Defines the valid values for a voice-controllable setting.
///
/// Used by the NLU pipeline to validate and constrain parsed setting values
/// before applying them.
@freezed
sealed class SettingConstraints with _$SettingConstraints {
  /// Constraints for a boolean (on/off) setting.
  const factory SettingConstraints.boolean() = BooleanConstraints;

  /// Constraints for a numeric setting with a continuous range.
  const factory SettingConstraints.range({
    /// Minimum allowed value.
    required double min,

    /// Maximum allowed value.
    required double max,

    /// Increment step between valid values.
    required double step,
  }) = RangeConstraints;

  /// Constraints for a setting with a discrete list of valid string values.
  const factory SettingConstraints.options({
    /// Allowed string values.
    required List<String> values,
  }) = OptionsConstraints;
}

/// Describes a single voice-controllable app setting.
///
/// Provides the AI matching pipeline with the information needed to identify
/// which setting the user is referring to (via [synonyms]) and how to validate
/// the requested value (via [constraints]).
@freezed
sealed class SettingMetadata with _$SettingMetadata {
  const factory SettingMetadata({
    /// Stable programmatic identifier for the setting (matches repository key).
    required String key,

    /// Localization key used to look up the human-readable display name.
    required String displayNameKey,

    /// Data type of this setting.
    required SettingType type,

    /// Validation constraints that bound acceptable values.
    required SettingConstraints constraints,

    /// Alternative phrases users might say to refer to this setting.
    ///
    /// Used by the NLU layer for fuzzy matching against voice input.
    required List<String> synonyms,
  }) = _SettingMetadata;
}
