import 'package:flutter/material.dart';

/// Application color schemes
class AppColorScheme {
  AppColorScheme._();

  /// Light color scheme
  static ColorScheme light() {
    return ColorScheme.light(
      primary: Colors.blue.shade700,
      secondary: Colors.teal.shade600,
      tertiary: Colors.purple.shade600,
      error: Colors.red.shade700,
      surface: Colors.white,
      surfaceContainerHighest: Colors.grey.shade100,
    );
  }

  /// Dark color scheme
  static ColorScheme dark() {
    return ColorScheme.dark(
      primary: Colors.blue.shade300,
      secondary: Colors.teal.shade300,
      tertiary: Colors.purple.shade300,
      error: Colors.red.shade300,
      surface: Colors.grey.shade900,
      surfaceContainerHighest: Colors.grey.shade800,
    );
  }
}
