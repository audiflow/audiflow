import 'dart:math' as math;

import 'package:audiflow_core/audiflow_core.dart';

/// Utilities for responsive grid layouts.
class ResponsiveGrid {
  ResponsiveGrid._();

  static const int _minColumns = 2;

  /// Calculates the number of grid columns based on available width.
  ///
  /// With [spacing], the gaps between columns are counted too, so every
  /// column is at least [itemWidth] wide.
  static int columnCount({
    required double availableWidth,
    double itemWidth = LayoutConstants.podcastGridItemWidth,
    double spacing = 0,
  }) {
    assert(0 < itemWidth, 'itemWidth must be positive');
    final columns = (availableWidth + spacing) ~/ (itemWidth + spacing);
    return math.max(_minColumns, columns);
  }
}
