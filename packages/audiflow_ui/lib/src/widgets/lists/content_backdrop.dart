import 'package:flutter/material.dart';

import '../../themes/app_colors.dart';

/// Backdrop for long content lists: a surface a touch lighter than `bg`
/// with very faint, uneven light and shade, like frosted glass or still
/// water, so the list reads as its own layer instead of blending into
/// the screen chrome.
///
/// Fills its parent and stays fixed while content scrolls over it. Only
/// the part below [top] shows the texture; above it the plain `bg`
/// shows, so headers sitting above the list keep the screen color.
class ContentBackdrop extends StatelessWidget {
  const ContentBackdrop({super.key, this.top = 0});

  /// Distance from the top of the backdrop where the list surface starts.
  final double top;

  @visibleForTesting
  static const Key textureKey = ValueKey('contentBackdropTexture');

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return ColoredBox(
      color: colors.bg,
      child: ClipRect(
        clipper: _BelowClipper(top),
        // The texture never changes while scrolling; only the clip moves.
        child: RepaintBoundary(
          child: CustomPaint(
            key: textureKey,
            painter: _MottlePainter(
              base: baseColorFor(colors),
              light: colors.surface,
              shade: colors.surfaceSunken,
              dark: colors.bg == AppColors.dark.bg,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }

  /// The list surface color: `bg` lifted most of the way toward
  /// `surface` (whiter in light mode, slightly raised in dark mode).
  static Color baseColorFor(AppColors colors) =>
      Color.lerp(colors.bg, colors.surface, 0.55)!;
}

class _BelowClipper extends CustomClipper<Rect> {
  const _BelowClipper(this.top);

  final double top;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, top.clamp(0.0, size.height), size.width, size.height);

  @override
  bool shouldReclip(_BelowClipper oldClipper) => oldClipper.top != top;
}

/// Soft, large blobs of light and shade over the base color. Positions
/// are fixed fractions of the size so the pattern is stable per screen.
class _MottlePainter extends CustomPainter {
  const _MottlePainter({
    required this.base,
    required this.light,
    required this.shade,
    required this.dark,
  });

  final Color base;
  final Color light;
  final Color shade;
  final bool dark;

  // (x, y, radius as a fraction of the shorter side, is light)
  static const _blobs = <(double, double, double, bool)>[
    (0.12, 0.08, 0.95, true),
    (0.92, 0.30, 0.80, false),
    (0.30, 0.48, 0.90, true),
    (0.05, 0.70, 0.75, false),
    (0.85, 0.78, 1.00, true),
    (0.40, 1.02, 0.70, false),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = base);
    final unit = size.shortestSide;
    for (final (x, y, r, isLight) in _blobs) {
      final center = Offset(size.width * x, size.height * y);
      final radius = unit * r;
      final color = isLight ? light : shade;
      final alpha = isLight ? (dark ? 0.035 : 0.75) : (dark ? 0.18 : 0.30);
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: alpha),
            color.withValues(alpha: alpha * 0.4),
            color.withValues(alpha: 0),
          ],
          stops: const [0, 0.45, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_MottlePainter oldDelegate) =>
      oldDelegate.base != base ||
      oldDelegate.light != light ||
      oldDelegate.shade != shade ||
      oldDelegate.dark != dark;
}
