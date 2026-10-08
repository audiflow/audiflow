import 'dart:ui' show ImageFilter;

import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Square station artwork (redesign 4.1): its podcasts' artwork as
/// stacked cards, or empty slots with an add button.
///
/// Artwork is never cropped. One podcast fills the square; two or three
/// are smaller cards overlapping from top-left to bottom-right over a blur
/// of the first. Callers pass at most [maxCards] URLs.
class StationArtwork extends StatelessWidget {
  const StationArtwork({required this.artworkUrls, this.onAdd, super.key});

  /// Cards shown at most; a station with more shows its first ones.
  static const int maxCards = 3;

  /// Opacity of the `surface` wash over the blurred backdrop.
  static const double _backdropWash = 0.6;

  @visibleForTesting
  static const Key cardKey = ValueKey('station-artwork-card');

  @visibleForTesting
  static const Key addButtonKey = ValueKey('station-artwork-add');

  /// Artwork of the station's first podcasts, in station order. A null
  /// entry is a podcast without artwork.
  final List<String?> artworkUrls;

  /// Opens podcast selection from the empty state. Null hides the button.
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        final urls = artworkUrls.take(maxCards).toList();
        if (urls.isEmpty) return _EmptySlots(size: size, onAdd: onAdd);
        if (urls.length == 1) return _artwork(context, urls.first, size);
        return _stack(context, urls, size);
      },
    );
  }

  Widget _stack(BuildContext context, List<String?> urls, double size) {
    // Cards and steps keep the stack centered with a 10% margin.
    final card = size * (urls.length == 2 ? 0.6 : 0.5);
    final step = (size * 0.8 - card) / (urls.length - 1);
    final margin = size * 0.1;
    return Stack(
      children: [
        Positioned.fill(child: _blurredBackdrop(context, urls.first, size)),
        for (var index = 0; index < urls.length; index++)
          Positioned(
            left: margin + step * index,
            top: margin + step * index,
            child: _card(context, urls[index], card),
          ),
      ],
    );
  }

  Widget _card(BuildContext context, String? url, double size) {
    final radius = BorderRadius.circular(size * 0.14);
    return Container(
      key: cardKey,
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppShadows.floating,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: _artwork(context, url, size),
      ),
    );
  }

  Widget _blurredBackdrop(BuildContext context, String? url, double size) {
    final colors = AppColors.of(context);
    if (url == null) return ColoredBox(color: colors.surfaceSunken);
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          // Clamp keeps the edges opaque instead of fading to transparent.
          imageFilter: ImageFilter.blur(
            sigmaX: size * 0.08,
            sigmaY: size * 0.08,
            tileMode: TileMode.clamp,
          ),
          child: _artwork(context, url, size),
        ),
        // The backdrop is the first card's own artwork; a wash keeps only
        // its tint so that card still stands apart from it.
        ColoredBox(color: colors.surface.withValues(alpha: _backdropWash)),
      ],
    );
  }

  Widget _artwork(BuildContext context, String? url, double size) {
    final fallback = _ArtworkFallback(size: size);
    if (url == null) return fallback;
    return ArtworkImage(
      url: url,
      width: size,
      height: size,
      loading: ColoredBox(color: AppColors.of(context).surfaceSunken),
      placeholder: fallback,
    );
  }
}

class _ArtworkFallback extends StatelessWidget {
  const _ArtworkFallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      width: size,
      height: size,
      color: colors.surfaceSunken,
      alignment: Alignment.center,
      child: Icon(
        Icons.podcasts,
        size: size * 0.4,
        color: colors.inkQuaternary,
      ),
    );
  }
}

/// Four dashed slots marking where podcasts will go, with an accent add
/// button so a station left empty leads straight to choosing podcasts.
class _EmptySlots extends StatelessWidget {
  const _EmptySlots({required this.size, required this.onAdd});

  final double size;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final add = onAdd;
    return ColoredBox(
      color: colors.surfaceSunken,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DashedSlotsPainter(color: colors.outline),
            ),
          ),
          if (add != null) _AddButton(size: size * 0.34, onPressed: add),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.size, required this.onPressed});

  final double size;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final label = AppLocalizations.of(context).stationSelectPodcasts;
    // At least the minimum touch target even on a small tile.
    final target = size < Spacing.minTouchTarget
        ? Spacing.minTouchTarget
        : size;
    return SizedBox.square(
      dimension: target,
      child: Center(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: AppShadows.floating,
          ),
          child: Material(
            key: StationArtwork.addButtonKey,
            color: colors.accent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: Semantics(
                button: true,
                label: label,
                child: SizedBox.square(
                  dimension: size,
                  child: Icon(
                    Icons.add_rounded,
                    size: size * 0.55,
                    color: colors.onAccent,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A 2x2 grid of rounded dashed outlines.
class _DashedSlotsPainter extends CustomPainter {
  const _DashedSlotsPainter({required this.color});

  final Color color;

  static const double _dash = 5;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = size.width * 0.1;
    final spacing = size.width * 0.06;
    final cell = (size.width - inset * 2 - spacing) / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (var row = 0; row < 2; row++) {
      for (var column = 0; column < 2; column++) {
        final rect = Rect.fromLTWH(
          inset + (cell + spacing) * column,
          inset + (cell + spacing) * row,
          cell,
          cell,
        );
        final outline = Path()
          ..addRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(cell * 0.2)),
          );
        canvas.drawPath(_dashed(outline), paint);
      }
    }
  }

  Path _dashed(Path source) {
    final dashed = Path();
    for (final metric in source.computeMetrics()) {
      for (var start = 0.0; start < metric.length; start += _dash + _gap) {
        dashed.addPath(metric.extractPath(start, start + _dash), Offset.zero);
      }
    }
    return dashed;
  }

  @override
  bool shouldRepaint(_DashedSlotsPainter oldDelegate) =>
      oldDelegate.color != color;
}
