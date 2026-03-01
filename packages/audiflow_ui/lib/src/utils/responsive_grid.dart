import 'dart:math' as math;

import 'package:audiflow_core/audiflow_core.dart';

/// Utilities for responsive grid layouts.
class ResponsiveGrid {
  ResponsiveGrid._();

  static const int _minColumns = 2;

  /// Calculates the number of grid columns based on available width.
  static int columnCount({
    required double availableWidth,
    double itemWidth = LayoutConstants.podcastGridItemWidth,
  }) {
    assert(0 < itemWidth, 'itemWidth must be positive');
    final columns = availableWidth ~/ itemWidth;
    return math.max(_minColumns, columns);
  }
}
