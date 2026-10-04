import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'scrub_speed.dart';

/// A contiguous stretch of the seek bar track, in fractions of the whole
/// track (0.0 to 1.0).
///
/// The track is drawn as a list of segments so that callers can later pass
/// chapter boundaries (with gaps between them) without changing the
/// [PlayerSeekBar] API.
@immutable
class SeekBarSegment {
  const SeekBarSegment({required this.start, required this.end})
    : assert(0.0 <= start && start <= end && end <= 1.0);

  /// Fraction of the track where this segment begins.
  final double start;

  /// Fraction of the track where this segment ends.
  final double end;

  /// A single segment spanning the whole track.
  static const List<SeekBarSegment> single = [
    SeekBarSegment(start: 0.0, end: 1.0),
  ];

  @override
  bool operator ==(Object other) =>
      other is SeekBarSegment && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);
}

/// Thumbless seek bar for the full player.
///
/// Draws a thick rounded track with the played part highlighted and two
/// time labels underneath. Scrubbing is delta-based: a horizontal drag moves
/// the value by the finger's travel from wherever it currently is, instead of
/// jumping to the touch point, and a tap never seeks.
///
/// Once a drag has started, moving the finger vertically away from the track
/// slows it down for fine adjustment (see [scrubSpeedForDistance]); the
/// current speed is shown between the time labels from [scrubSpeedLabels].
///
/// The widget is controlled like [Slider]: it reports value changes through
/// the callbacks and renders whatever [value] the parent passes back.
class PlayerSeekBar extends StatefulWidget {
  const PlayerSeekBar({
    super.key,
    required this.value,
    required this.leadingLabel,
    required this.trailingLabel,
    this.segments = SeekBarSegment.single,
    this.semanticValueFormatter,
    this.scrubSpeedLabels = const {},
    this.onChangeStart,
    this.onChanged,
    this.onChangeEnd,
    this.onTrailingLabelTap,
  });

  /// Track thickness at rest.
  static const double idleTrackHeight = 6.0;

  /// Track thickness while the user is scrubbing.
  static const double draggingTrackHeight = 10.0;

  /// Fraction of the track a screen-reader increase/decrease action moves.
  static const double semanticStep = 0.05;

  /// Key of the draggable track area, for tests and integration code.
  static const Key trackKey = ValueKey('player-seek-bar-track');

  /// Played fraction of the track (0.0 to 1.0).
  final double value;

  /// Label under the start of the track (typically elapsed time).
  final String leadingLabel;

  /// Label under the end of the track (remaining or total time).
  final String trailingLabel;

  /// Stretches of the track to draw. Defaults to one full-width segment.
  final List<SeekBarSegment> segments;

  /// Formats a track fraction for screen readers, e.g. "01:00 of 10:00".
  ///
  /// Also used for the values announced after an increase/decrease action;
  /// those actions are only offered when a formatter is given.
  final String Function(double value)? semanticValueFormatter;

  /// Text shown between the time labels while scrubbing at a reduced speed.
  ///
  /// Nothing is shown at [ScrubSpeed.full] or for speeds without an entry.
  final Map<ScrubSpeed, String> scrubSpeedLabels;

  /// Called with the value at the moment a drag begins.
  final ValueChanged<double>? onChangeStart;

  /// Called with the new value on every drag update.
  final ValueChanged<double>? onChanged;

  /// Called with the final value when the drag ends or is cancelled.
  final ValueChanged<double>? onChangeEnd;

  /// Called when the trailing label is tapped.
  final VoidCallback? onTrailingLabelTap;

  @override
  State<PlayerSeekBar> createState() => _PlayerSeekBarState();
}

class _PlayerSeekBarState extends State<PlayerSeekBar> {
  static const double _touchAreaHeight = 32.0;
  static const Duration _thicknessAnimation = Duration(milliseconds: 150);

  bool _isDragging = false;
  double _dragValue = 0.0;
  double _trackWidth = 0.0;
  ScrubSpeed _scrubSpeed = ScrubSpeed.full;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final value = (_isDragging ? _dragValue : widget.value).clamp(0.0, 1.0);

    return _buildSemantics(
      value: value,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_buildTrack(value, primary), _buildLabels(theme, primary)],
      ),
    );
  }

  Widget _buildSemantics({required double value, required Widget child}) {
    final format = widget.semanticValueFormatter;
    if (format == null) return Semantics(slider: true, child: child);
    const step = PlayerSeekBar.semanticStep;
    return Semantics(
      slider: true,
      value: format(value),
      increasedValue: format((value + step).clamp(0.0, 1.0)),
      decreasedValue: format((value - step).clamp(0.0, 1.0)),
      onIncrease: () => _adjustBy(step),
      onDecrease: () => _adjustBy(-step),
      child: child,
    );
  }

  Widget _buildTrack(double value, Color primary) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _trackWidth = constraints.maxWidth;
        return GestureDetector(
          key: PlayerSeekBar.trackKey,
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: _handleDragUpdate,
          onHorizontalDragEnd: (_) => _handleDragFinish(),
          onHorizontalDragCancel: _handleDragFinish,
          child: SizedBox(
            height: _touchAreaHeight,
            width: double.infinity,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: _trackHeight),
              duration: _thicknessAnimation,
              curve: Curves.easeOut,
              builder: (context, height, _) => CustomPaint(
                painter: PlayerSeekBarPainter(
                  value: value,
                  trackHeight: height,
                  segments: widget.segments,
                  activeColor: primary,
                  inactiveColor: primary.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double get _trackHeight => _isDragging
      ? PlayerSeekBar.draggingTrackHeight
      : PlayerSeekBar.idleTrackHeight;

  Widget _buildLabels(ThemeData theme, Color primary) {
    final style = theme.textTheme.bodySmall?.copyWith(
      // Fixed-width digits keep the labels from jittering every second.
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    // The slider node already announces the position; only the trailing
    // label stays reachable, as a button, so its toggle remains accessible.
    return Row(
      children: [
        ExcludeSemantics(child: Text(widget.leadingLabel, style: style)),
        Expanded(child: _buildScrubSpeedLabel(style?.copyWith(color: primary))),
        Semantics(
          button: widget.onTrailingLabelTap != null,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTrailingLabelTap,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
              child: Text(widget.trailingLabel, style: style),
            ),
          ),
        ),
      ],
    );
  }

  // Purely visual feedback for sighted scrubbing; screen readers adjust via
  // the slider actions, which have no speed bands.
  Widget _buildScrubSpeedLabel(TextStyle? style) {
    final label = _isDragging ? widget.scrubSpeedLabels[_scrubSpeed] : null;
    if (label == null || _scrubSpeed == ScrubSpeed.full) {
      return const SizedBox.shrink();
    }
    return ExcludeSemantics(
      child: Text(
        label,
        style: style,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // Screen-reader adjustments are a one-shot start/change/end sequence so
  // the parent sees the same callbacks as for a drag.
  void _adjustBy(double delta) {
    if (_isDragging) return;
    final start = widget.value.clamp(0.0, 1.0);
    final next = (start + delta).clamp(0.0, 1.0);
    widget.onChangeStart?.call(start);
    widget.onChanged?.call(next);
    widget.onChangeEnd?.call(next);
  }

  // The drag only "starts" on the first real movement. A drag recognizer
  // that is alone in the gesture arena also wins plain taps (firing start and
  // end with no movement), and a tap must never count as a seek.
  void _beginDrag() {
    HapticFeedback.lightImpact();
    final start = widget.value.clamp(0.0, 1.0);
    setState(() {
      _isDragging = true;
      _dragValue = start;
    });
    widget.onChangeStart?.call(start);
  }

  // The horizontal drag recognizer only wins the arena on horizontal
  // movement, so a drag that starts vertically still reaches the enclosing
  // sheet's swipe-to-dismiss. Once won, it keeps reporting the finger's full
  // position (even outside the bar), which drives the speed bands.
  void _handleDragUpdate(DragUpdateDetails details) {
    if (_trackWidth <= 0) return;
    final delta = details.primaryDelta ?? details.delta.dx;
    if (!_isDragging && delta == 0) return;
    if (!_isDragging) _beginDrag();
    _updateScrubSpeed(details.localPosition.dy - _touchAreaHeight / 2);
    _moveDragValueBy(delta * _scrubSpeed.factor / _trackWidth);
  }

  void _updateScrubSpeed(double distanceFromTrack) {
    final speed = scrubSpeedForDistance(distanceFromTrack);
    if (speed == _scrubSpeed) return;
    HapticFeedback.lightImpact();
    setState(() => _scrubSpeed = speed);
  }

  // Single place where a drag changes the position, so lift-off handling can
  // hook in without touching the gesture plumbing.
  void _moveDragValueBy(double fraction) {
    if (fraction == 0) return;
    final next = (_dragValue + fraction).clamp(0.0, 1.0);
    if (next == _dragValue) return;
    setState(() => _dragValue = next);
    widget.onChanged?.call(next);
  }

  void _handleDragFinish() {
    if (!_isDragging) return;
    final end = _dragValue;
    setState(() {
      _isDragging = false;
      _scrubSpeed = ScrubSpeed.full;
    });
    widget.onChangeEnd?.call(end);
  }
}

/// Paints the [PlayerSeekBar] track: each segment as a rounded bar, filled
/// with [activeColor] up to [value] and [inactiveColor] after it.
@visibleForTesting
class PlayerSeekBarPainter extends CustomPainter {
  const PlayerSeekBarPainter({
    required this.value,
    required this.trackHeight,
    required this.segments,
    required this.activeColor,
    required this.inactiveColor,
  });

  final double value;
  final double trackHeight;
  final List<SeekBarSegment> segments;
  final Color activeColor;
  final Color inactiveColor;

  @override
  void paint(Canvas canvas, Size size) {
    final top = (size.height - trackHeight) / 2;
    final radius = Radius.circular(trackHeight / 2);
    final activePaint = Paint()..color = activeColor;
    final inactivePaint = Paint()..color = inactiveColor;
    final playedX = size.width * value;

    for (final segment in segments) {
      final rect = Rect.fromLTWH(
        size.width * segment.start,
        top,
        size.width * (segment.end - segment.start),
        trackHeight,
      );
      final shape = RRect.fromRectAndRadius(rect, radius);
      canvas.drawRRect(shape, inactivePaint);
      if (playedX <= rect.left) continue;
      canvas
        ..save()
        ..clipRRect(shape)
        ..drawRect(
          Rect.fromLTRB(rect.left, top, playedX, top + trackHeight),
          activePaint,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(PlayerSeekBarPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.trackHeight != trackHeight ||
      oldDelegate.activeColor != activeColor ||
      oldDelegate.inactiveColor != inactiveColor ||
      !listEquals(oldDelegate.segments, segments);
}
