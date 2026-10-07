import 'package:flutter/material.dart';

/// Application text styles (redesign section 2.3).
///
/// Styles carry size, weight, line height, and tracking only; color comes
/// from the ambient theme so each style works in both brightness modes.
/// Font family is left to the platform default (SF Pro / Hiragino Sans on
/// iOS, Roboto / Noto Sans CJK on Android), which supplies the geometric
/// grotesque plus matching Gothic pairing without bundling font assets.
class AppTextStyles {
  AppTextStyles._();

  /// Tab titles (Library, Search, Queue, Settings).
  static const TextStyle displayTitle = TextStyle(
    fontSize: 28,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: 28 * -0.01,
  );

  /// Podcast and series hero titles.
  static const TextStyle heroTitle = TextStyle(
    fontSize: 22,
    height: 1.35,
    fontWeight: FontWeight.w700,
  );

  /// [heroTitle] variant for long titles.
  static const TextStyle heroTitleLong = TextStyle(
    fontSize: 19,
    height: 1.35,
    fontWeight: FontWeight.w700,
  );

  /// Section headings inside a tab.
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 17,
    height: 1.35,
    fontWeight: FontWeight.w600,
  );

  /// Episode and series row titles.
  static const TextStyle rowTitle = TextStyle(
    fontSize: 15,
    height: 1.4,
    fontWeight: FontWeight.w600,
  );

  /// Settings rows, menu items.
  static const TextStyle body = TextStyle(
    fontSize: 15,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );

  /// Durations, counts, descriptions.
  static const TextStyle meta = TextStyle(
    fontSize: 13,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );

  /// Dates, status labels.
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );

  /// Year headers, settings group headers.
  static const TextStyle overline = TextStyle(
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w600,
    letterSpacing: 12 * 0.06,
  );

  /// Button and pill labels.
  static const TextStyle label = TextStyle(
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );

  /// Returns [style] with tabular figures, for numbers that change in
  /// place (durations, counts, times) so digits do not shift width.
  static TextStyle tabular(TextStyle style) {
    return style.copyWith(
      fontFeatures: [
        ...?style.fontFeatures,
        const FontFeature.tabularFigures(),
      ],
    );
  }

  /// Material text theme mapped onto the redesign roles so stock widgets
  /// (ListTile, AppBar, dialogs) pick up the new scale.
  static final TextTheme textTheme = TextTheme(
    displayLarge: displayTitle.copyWith(fontSize: 57, letterSpacing: -1.14),
    displayMedium: displayTitle.copyWith(fontSize: 45, letterSpacing: -0.9),
    displaySmall: displayTitle,
    headlineLarge: displayTitle.copyWith(fontSize: 30, letterSpacing: -0.6),
    headlineMedium: heroTitle.copyWith(fontSize: 26),
    headlineSmall: heroTitle,
    titleLarge: sectionTitle,
    titleMedium: rowTitle,
    titleSmall: rowTitle.copyWith(fontSize: 14),
    bodyLarge: body,
    bodyMedium: meta,
    bodySmall: caption,
    labelLarge: label,
    labelMedium: caption.copyWith(fontWeight: FontWeight.w600),
    labelSmall: overline,
  );
}
