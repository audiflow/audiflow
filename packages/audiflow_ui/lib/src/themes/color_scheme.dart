import 'package:flutter/material.dart';

/// Application color schemes.
///
/// Seeded from Material's deep purple to keep the original Audiflow
/// brand feel. Component-level theming in [AppTheme] consumes the
/// resulting [ColorScheme] so light and dark variants stay consistent.
class AppColorScheme {
  AppColorScheme._();

  /// Brand seed color used to derive light and dark schemes.
  static const Color brandSeed = Colors.deepPurple;

  /// Light color scheme derived from [brandSeed].
  static ColorScheme light() {
    return ColorScheme.fromSeed(seedColor: brandSeed);
  }

  /// Dark color scheme derived from [brandSeed].
  static ColorScheme dark() {
    return ColorScheme.fromSeed(
      seedColor: brandSeed,
      brightness: Brightness.dark,
    );
  }
}
