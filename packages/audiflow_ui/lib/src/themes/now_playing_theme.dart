import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_theme.dart';

/// Theme for the full-screen player on its artwork-derived [ground]
/// (redesign section 2.2): every control is white, secondary labels are
/// white at 70%, and filled controls (play/pause) take the ground color
/// for their glyph.
///
/// Built on the dark theme so shared widgets (seek bar, chips, sheets
/// opened from the player's own context) read the right roles without
/// player-specific parameters.
ThemeData nowPlayingTheme(Color ground) {
  const white = NowPlayingColors.foreground;
  const secondary = NowPlayingColors.labelSecondary;
  final base = AppTheme.dark();
  final colors = AppColors.dark.copyWith(
    bg: ground,
    ink: white,
    inkSecondary: secondary,
    inkTertiary: secondary,
    accent: white,
    onAccent: ground,
    hairline: NowPlayingColors.trackInactive,
    progressTrack: NowPlayingColors.trackInactive,
  );
  return base.copyWith(
    scaffoldBackgroundColor: ground,
    canvasColor: ground,
    colorScheme: base.colorScheme.copyWith(
      primary: white,
      onPrimary: ground,
      surface: ground,
      onSurface: white,
      onSurfaceVariant: secondary,
      inverseSurface: white,
      onInverseSurface: ground,
    ),
    iconTheme: const IconThemeData(color: white),
    textTheme: base.textTheme.apply(bodyColor: white, displayColor: white),
    extensions: [colors],
  );
}
