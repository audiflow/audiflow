/// Resolves where a continuous seek bar drag lands when the finger lifts
/// off, filtering the shift the contact point makes as the finger rolls off
/// the glass.
///
/// The drag's positions are fed in as they change, with pointer event
/// timestamps. On release, if the position had held still (within
/// [stillness]) for at least [minDwell] and then moved only inside the last
/// [lateMoveWindow] before lift-off, by no more than [maxRoll], the settled
/// position wins. Anything else (a drag still moving at lift-off, a flick)
/// commits the final position.
///
/// Values are track fractions (0.0 to 1.0) after any fine-scrub scaling, so
/// the rule judges what the user saw on the bar, not raw finger travel.
/// Distances are compared in track points ([trackWidth] per whole track).
class SeekReleaseTracker {
  SeekReleaseTracker({
    required double startValue,
    required Duration startTime,
    required this.trackWidth,
    this.minDwell = defaultMinDwell,
    this.lateMoveWindow = defaultLateMoveWindow,
    this.stillness = defaultStillness,
    this.maxRoll = defaultMaxRoll,
  }) : _history = [(value: startValue, at: startTime)];

  // Initial values, to be tuned on a device.
  //
  // 150 ms matches the stepped speed slider's dwell: long enough that the
  // user deliberately stopped to read the position, short enough that a
  // brief pause before lifting still counts.
  static const Duration defaultMinDwell = Duration(milliseconds: 150);

  // The roll happens in the last one to three frames before the up event
  // (about 16-50 ms). 60 ms covers that with some margin while staying
  // shorter than the speed slider's 80 ms: a continuous bar has no step
  // hysteresis, so a narrower window undoes fewer intentional last nudges.
  static const Duration defaultLateMoveWindow = Duration(milliseconds: 60);

  // A resting finger jitters by about a point; 2 pt of track tolerates that
  // without letting a slow deliberate drag pass as "still".
  static const double defaultStillness = 2.0;

  // Lift-off roll shifts the contact point by a few points. A larger late
  // move is a flick or a deliberate final push and is kept.
  static const double defaultMaxRoll = 12.0;

  /// Width of the track in points, used to convert fractions to points.
  final double trackWidth;

  /// How long the position must have held still before the late move.
  final Duration minDwell;

  /// How close to lift-off a move must be to count as roll.
  final Duration lateMoveWindow;

  /// Largest drift, in track points, that still counts as holding still.
  final double stillness;

  /// Largest late move, in track points, that counts as roll.
  final double maxRoll;

  final List<({double value, Duration at})> _history;

  /// The most recent drag position.
  double get value => _history.last.value;

  /// Records that the drag moved to [value] at [at].
  void update(double value, Duration at) {
    _history.add((value: value, at: at));
  }

  /// The position to commit when the finger lifts off at [liftOff].
  double resolveRelease(Duration liftOff) {
    final settleEnd = liftOff - lateMoveWindow;
    final settledIndex = _history.lastIndexWhere((s) => s.at <= settleEnd);
    // No late move, or the drag began inside the late window.
    if (settledIndex == -1 || settledIndex == _history.length - 1) {
      return value;
    }
    final settled = _history[settledIndex].value;
    if (maxRoll < _points(value - settled)) return value;
    if (!_heldStill(settledIndex, settleEnd - minDwell)) return value;
    return settled;
  }

  // Walks back from the settled sample until one at or before [dwellStart];
  // every position held in between must stay within [stillness]. A drag that
  // began after [dwellStart] never dwelt long enough.
  bool _heldStill(int settledIndex, Duration dwellStart) {
    final settled = _history[settledIndex].value;
    for (var i = settledIndex; 0 <= i; i--) {
      final sample = _history[i];
      if (stillness < _points(sample.value - settled)) return false;
      if (sample.at <= dwellStart) return true;
    }
    return false;
  }

  double _points(double fractionDelta) => fractionDelta.abs() * trackWidth;
}
