import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
/// The widget is controlled like [Slider]: it reports value changes through
/// the callbacks and renders whatever [value] the parent passes back.
class PlayerSeekBar extends StatefulWidget {
  const PlayerSeekBar({
    super.key,
    required this.value,
    required this.leadingLabel,
    required this.trailingLabel,
    this.segments = SeekBarSegment.single,
    this.semanticValue,
    this.onChangeStart,
    this.onChanged,
    this.onChangeEnd,
    this.onTrailingLabelTap,
  });

  /// Track thickness at rest.
  static const double idleTrackHeight = 6.0;

  /// Track thickness while the user is scrubbing.
  static const double draggingTrackHeight = 10.0;

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

  /// Value announced by screen readers, e.g. "01:00 of 10:00".
  final String? semanticValue;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final value = (_isDragging ? _dragValue : widget.value).clamp(0.0, 1.0);

    return Semantics(
      slider: true,
      value: widget.semanticValue,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_buildTrack(value, primary), _buildLabels(theme)],
      ),
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

  Widget _buildLabels(ThemeData theme) {
    final style = theme.textTheme.bodySmall?.copyWith(
      // Fixed-width digits keep the labels from jittering every second.
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.leadingLabel, style: style),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTrailingLabelTap,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
              child: Text(widget.trailingLabel, style: style),
            ),
          ),
        ],
      ),
    );
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

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? details.delta.dx;
    if (delta == 0 || _trackWidth <= 0) return;
    if (!_isDragging) _beginDrag();
    final next = (_dragValue + delta / _trackWidth).clamp(0.0, 1.0);
    if (next == _dragValue) return;
    setState(() => _dragValue = next);
    widget.onChanged?.call(next);
  }

  void _handleDragFinish() {
    if (!_isDragging) return;
    final end = _dragValue;
    setState(() => _isDragging = false);
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
