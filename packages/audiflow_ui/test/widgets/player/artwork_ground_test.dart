import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('groundFromArtworkColor', () {
    test('keeps the hue but darkens and mutes it', () {
      const vivid = Color(0xFFE8823A);
      final ground = HSLColor.fromColor(groundFromArtworkColor(vivid));
      final source = HSLColor.fromColor(vivid);
      check(ground.hue).isCloseTo(source.hue, 2);
      check(ground.lightness).isCloseTo(0.24, 0.01);
      check(ground.saturation).isLessOrEqual(0.45);
    });

    test('white controls stay readable on a light artwork', () {
      final ground = groundFromArtworkColor(const Color(0xFFF5F0E0));
      final contrast =
          (1.05) / (ground.computeLuminance() + 0.05); // white is 1.0
      check(contrast).isGreaterOrEqual(4.5);
    });
  });

  group('averageArtworkColor', () {
    test('a colorful subject outweighs a flat background', () {
      // Three white pixels and one saturated blue one.
      final rgba = [
        ...[255, 255, 255, 255],
        ...[255, 255, 255, 255],
        ...[255, 255, 255, 255],
        ...[20, 40, 220, 255],
      ];
      final average = averageArtworkColor(rgba);
      check(average.b).isGreaterThan(average.r);
    });

    test('transparent pixels fall back to the default ground', () {
      check(
        averageArtworkColor([0, 0, 0, 0]),
      ).equals(NowPlayingColors.fallbackBackground);
    });
  });

  testWidgets('shows the fallback ground without artwork', (tester) async {
    Color? seen;
    await tester.pumpWidget(
      ArtworkGround(
        url: null,
        builder: (_, ground) {
          seen = ground;
          return const SizedBox();
        },
      ),
    );
    check(seen).equals(NowPlayingColors.fallbackBackground);
  });

  test('now playing theme makes controls white on the ground', () {
    const ground = Color(0xFF2A3344);
    final theme = nowPlayingTheme(ground);
    check(theme.colorScheme.primary).equals(NowPlayingColors.foreground);
    check(theme.colorScheme.onPrimary).equals(ground);
    check(theme.scaffoldBackgroundColor).equals(ground);
    check(
      theme.extension<AppColors>()!.ink,
    ).equals(NowPlayingColors.foreground);
  });
}
