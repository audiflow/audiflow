import 'package:flutter/material.dart';

/// Application color schemes.
///
/// Palette: black + white neutrals with the Audiflow icon color
/// (`#DB8648`, sampled from `assets/icons/prod/app-icon.png`) as the
/// single accent. No purple, no blue, no teal.
class AppColorScheme {
  AppColorScheme._();

  /// Audiflow brand orange — sampled from the production app icon background.
  static const Color brandPrimary = Color(0xFFDB8648);

  /// Lightened brand orange for accents on dark surfaces.
  static const Color brandPrimaryDark = Color(0xFFE89968);

  /// Light color scheme: white surfaces, black text, brand orange accent.
  static ColorScheme light() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: brandPrimary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFFFE3D1),
      onPrimaryContainer: Color(0xFF3A1E0A),
      secondary: brandPrimary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFFE3D1),
      onSecondaryContainer: Color(0xFF5A2C0E),
      tertiary: Colors.black,
      onTertiary: Colors.white,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Color(0xFFF7F7F7),
      surfaceContainer: Color(0xFFF2F2F2),
      surfaceContainerHigh: Color(0xFFEDEDED),
      surfaceContainerHighest: Color(0xFFE6E6E6),
      onSurfaceVariant: Color(0xFF424242),
      outline: Color(0xFFBDBDBD),
      outlineVariant: Color(0xFFE0E0E0),
      inverseSurface: Colors.black,
      onInverseSurface: Colors.white,
      inversePrimary: brandPrimaryDark,
      shadow: Colors.black,
      scrim: Colors.black,
    );
  }

  /// Dark color scheme: black surfaces, white text, brand orange accent.
  static ColorScheme dark() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: brandPrimaryDark,
      onPrimary: Colors.black,
      primaryContainer: Color(0xFF6E3A14),
      onPrimaryContainer: Color(0xFFFFE3D1),
      secondary: brandPrimaryDark,
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFF5A2C0E),
      onSecondaryContainer: Color(0xFFFFE3D1),
      tertiary: Colors.white,
      onTertiary: Colors.black,
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      surface: Colors.black,
      onSurface: Colors.white,
      surfaceContainerLowest: Colors.black,
      surfaceContainerLow: Color(0xFF0F0F0F),
      surfaceContainer: Color(0xFF161616),
      surfaceContainerHigh: Color(0xFF1F1F1F),
      surfaceContainerHighest: Color(0xFF2A2A2A),
      onSurfaceVariant: Color(0xFFBDBDBD),
      outline: Color(0xFF5C5C5C),
      outlineVariant: Color(0xFF2E2E2E),
      inverseSurface: Colors.white,
      onInverseSurface: Colors.black,
      inversePrimary: brandPrimary,
      shadow: Colors.black,
      scrim: Colors.black,
    );
  }
}
