import 'dart:math' as math;

/// Where the episode detail play pill sits in its row.
///
/// The pill aims for the center of the row, so it lines up with the title
/// and description above it. Buttons at the row's trailing edge take
/// precedence: when centering would run into them, the pill slides toward
/// the start just enough to clear them, so narrower rows drift gradually
/// instead of jumping between centered and start-aligned.
class PlayPillPlacement {
  const PlayPillPlacement({required this.start, required this.width});

  /// Resolves the pill for a row of [rowWidth], capping it at
  /// [maxPillWidth] and keeping [trailingReserve] free at the end (the
  /// trailing buttons plus the gap before them).
  factory PlayPillPlacement.resolve({
    required double rowWidth,
    required double maxPillWidth,
    required double trailingReserve,
  }) {
    final available = math.max(0.0, rowWidth - trailingReserve);
    final width = math.min(maxPillWidth, available);
    final centered = (rowWidth - width) / 2;
    final start = math.min(centered, available - width);
    return PlayPillPlacement(start: math.max(0.0, start), width: width);
  }

  /// Offset from the row's start edge.
  final double start;

  final double width;
}
