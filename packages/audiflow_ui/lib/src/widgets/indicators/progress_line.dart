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

  /// Whether [fraction] represents an item whose playback has started,
  /// the only state in which the spec shows the line. Unplayed items
  /// (0, null) show none; finished items (1 or more) show it full.
  static bool isStarted(double? fraction) {
    if (fraction == null || fraction.isNaN) return false;
    return 0 < fraction;
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
/// playback has started (full once finished), without changing the
/// child's size.
///
/// Rounded parents clip the line themselves (e.g. via the card's shape).
/// Full-width list rows pass [inset] so the line lines up with the row
/// text instead of running edge to edge; an inset line gets rounded ends.
class BottomEdgeProgress extends StatelessWidget {
  const BottomEdgeProgress({
    super.key,
    required this.fraction,
    required this.child,
    this.fillColor,
    this.inset = 0,
  });

  final double? fraction;
  final Widget child;
  final Color? fillColor;

  /// Horizontal margin on both sides of the line.
  final double inset;

  @override
  Widget build(BuildContext context) {
    final value = fraction;
    // The Stack stays in the tree whether or not the line shows, so
    // crossing a progress boundary does not rebuild the child and reset
    // its state.
    return Stack(
      children: [
        child,
        if (ProgressLine.isStarted(value))
          PositionedDirectional(
            start: inset,
            end: inset,
            bottom: 0,
            child: _line(value!),
          ),
      ],
    );
  }

  Widget _line(double value) {
    final line = ProgressLine(fraction: value, fillColor: fillColor);
    if (inset == 0) return line;
    return ClipRRect(
      borderRadius: BorderRadius.circular(ProgressLine.thickness / 2),
      child: line,
    );
  }
}
