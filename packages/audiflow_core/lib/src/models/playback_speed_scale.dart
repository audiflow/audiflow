/// Discrete playback speed grid shared by every speed control.
///
/// The grid is 0.5 to 2.0 in 0.1 increments, then 2.2 to 3.0 in 0.2
/// increments. Steps are listed as literals rather than computed so
/// that values compare exactly (no floating-point accumulation).
abstract final class PlaybackSpeedScale {
  /// All selectable speeds in ascending order.
  static const List<double> steps = [
    0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, //
    1.6, 1.7, 1.8, 1.9, 2.0, 2.2, 2.4, 2.6, 2.8, 3.0,
  ];

  /// Normal (unmodified) playback speed.
  static const double normal = 1.0;

  /// Lowest selectable speed.
  static double get min => steps.first;

  /// Highest selectable speed.
  static double get max => steps.last;

  /// Index of the last step.
  static int get maxIndex => steps.length - 1;

  /// Speed at [index], clamped to the grid bounds.
  static double speedForIndex(int index) => steps[index.clamp(0, maxIndex)];

  /// Index of the step nearest to [speed].
  ///
  /// Ties round half up (e.g. legacy 1.25 becomes 1.3). Values outside
  /// the grid clamp to the first or last step.
  static int indexForSpeed(double speed) {
    var bestIndex = 0;
    var bestDistance = double.infinity;
    for (var i = 0; i < steps.length; i++) {
      final distance = (steps[i] - speed).abs();
      // Epsilon makes exact midpoints count as ties despite binary
      // representation error, so the later (higher) step wins.
      if (distance <= bestDistance + 1e-9) {
        bestDistance = distance;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  /// Rounds [speed] to the nearest step on the grid.
  static double snap(double speed) => steps[indexForSpeed(speed)];

  /// Short display label such as `1.3x`.
  static String label(double speed) => '${speed.toStringAsFixed(1)}x';
}

/// Rules for the "recently used speeds" list shown as quick chips.
///
/// The stored list is newest-first, never contains [PlaybackSpeedScale.normal]
/// (which always has its own chip), and holds at most [capacity] entries.
abstract final class RecentPlaybackSpeeds {
  /// Maximum number of remembered non-normal speeds.
  static const int capacity = 2;

  /// Returns [recent] with [speed] recorded as the newest entry.
  ///
  /// [speed] is snapped to the grid first. Recording normal speed leaves
  /// the list unchanged; an existing entry moves to the front instead of
  /// being duplicated; the oldest entry is evicted beyond [capacity].
  static List<double> record(List<double> recent, double speed) {
    final snapped = PlaybackSpeedScale.snap(speed);
    if (snapped == PlaybackSpeedScale.normal) return normalize(recent);
    final rest = normalize(recent).where((s) => s != snapped);
    return [snapped, ...rest].take(capacity).toList();
  }

  /// Sanitizes a stored list: snaps to the grid, drops normal speed and
  /// duplicates, keeps newest-first order, and caps at [capacity].
  static List<double> normalize(List<double> recent) {
    final result = <double>[];
    for (final speed in recent) {
      final snapped = PlaybackSpeedScale.snap(speed);
      if (snapped == PlaybackSpeedScale.normal) continue;
      if (result.contains(snapped)) continue;
      result.add(snapped);
      if (result.length == capacity) break;
    }
    return result;
  }

  /// Chip speeds for display: normal plus [recent], in ascending order.
  static List<double> chipSpeeds(List<double> recent) {
    return [PlaybackSpeedScale.normal, ...normalize(recent)]..sort();
  }
}
