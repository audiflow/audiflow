import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';

/// Shared state-to-style mapper for voice trigger widgets.
///
/// Both [VoiceTriggerButton] (app bar) and `_VoiceCenterButton` (nav bar)
/// use this to avoid duplicating the voice state styling logic.
class VoiceTriggerStyle {
  VoiceTriggerStyle._();

  /// Whether the voice state should prevent tap interactions.
  static bool isTapDisabled(VoiceRecognitionState state) {
    return switch (state) {
      VoiceIdle() => false,
      VoiceListening() => false,
      VoiceSuccess() => false,
      VoiceError() => false,
      VoiceProcessing() => true,
      VoiceExecuting() => true,
      VoiceSettingsAutoApplied() => true,
      VoiceSettingsDisambiguation() => true,
      VoiceSettingsLowConfidence() => true,
    };
  }

  /// Whether the button should pulse (processing/executing states).
  static bool isPulsing(VoiceRecognitionState state) {
    return state is VoiceProcessing || state is VoiceExecuting;
  }

  /// Icon fill value (1 = filled, 0 = outline).
  static double iconFill(VoiceRecognitionState state) {
    return switch (state) {
      VoiceListening() => 1,
      VoiceIdle() => 0,
      VoiceProcessing() => 0,
      VoiceExecuting() => 0,
      VoiceSuccess() => 0,
      VoiceError() => 0,
      VoiceSettingsAutoApplied() => 0,
      VoiceSettingsDisambiguation() => 0,
      VoiceSettingsLowConfidence() => 0,
    };
  }
}

/// Style set for the compact app bar trigger button (36x36 visual).
class AppBarTriggerStyle {
  AppBarTriggerStyle._();

  static Color backgroundColor(ColorScheme cs, VoiceRecognitionState state) {
    return switch (state) {
      VoiceIdle() => cs.primary.withValues(alpha: 0.1),
      VoiceListening() => cs.primary.withValues(alpha: 0.25),
      VoiceProcessing() => cs.primary.withValues(alpha: 0.15),
      VoiceExecuting() => cs.primary.withValues(alpha: 0.15),
      VoiceSuccess() => cs.tertiary.withValues(alpha: 0.15),
      VoiceError() => cs.error.withValues(alpha: 0.15),
      VoiceSettingsAutoApplied() => cs.secondary.withValues(alpha: 0.15),
      VoiceSettingsDisambiguation() => cs.secondary.withValues(alpha: 0.15),
      VoiceSettingsLowConfidence() => cs.secondary.withValues(alpha: 0.15),
    };
  }

  static Color iconColor(ColorScheme cs, VoiceRecognitionState state) {
    return switch (state) {
      VoiceIdle() => cs.primary,
      // Accent amber per visual spec.
      VoiceListening() => const Color(0xFFFFC107),
      VoiceProcessing() => cs.primary,
      VoiceExecuting() => cs.primary,
      VoiceSuccess() => cs.tertiary,
      VoiceError() => cs.error,
      VoiceSettingsAutoApplied() => cs.secondary,
      VoiceSettingsDisambiguation() => cs.secondary,
      VoiceSettingsLowConfidence() => cs.secondary,
    };
  }

  static List<BoxShadow> boxShadows(
    ColorScheme cs,
    VoiceRecognitionState state,
  ) {
    return switch (state) {
      VoiceListening() => [
        BoxShadow(color: cs.primary.withValues(alpha: 0.4), blurRadius: 12),
      ],
      _ => const [],
    };
  }
}

/// Style set for the center-docked nav bar button (48x48 circular).
class CenterButtonStyle {
  CenterButtonStyle._();

  static Color backgroundColor(ColorScheme cs, VoiceRecognitionState state) {
    return switch (state) {
      VoiceIdle() => cs.primary,
      VoiceListening() => cs.primary,
      VoiceProcessing() => cs.primary.withValues(alpha: 0.7),
      VoiceExecuting() => cs.primary.withValues(alpha: 0.7),
      VoiceSuccess() => cs.tertiary,
      VoiceError() => cs.error,
      VoiceSettingsAutoApplied() => cs.secondary,
      VoiceSettingsDisambiguation() => cs.secondary,
      VoiceSettingsLowConfidence() => cs.secondary,
    };
  }

  static Color iconColor(ColorScheme cs, VoiceRecognitionState state) {
    return switch (state) {
      VoiceIdle() => cs.onPrimary,
      VoiceListening() => const Color(0xFFFFC107),
      VoiceProcessing() => cs.onPrimary,
      VoiceExecuting() => cs.onPrimary,
      VoiceSuccess() => cs.onTertiary,
      VoiceError() => cs.onError,
      VoiceSettingsAutoApplied() => cs.onSecondary,
      VoiceSettingsDisambiguation() => cs.onSecondary,
      VoiceSettingsLowConfidence() => cs.onSecondary,
    };
  }

  static List<BoxShadow> boxShadows(
    ColorScheme cs,
    VoiceRecognitionState state,
  ) {
    return switch (state) {
      VoiceListening() => [
        BoxShadow(
          color: cs.primary.withValues(alpha: 0.5),
          blurRadius: 16,
          spreadRadius: 2,
        ),
      ],
      _ => [
        BoxShadow(
          color: cs.shadow.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    };
  }
}
