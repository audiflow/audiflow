import 'package:flutter/material.dart';

/// Semantic color tokens from `docs/design/redesign.md` section 2.1.
///
/// Material's [ColorScheme] has no slot for several roles the redesign
/// relies on (tertiary and quaternary ink, the brand mark color, the
/// raised content surface distinct from the screen background), so the
/// full palette is carried as a [ThemeExtension]. Read it with
/// [AppColors.of].
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.surface,
    required this.surfaceSunken,
    required this.surfaceMuted,
    required this.ink,
    required this.inkSecondary,
    required this.inkTertiary,
    required this.inkQuaternary,
    required this.hairline,
    required this.outline,
    required this.progressTrack,
    required this.accent,
    required this.onAccent,
    required this.accentTint,
    required this.brand,
  });

  /// Screen background.
  final Color bg;

  /// Grouped lists, cards, sheets, floating buttons.
  final Color surface;

  /// Segmented-control track, search field, filter field.
  final Color surfaceSunken;

  /// Neutral pill background (play pill, menu tiles).
  final Color surfaceMuted;

  /// Primary text and icons.
  final Color ink;

  /// Secondary text (author, metadata).
  final Color inkSecondary;

  /// Captions, inactive tab labels, counts. Minimum for inactive text.
  final Color inkTertiary;

  /// Chevrons, episode numbers. Non-text glyphs only.
  final Color inkQuaternary;

  /// Row separators inside a surface; bottom-edge progress track.
  final Color hairline;

  /// Borders on chips and dropdown buttons.
  final Color outline;

  /// Track behind sliders and standalone progress bars.
  final Color progressTrack;

  /// Primary buttons, selected tab, links, progress fill.
  final Color accent;

  /// Text and icons on an [accent] fill.
  final Color onAccent;

  /// Tonal background (subscribed pill, icon tiles, playing pill).
  ///
  /// Stored opaque (accent composited over [surface]) so widgets that
  /// assume an opaque fill, such as Material containers, render the same
  /// tone regardless of what lies beneath them.
  final Color accentTint;

  /// Bright brand orange for non-text marks only (mini player progress
  /// line). Fails text contrast; never use behind or as text.
  final Color brand;

  static const Color _brandOrange = Color(0xFFE8823A);

  static const Color _lightAccent = Color(0xFFB5531C);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _darkAccent = Color(0xFFF0965A);
  static const Color _darkSurface = Color(0xFF1F1C19);

  /// Light-mode palette.
  static const AppColors light = AppColors(
    bg: Color(0xFFF7F5F2),
    surface: _lightSurface,
    surfaceSunken: Color(0xFFECE8E2),
    surfaceMuted: Color(0xFFF3F0EB),
    ink: Color(0xFF1A1714),
    inkSecondary: Color(0xFF5E5952),
    inkTertiary: Color(0xFF6E6962),
    inkQuaternary: Color(0xFFA39D95),
    hairline: Color(0xFFF0ECE6),
    outline: Color(0xFFDED9D2),
    progressTrack: Color(0xFFE9E5DF),
    accent: _lightAccent,
    onAccent: Color(0xFFFFFFFF),
    // _lightAccent at 10% over _lightSurface.
    accentTint: Color(0xFFF8EEE8),
    brand: _brandOrange,
  );

  /// Dark-mode palette.
  static const AppColors dark = AppColors(
    bg: Color(0xFF141210),
    surface: _darkSurface,
    surfaceSunken: Color(0xFF2A2622),
    surfaceMuted: Color(0xFF2A2622),
    ink: Color(0xFFF3EFEA),
    inkSecondary: Color(0xFFB8B1A8),
    inkTertiary: Color(0xFF9A938A),
    inkQuaternary: Color(0xFF6F6961),
    hairline: Color(0xFF2A2622),
    outline: Color(0xFF3A342E),
    progressTrack: Color(0xFF3A342E),
    accent: _darkAccent,
    onAccent: Color(0xFF1A1714),
    // _darkAccent at 16% over _darkSurface.
    accentTint: Color(0xFF403023),
    brand: _brandOrange,
  );

  /// Palette for [brightness].
  static AppColors forBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }

  /// Resolves the palette from the ambient theme, falling back to the
  /// palette matching the theme brightness when the extension is absent
  /// (e.g. widget tests that pump a bare [ThemeData]).
  static AppColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AppColors>() ?? forBrightness(theme.brightness);
  }

  @override
  AppColors copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceSunken,
    Color? surfaceMuted,
    Color? ink,
    Color? inkSecondary,
    Color? inkTertiary,
    Color? inkQuaternary,
    Color? hairline,
    Color? outline,
    Color? progressTrack,
    Color? accent,
    Color? onAccent,
    Color? accentTint,
    Color? brand,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      ink: ink ?? this.ink,
      inkSecondary: inkSecondary ?? this.inkSecondary,
      inkTertiary: inkTertiary ?? this.inkTertiary,
      inkQuaternary: inkQuaternary ?? this.inkQuaternary,
      hairline: hairline ?? this.hairline,
      outline: outline ?? this.outline,
      progressTrack: progressTrack ?? this.progressTrack,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentTint: accentTint ?? this.accentTint,
      brand: brand ?? this.brand,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    if (t == 0) return this;
    if (t == 1) return other;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      bg: mix(bg, other.bg),
      surface: mix(surface, other.surface),
      surfaceSunken: mix(surfaceSunken, other.surfaceSunken),
      surfaceMuted: mix(surfaceMuted, other.surfaceMuted),
      ink: mix(ink, other.ink),
      inkSecondary: mix(inkSecondary, other.inkSecondary),
      inkTertiary: mix(inkTertiary, other.inkTertiary),
      inkQuaternary: mix(inkQuaternary, other.inkQuaternary),
      hairline: mix(hairline, other.hairline),
      outline: mix(outline, other.outline),
      progressTrack: mix(progressTrack, other.progressTrack),
      accent: mix(accent, other.accent),
      onAccent: mix(onAccent, other.onAccent),
      accentTint: mix(accentTint, other.accentTint),
      brand: mix(brand, other.brand),
    );
  }
}

/// Colors for the full-screen Now Playing player (redesign section 2.2).
///
/// The player ground is derived from the episode artwork, not the app
/// palette, so all controls on it are white regardless of brightness.
class NowPlayingColors {
  NowPlayingColors._();

  /// Ground used when no artwork color can be derived.
  static const Color fallbackBackground = Color(0xFF22304F);

  /// Controls, scrubber fill, and thumb.
  static const Color foreground = Color(0xFFFFFFFF);

  /// Unplayed scrubber track: white at 22%.
  static const Color trackInactive = Color(0x38FFFFFF);

  /// Secondary labels: white at 70%.
  static const Color labelSecondary = Color(0xB3FFFFFF);
}
