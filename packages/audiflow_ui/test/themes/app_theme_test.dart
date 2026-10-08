import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la < lb ? lb : la;
  final darker = la < lb ? la : lb;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('AppColors palette', () {
    test('light tokens match the redesign spec', () {
      const colors = AppColors.light;
      check(colors.bg).equals(const Color(0xFFF7F5F2));
      check(colors.surface).equals(const Color(0xFFFFFFFF));
      check(colors.surfaceSunken).equals(const Color(0xFFECE8E2));
      check(colors.surfaceMuted).equals(const Color(0xFFF3F0EB));
      check(colors.ink).equals(const Color(0xFF1A1714));
      check(colors.inkSecondary).equals(const Color(0xFF5E5952));
      check(colors.inkTertiary).equals(const Color(0xFF6E6962));
      check(colors.inkQuaternary).equals(const Color(0xFFA39D95));
      check(colors.hairline).equals(const Color(0xFFF0ECE6));
      check(colors.outline).equals(const Color(0xFFDED9D2));
      check(colors.progressTrack).equals(const Color(0xFFE9E5DF));
      check(colors.accent).equals(const Color(0xFFB5531C));
      check(colors.onAccent).equals(const Color(0xFFFFFFFF));
      check(colors.brand).equals(const Color(0xFFE8823A));
    });

    test('dark tokens match the redesign spec', () {
      const colors = AppColors.dark;
      check(colors.bg).equals(const Color(0xFF141210));
      check(colors.surface).equals(const Color(0xFF1F1C19));
      check(colors.surfaceSunken).equals(const Color(0xFF2A2622));
      check(colors.surfaceMuted).equals(const Color(0xFF2A2622));
      check(colors.ink).equals(const Color(0xFFF3EFEA));
      check(colors.inkSecondary).equals(const Color(0xFFB8B1A8));
      check(colors.inkTertiary).equals(const Color(0xFF9A938A));
      check(colors.inkQuaternary).equals(const Color(0xFF6F6961));
      check(colors.hairline).equals(const Color(0xFF2A2622));
      check(colors.outline).equals(const Color(0xFF3A342E));
      check(colors.progressTrack).equals(const Color(0xFF3A342E));
      check(colors.accent).equals(const Color(0xFFF0965A));
      check(colors.onAccent).equals(const Color(0xFF1A1714));
      check(colors.brand).equals(const Color(0xFFE8823A));
    });

    for (final (name, colors, alpha) in [
      ('light', AppColors.light, 0.10),
      ('dark', AppColors.dark, 0.16),
    ]) {
      test('$name accentTint is accent composited over surface', () {
        final expected = Color.alphaBlend(
          colors.accent.withValues(alpha: alpha),
          colors.surface,
        );
        // Stored as 8-bit hex, so allow one step of rounding per channel.
        const tolerance = 1 / 255 + 1e-9;
        check(
          (colors.accentTint.r - expected.r).abs(),
        ).isLessOrEqual(tolerance);
        check(
          (colors.accentTint.g - expected.g).abs(),
        ).isLessOrEqual(tolerance);
        check(
          (colors.accentTint.b - expected.b).abs(),
        ).isLessOrEqual(tolerance);
        check(colors.accentTint.a).equals(1);
      });
    }

    for (final (name, colors) in [
      ('light', AppColors.light),
      ('dark', AppColors.dark),
    ]) {
      test('$name accent text reaches 4.5:1 on surface', () {
        check(
          _contrastRatio(colors.accent, colors.surface),
        ).isGreaterOrEqual(4.5);
        check(
          _contrastRatio(colors.onAccent, colors.accent),
        ).isGreaterOrEqual(4.5);
      });

      test('$name inkTertiary reaches 4.5:1 on surface and bg', () {
        check(
          _contrastRatio(colors.inkTertiary, colors.surface),
        ).isGreaterOrEqual(4.5);
        check(
          _contrastRatio(colors.inkTertiary, colors.bg),
        ).isGreaterOrEqual(4.5);
      });
    }
  });

  group('AppColorScheme mapping', () {
    for (final (name, scheme, colors) in [
      ('light', AppColorScheme.light(), AppColors.light),
      ('dark', AppColorScheme.dark(), AppColors.dark),
    ]) {
      test('$name maps ColorScheme roles to tokens', () {
        check(scheme.primary).equals(colors.accent);
        check(scheme.onPrimary).equals(colors.onAccent);
        check(scheme.primaryContainer).equals(colors.accentTint);
        check(scheme.onPrimaryContainer).equals(colors.accent);
        check(scheme.surface).equals(colors.bg);
        check(scheme.surfaceContainerLowest).equals(colors.surface);
        check(scheme.surfaceContainer).equals(colors.surfaceMuted);
        check(scheme.surfaceContainerHigh).equals(colors.surfaceSunken);
        check(scheme.onSurface).equals(colors.ink);
        check(scheme.onSurfaceVariant).equals(colors.inkSecondary);
        check(scheme.outline).equals(colors.outline);
        check(scheme.outlineVariant).equals(colors.hairline);
      });
    }

    test('brightness matches the mode', () {
      check(AppColorScheme.light().brightness).equals(Brightness.light);
      check(AppColorScheme.dark().brightness).equals(Brightness.dark);
    });
  });

  group('AppTheme', () {
    for (final (name, theme, colors) in [
      ('light', AppTheme.light(), AppColors.light),
      ('dark', AppTheme.dark(), AppColors.dark),
    ]) {
      test('$name registers the AppColors extension', () {
        check(theme.extension<AppColors>()).equals(colors);
      });

      test('$name uses bg as the scaffold background', () {
        check(theme.scaffoldBackgroundColor).equals(colors.bg);
      });

      test('$name sheets use surface with 28 top radius', () {
        final sheet = theme.bottomSheetTheme;
        check(sheet.backgroundColor).equals(colors.surface);
        check(sheet.shape)
            .isA<RoundedRectangleBorder>()
            .has((shape) => shape.borderRadius, 'borderRadius')
            .equals(AppBorders.sheet);
      });

      test('$name snackbar action text reaches 4.5:1 on its fill', () {
        final snackBar = theme.snackBarTheme;
        check(
          snackBar.actionTextColor,
        ).isNotNull().not((it) => it.equals(colors.brand));
        check(
          _contrastRatio(snackBar.actionTextColor!, snackBar.backgroundColor!),
        ).isGreaterOrEqual(4.5);
      });
    }

    testWidgets('AppColors.of resolves from the ambient theme', (tester) async {
      late AppColors resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (context) {
              resolved = AppColors.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      check(resolved).equals(AppColors.dark);
    });

    testWidgets('AppColors.of falls back by brightness without extension', (
      tester,
    ) async {
      late AppColors resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Builder(
            builder: (context) {
              resolved = AppColors.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      check(resolved).equals(AppColors.dark);
    });
  });

  group('AppColors.lerp', () {
    test('returns endpoints at t = 0 and t = 1', () {
      check(AppColors.light.lerp(AppColors.dark, 0)).equals(AppColors.light);
      check(AppColors.light.lerp(AppColors.dark, 1)).equals(AppColors.dark);
    });

    test('returns itself when other is not AppColors', () {
      check(AppColors.light.lerp(null, 0.5)).equals(AppColors.light);
    });
  });

  group('AppTextStyles', () {
    test('roles match the redesign spec', () {
      check(AppTextStyles.displayTitle.fontSize).equals(28);
      check(AppTextStyles.displayTitle.fontWeight).equals(FontWeight.w700);
      check(AppTextStyles.heroTitle.fontSize).equals(22);
      check(AppTextStyles.heroTitleLong.fontSize).equals(19);
      check(AppTextStyles.sectionTitle.fontSize).equals(17);
      check(AppTextStyles.sectionTitle.fontWeight).equals(FontWeight.w600);
      check(AppTextStyles.rowTitle.fontSize).equals(15);
      check(AppTextStyles.rowTitle.fontWeight).equals(FontWeight.w600);
      check(AppTextStyles.body.fontSize).equals(15);
      check(AppTextStyles.meta.fontSize).equals(13);
      check(AppTextStyles.caption.fontSize).equals(12);
      check(AppTextStyles.overline.fontWeight).equals(FontWeight.w600);
    });

    test('tracking is expressed in logical pixels from em', () {
      check(AppTextStyles.displayTitle.letterSpacing).equals(28 * -0.01);
      check(AppTextStyles.overline.letterSpacing).equals(12 * 0.06);
    });

    test('tabular applies tabular figures', () {
      final style = AppTextStyles.tabular(AppTextStyles.meta);
      check(
        style.fontFeatures,
      ).isNotNull().contains(const FontFeature.tabularFigures());
      check(style.fontSize).equals(13);
    });
  });
}
