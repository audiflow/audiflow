import 'dart:math' as math;

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/settings_metadata.dart';
import 'settings_metadata_registry.dart';

part 'settings_intent_resolver.freezed.dart';

/// A resolved candidate when disambiguating between multiple possible settings.
@freezed
sealed class SettingsResolutionCandidate with _$SettingsResolutionCandidate {
  const factory SettingsResolutionCandidate({
    /// The settings key this candidate targets.
    required String key,

    /// The l10n key used to resolve a localized display name.
    required String displayNameKey,

    /// The current value of the setting before the proposed change.
    required String oldValue,

    /// The proposed new value for the setting.
    required String newValue,

    /// Confidence score in [0.0, 1.0] for this candidate.
    required double confidence,
  }) = _SettingsResolutionCandidate;
}

/// The outcome of resolving a [SettingsChangePayload] against the registry.
///
/// Four variants map the full confidence spectrum to UI-appropriate actions:
/// - [SettingsResolutionAutoApply]: apply immediately without user confirmation.
/// - [SettingsResolutionConfirm]: show confirmation UI before applying.
/// - [SettingsResolutionDisambiguate]: present multiple candidates to the user.
/// - [SettingsResolutionNotFound]: no valid match; surface an error.
@freezed
sealed class SettingsResolution with _$SettingsResolution {
  /// High-confidence result: apply the change immediately.
  const factory SettingsResolution.autoApply({
    /// The settings key to modify.
    required String key,

    /// The current value before the change.
    required String oldValue,

    /// The proposed new value.
    required String newValue,
  }) = SettingsResolutionAutoApply;

  /// Low-confidence result: prompt the user for confirmation.
  const factory SettingsResolution.confirm({
    /// The settings key to modify.
    required String key,

    /// The current value before the change.
    required String oldValue,

    /// The proposed new value.
    required String newValue,

    /// Confidence score in [0.0, 1.0].
    required double confidence,
  }) = SettingsResolutionConfirm;

  /// Multiple plausible candidates: prompt the user to pick one.
  const factory SettingsResolution.disambiguate({
    /// All plausible candidates ordered by descending confidence.
    required List<SettingsResolutionCandidate> candidates,
  }) = SettingsResolutionDisambiguate;

  /// No valid match found; the change cannot be resolved.
  const factory SettingsResolution.notFound() = SettingsResolutionNotFound;
}

/// Resolves a [SettingsChangePayload] from the AI layer into a concrete
/// [SettingsResolution] using registry metadata and the current setting values.
///
/// Confidence thresholds:
/// - [_autoApplyThreshold] (0.8): apply without confirmation.
/// - [_discardThreshold] (0.4): discard ambiguous candidates below this level.
class SettingsIntentResolver {
  SettingsIntentResolver(this._registry);

  final SettingsMetadataRegistry _registry;

  static const double _autoApplyThreshold = 0.8;
  static const double _discardThreshold = 0.4;

  static const int _smallSteps = 1;
  static const int _mediumSteps = 2;
  static const int _largeSteps = 3;

  /// The registry used for metadata lookups.
  SettingsMetadataRegistry get registry => _registry;

  /// Resolves [payload] into a [SettingsResolution] given [currentValues].
  ///
  /// [currentValues] maps each settings key to its current string value,
  /// matching the format produced by [SettingsSnapshotService.getCurrentValue].
  SettingsResolution resolve(
    SettingsChangePayload payload, {
    required Map<String, String> currentValues,
  }) {
    return switch (payload) {
      SettingsChangePayloadAbsolute(
        :final key,
        :final value,
        :final confidence,
      ) =>
        _resolveAbsolute(
          key: key,
          newValue: value,
          confidence: confidence,
          currentValues: currentValues,
        ),
      SettingsChangePayloadRelative(
        :final key,
        :final direction,
        :final magnitude,
        :final confidence,
      ) =>
        _resolveRelative(
          key: key,
          direction: direction,
          magnitude: magnitude,
          confidence: confidence,
          currentValues: currentValues,
        ),
      SettingsChangePayloadAmbiguous(:final candidates) => _resolveAmbiguous(
        candidates: candidates,
        currentValues: currentValues,
      ),
    };
  }

  SettingsResolution _resolveAbsolute({
    required String key,
    required String newValue,
    required double confidence,
    required Map<String, String> currentValues,
  }) {
    final metadata = _registry.findByKey(key);
    if (metadata == null) {
      return const SettingsResolution.notFound();
    }
    final oldValue = currentValues[key] ?? '';
    return _applyThreshold(
      key: key,
      oldValue: oldValue,
      newValue: newValue,
      confidence: confidence,
    );
  }

  SettingsResolution _resolveRelative({
    required String key,
    required ChangeDirection direction,
    required ChangeMagnitude magnitude,
    required double confidence,
    required Map<String, String> currentValues,
  }) {
    final metadata = _registry.findByKey(key);
    if (metadata == null) {
      return const SettingsResolution.notFound();
    }

    final constraints = metadata.constraints;
    if (constraints is! RangeConstraints) {
      return const SettingsResolution.notFound();
    }

    final oldValue = currentValues[key] ?? '';
    final current = double.tryParse(oldValue);
    if (current == null) {
      return const SettingsResolution.notFound();
    }

    final stepCount = _stepsForMagnitude(magnitude);
    final delta = constraints.step * stepCount;
    final raw = switch (direction) {
      ChangeDirection.increase => current + delta,
      ChangeDirection.decrease => current - delta,
    };

    final clamped = math.max(constraints.min, math.min(constraints.max, raw));
    final newValue = _formatValue(metadata.type, clamped, constraints.step);

    return _applyThreshold(
      key: key,
      oldValue: oldValue,
      newValue: newValue,
      confidence: confidence,
    );
  }

  SettingsResolution _resolveAmbiguous({
    required List<SettingsCandidate> candidates,
    required Map<String, String> currentValues,
  }) {
    // Keep only candidates meeting the discard threshold (_discardThreshold <= confidence).
    final kept = candidates
        .where((c) => _discardThreshold <= c.confidence)
        .toList();

    if (kept.isEmpty) {
      return const SettingsResolution.notFound();
    }

    if (kept.length == 1) {
      final only = kept.first;
      final metadata = _registry.findByKey(only.key);
      if (metadata == null) {
        return const SettingsResolution.notFound();
      }
      final oldValue = currentValues[only.key] ?? '';
      return _applyThreshold(
        key: only.key,
        oldValue: oldValue,
        newValue: only.value,
        confidence: only.confidence,
      );
    }

    // 2+ candidates: present them to the user for disambiguation.
    final resolutionCandidates = kept.map((c) {
      final metadata = _registry.findByKey(c.key);
      final oldValue = currentValues[c.key] ?? '';
      return SettingsResolutionCandidate(
        key: c.key,
        displayNameKey: metadata?.displayNameKey ?? c.key,
        oldValue: oldValue,
        newValue: c.value,
        confidence: c.confidence,
      );
    }).toList();

    return SettingsResolution.disambiguate(candidates: resolutionCandidates);
  }

  SettingsResolution _applyThreshold({
    required String key,
    required String oldValue,
    required String newValue,
    required double confidence,
  }) {
    // Confidence at or above the auto-apply threshold needs no confirmation.
    if (_autoApplyThreshold <= confidence) {
      return SettingsResolution.autoApply(
        key: key,
        oldValue: oldValue,
        newValue: newValue,
      );
    }
    return SettingsResolution.confirm(
      key: key,
      oldValue: oldValue,
      newValue: newValue,
      confidence: confidence,
    );
  }

  int _stepsForMagnitude(ChangeMagnitude magnitude) {
    return switch (magnitude) {
      ChangeMagnitude.small => _smallSteps,
      ChangeMagnitude.medium => _mediumSteps,
      ChangeMagnitude.large => _largeSteps,
    };
  }

  /// Formats a clamped value as a string appropriate for the setting type.
  ///
  /// For [SettingType.intValue], rounds to the nearest integer. For
  /// floating-point types, rounds to the decimal precision implied by [step]
  /// to avoid floating-point drift.
  String _formatValue(SettingType type, double value, double step) {
    if (type == SettingType.intValue) {
      return value.round().toString();
    }
    final stepStr = step.toString();
    final dotIndex = stepStr.indexOf('.');
    final decimalPlaces = (dotIndex == -1) ? 0 : stepStr.length - dotIndex - 1;
    return value.toStringAsFixed(decimalPlaces);
  }
}
