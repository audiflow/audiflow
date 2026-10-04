/// Resolves a drag on a stepped slider into step indices, filtering the
/// two usual sources of unintended steps.
///
/// - Boundary wobble: a finger resting near a step boundary jitters by
///   a point or two. A new step is only taken once the finger is
///   [hysteresis] of a step past the boundary.
/// - Lift-off roll: the contact point shifts as the finger leaves the
///   glass. If the last change was a single step made within
///   [lateChangeWindow] of lift-off, after the finger had rested on the
///   previous step for at least [minDwell], the previous step wins.
///
/// Positions are in step units (0 is the first step). Times are pointer
/// event timestamps, so the rules are independent of frame timing.
class StepDragTracker {
  StepDragTracker({
    required int startIndex,
    required Duration startTime,
    this.hysteresis = 0.3,
    this.lateChangeWindow = const Duration(milliseconds: 80),
    this.minDwell = const Duration(milliseconds: 150),
  }) : _history = [(index: startIndex, at: startTime)];

  /// Fraction of a step the finger must pass a boundary by.
  final double hysteresis;

  /// How close to lift-off a change must be to count as roll.
  final Duration lateChangeWindow;

  /// How long the finger must have rested on the previous step.
  final Duration minDwell;

  final List<({int index, Duration at})> _history;

  /// The step currently selected.
  int get index => _history.last.index;

  /// Feeds the finger [position] seen at [at].
  ///
  /// Returns true when the selected step changed.
  bool update(double position, Duration at) {
    final current = index;
    if ((position - current).abs() < 0.5 + hysteresis) return false;
    final next = position.round();
    if (next == current) return false;
    _history.add((index: next, at: at));
    return true;
  }

  /// The step to commit when the finger lifts off at [at].
  int resolveRelease(Duration at) {
    if (_history.length < 2) return index;
    final last = _history.last;
    final previous = _history[_history.length - 2];
    final isLate = at - last.at <= lateChangeWindow;
    final hadSettled = minDwell <= last.at - previous.at;
    final isSingleStep = (last.index - previous.index).abs() == 1;
    return isLate && hadSettled && isSingleStep ? previous.index : last.index;
  }
}
