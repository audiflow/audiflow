import 'package:flutter/material.dart';

import '../../themes/app_colors.dart';

/// A thin playback progress line (redesign section 3.1).
///
/// Track is `hairline`, fill is `accent` unless [fillColor] overrides it
/// (the mini player passes `brand`). Usually placed by
/// [BottomEdgeProgress] rather than directly.
class ProgressLine extends StatelessWidget {
  const ProgressLine({
    super.key,
    required this.fraction,
    this.fillColor,
    this.trackColor,
  });

  /// Line thickness from the spec.
  static const double thickness = 3;

  @visibleForTesting
  static const Key trackKey = ValueKey('progressLineTrack');

  @visibleForTesting
  static const Key fillKey = ValueKey('progressLineFill');

  /// Progress in `[0, 1]`. Out-of-range values are clamped; NaN is empty.
  final double fraction;

  final Color? fillColor;
  final Color? trackColor;

  /// Whether [fraction] represents a partially played item, the only
  /// state in which the spec shows the line. Unplayed (0, null) and
  /// finished (1 or more) items show no line.
  static bool isPartial(double? fraction) {
    if (fraction == null || fraction.isNaN) return false;
    return 0 < fraction && fraction < 1;
  }

  double get _clamped => fraction.isNaN ? 0 : fraction.clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return ExcludeSemantics(
      child: SizedBox(
        height: thickness,
        width: double.infinity,
        child: ColoredBox(
          key: trackKey,
          color: trackColor ?? colors.hairline,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: _clamped,
              heightFactor: 1,
              child: ColoredBox(
                key: fillKey,
                color: fillColor ?? colors.accent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Overlays a [ProgressLine] on the bottom edge of [child] while
/// [fraction] is partial, without changing the child's size.
///
/// Rounded parents clip the line themselves (e.g. via the card's shape).
class BottomEdgeProgress extends StatelessWidget {
  const BottomEdgeProgress({
    super.key,
    required this.fraction,
    required this.child,
    this.fillColor,
  });

  final double? fraction;
  final Widget child;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final value = fraction;
    // The Stack stays in the tree whether or not the line shows, so
    // crossing a progress boundary does not rebuild the child and reset
    // its state.
    return Stack(
      children: [
        child,
        if (ProgressLine.isPartial(value))
          PositionedDirectional(
            start: 0,
            end: 0,
            bottom: 0,
            child: ProgressLine(fraction: value!, fillColor: fillColor),
          ),
      ],
    );
  }
}
