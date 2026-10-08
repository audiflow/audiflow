import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Application color schemes.
///
/// Built from explicit [AppColors] tokens (redesign section 2.1) instead
/// of a seed so the palette does not drift with Material's seed
/// algorithm. Roles the spec does not map are assigned the nearest
/// neutral or accent token so no widget falls back to a stray hue.
class AppColorScheme {
  AppColorScheme._();

  /// Light color scheme.
  static ColorScheme light() {
    return _fromTokens(
      AppColors.light,
      brightness: Brightness.light,
      inversePrimary: AppColors.dark.accent,
      surfaceContainerHighest: const Color(0xFFE4DFD8),
      error: const Color(0xFFB3261E),
      onError: const Color(0xFFFFFFFF),
      errorContainer: const Color(0xFFF9DEDC),
      onErrorContainer: const Color(0xFF410E0B),
    );
  }

  /// Dark color scheme.
  static ColorScheme dark() {
    return _fromTokens(
      AppColors.dark,
      brightness: Brightness.dark,
      inversePrimary: AppColors.light.accent,
      surfaceContainerHighest: const Color(0xFF332E29),
      error: const Color(0xFFF2B8B5),
      onError: const Color(0xFF601410),
      errorContainer: const Color(0xFF8C1D18),
      onErrorContainer: const Color(0xFFF9DEDC),
    );
  }

  static ColorScheme _fromTokens(
    AppColors colors, {
    required Brightness brightness,
    required Color inversePrimary,
    required Color surfaceContainerHighest,
    required Color error,
    required Color onError,
    required Color errorContainer,
    required Color onErrorContainer,
  }) {
    return ColorScheme(
      brightness: brightness,
      primary: colors.accent,
      onPrimary: colors.onAccent,
      primaryContainer: colors.accentTint,
      onPrimaryContainer: colors.accent,
      // One-accent rule: secondary and tertiary reuse the accent family
      // so selected chips and segments read as the same state color.
      secondary: colors.accent,
      onSecondary: colors.onAccent,
      secondaryContainer: colors.accentTint,
      onSecondaryContainer: colors.accent,
      tertiary: colors.accent,
      onTertiary: colors.onAccent,
      tertiaryContainer: colors.accentTint,
      onTertiaryContainer: colors.accent,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: colors.bg,
      onSurface: colors.ink,
      onSurfaceVariant: colors.inkSecondary,
      surfaceDim: colors.bg,
      surfaceBright: colors.surface,
      surfaceContainerLowest: colors.surface,
      surfaceContainerLow: colors.surface,
      surfaceContainer: colors.surfaceMuted,
      surfaceContainerHigh: colors.surfaceSunken,
      surfaceContainerHighest: surfaceContainerHighest,
      outline: colors.outline,
      outlineVariant: colors.hairline,
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      inverseSurface: colors.ink,
      onInverseSurface: colors.bg,
      inversePrimary: inversePrimary,
      // Disables M3 elevation tinting; surfaces stay neutral.
      surfaceTint: Colors.transparent,
    );
  }
}
