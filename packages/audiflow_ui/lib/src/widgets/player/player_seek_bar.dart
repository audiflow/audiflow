import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show kTouchSlop;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'scrub_speed.dart';
import 'seek_release_tracker.dart';

/// A contiguous stretch of the seek bar track, in fractions of the whole
/// track (0.0 to 1.0).
///
/// The track is drawn as a list of segments, typically one per chapter;
/// [PlayerSeekBar] leaves a small gap wherever one segment meets the next.
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
/// While dragging, an optional [tooltipBuilder] shows a bubble above the
/// track that follows the scrub position and stays inside the bar's width.
///
/// Once a drag has started, moving the finger vertically away from the track
/// slows it down for fine adjustment (see [scrubSpeedForDistance]); the
/// current speed is shown between the time labels from [scrubSpeedLabels].
///
/// On release, a small move made just as the finger lifts off after holding
/// still is discarded, and the position the user settled on is committed
/// (see [SeekReleaseTracker]).
///
/// The widget is controlled like [Slider]: it reports value changes through
/// the callbacks and renders whatever [value] the parent passes back.
class PlayerSeekBar extends StatefulWidget {
  const PlayerSeekBar({
    super.key,
    required this.value,
    required this.leadingLabel,
    required this.trailingLabel,
    this.trailingLabelIcon,
    this.trailingLabelSemanticsLabel,
    this.segments = SeekBarSegment.single,
    this.tooltipBuilder,
    this.semanticValueFormatter,
    this.adjustable = true,
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

  /// Width of the gap left between adjacent segments.
  static const double segmentGap = 2.0;

  /// Space between the tooltip and the top of the touch area.
  static const double tooltipSpacing = 4.0;

  /// Fraction of the track a screen-reader increase/decrease action moves.
  static const double semanticStep = 0.05;

  /// Key of the draggable track area, for tests and integration code.
  static const Key trackKey = ValueKey('player-seek-bar-track');

  /// Key of the scrub tooltip bubble, present only while dragging.
  static const Key tooltipKey = ValueKey('player-seek-bar-tooltip');

  /// Played fraction of the track (0.0 to 1.0).
  final double value;

  /// Label under the start of the track (typically elapsed time).
  final String leadingLabel;

  /// Label under the end of the track (remaining or total time).
  final String trailingLabel;

  /// Glyph shown just before [trailingLabel], e.g. to mark that the label
  /// shows something other than the playback time.
  final Widget? trailingLabelIcon;

  /// Replaces [trailingLabel] for screen readers when the visible text does
  /// not speak well on its own.
  final String? trailingLabelSemanticsLabel;

  /// Stretches of the track to draw. Defaults to one full-width segment.
  final List<SeekBarSegment> segments;

  /// Builds the tooltip content for the scrub position while dragging.
  ///
  /// The bar supplies the bubble around it. No tooltip is shown when null.
  final Widget Function(BuildContext context, double value)? tooltipBuilder;

  /// Formats a track fraction for screen readers, e.g. "01:00 of 10:00".
  ///
  /// Also used for the values announced after an increase/decrease action;
  /// those actions are only offered when a formatter is given.
  final String Function(double value)? semanticValueFormatter;

  /// Whether screen readers are offered increase/decrease actions.
  ///
  /// Pass false while a seek cannot take effect (e.g. the duration is still
  /// unknown), so the actions do not announce a position that never comes.
  final bool adjustable;

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
  // How far the time labels tuck under the bottom of the touch area. The
  // track is drawn in the middle of the 32 pt touch area, so without this
  // the labels sat about 17 pt below a 6 pt bar, which read as detached.
  static const double _labelOverlap = 10.0;
  static const Duration _thicknessAnimation = Duration(milliseconds: 150);

  // Lets the track forward taps that land on the part of the trailing label
  // it covers (see [_forwardLabelTap]).
  final GlobalKey _trailingLabelKey = GlobalKey();
  // The one pointer that may become a forwarded label tap; later touches are
  // ignored until it lifts.
  PointerDownEvent? _labelTapDown;
  bool _isDragging = false;
  double _dragValue = 0.0;
  double _trackWidth = 0.0;
  ScrubSpeed _scrubSpeed = ScrubSpeed.full;
  SeekReleaseTracker? _releaseTracker;
  // Timestamp of the latest pointer event on the track. Recorded by a
  // Listener below the drag recognizer, so it is current when the
  // recognizer's callbacks run.
  Duration _lastPointerTime = Duration.zero;
  // Pointer of the latest move on the track, which is the one driving the
  // drag when the recognizer reports an update.
  int? _lastMovedPointer;
  int? _dragPointer;
  // A cancel after the drag started arrives as a drag end, not as a drag
  // cancel, so the Listener flags it to skip the lift-off rule. Only the
  // dragging pointer counts, so an unrelated touch cannot change the release.
  bool _pointerCancelled = false;
  // Raw horizontal finger travel since the drag began, before fine-scrub
  // scaling, so the release rule can measure roll under the finger.
  double _fingerTravel = 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final value = (_isDragging ? _dragValue : widget.value).clamp(0.0, 1.0);

    return _buildSemantics(
      value: value,
      // The track is stacked last so its whole touch area stays draggable
      // where the labels tuck underneath it.
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: _touchAreaHeight - _labelOverlap,
            ),
            child: _buildLabels(theme, primary),
          ),
          _withTooltip(value, _forwardLabelTap(_buildTrack(value, primary))),
        ],
      ),
    );
  }

  Widget _buildSemantics({required double value, required Widget child}) {
    final format = widget.semanticValueFormatter;
    if (format == null) return Semantics(slider: true, child: child);
    if (!widget.adjustable) {
      return Semantics(slider: true, value: format(value), child: child);
    }
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
          onHorizontalDragEnd: (_) => _handleDragEnd(),
          onHorizontalDragCancel: () => _finishDrag(_dragValue),
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: _recordPointerTime,
            onPointerMove: (event) {
              _lastMovedPointer = event.pointer;
              _recordPointerTime(event);
            },
            onPointerUp: _recordPointerTime,
            onPointerCancel: (event) {
              if (event.pointer == _dragPointer) _pointerCancelled = true;
            },
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
                    segmentGap: PlayerSeekBar.segmentGap,
                    activeColor: primary,
                    inactiveColor: primary.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _recordPointerTime(PointerEvent event) {
    _lastPointerTime = event.timeStamp;
  }

  // The track sits on top of the tucked-in labels so drags work across its
  // whole touch area, which hides the top of the trailing label from hit
  // testing. Forward taps landing there so the label's toggle keeps its full
  // tap target. A raw Listener is used because a tap recognizer would join
  // the gesture arena and make a lone drag wait for the touch slop.
  Widget _forwardLabelTap(Widget track) {
    if (widget.onTrailingLabelTap == null) return track;
    return Listener(
      onPointerDown: _handleTrackPointerDown,
      onPointerCancel: (event) => _clearLabelTap(event.pointer),
      onPointerUp: _handleTrackPointerUp,
      child: track,
    );
  }

  void _handleTrackPointerDown(PointerDownEvent event) {
    if (_labelTapDown != null) return;
    if (!_isOnTrailingLabel(event.position)) return;
    _labelTapDown = event;
  }

  void _clearLabelTap(int pointer) {
    if (_labelTapDown?.pointer == pointer) _labelTapDown = null;
  }

  // Runs before the drag recognizer sees the up event, so [_isDragging] still
  // tells a scrub apart from a tap.
  void _handleTrackPointerUp(PointerUpEvent event) {
    final down = _labelTapDown;
    if (down == null || down.pointer != event.pointer) return;
    _labelTapDown = null;
    if (_isDragging) return;
    if (kTouchSlop < (event.position - down.position).distance) return;
    widget.onTrailingLabelTap?.call();
  }

  bool _isOnTrailingLabel(Offset globalPosition) {
    final box = _trailingLabelKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return false;
    return box.size.contains(box.globalToLocal(globalPosition));
  }

  // The tooltip floats above the track without taking layout space, so the
  // bar keeps its height whether or not the user is scrubbing. The Stack is
  // always present: wrapping the track only once a drag starts would remount
  // its gesture detector and cancel that drag.
  Widget _withTooltip(double value, Widget track) {
    final builder = widget.tooltipBuilder;
    final showTooltip = _isDragging && builder != null;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        track,
        if (showTooltip)
          Positioned(
            left: 0,
            right: 0,
            bottom: _touchAreaHeight + PlayerSeekBar.tooltipSpacing,
            child: IgnorePointer(
              child: _TooltipPositioner(
                anchor: value,
                child: _TooltipBubble(child: builder(context, value)),
              ),
            ),
          ),
      ],
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
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        children: [
          ExcludeSemantics(child: Text(widget.leadingLabel, style: style)),
          Expanded(
            child: _buildScrubSpeedLabel(style?.copyWith(color: primary)),
          ),
          // A sleep countdown with its glyph and a `+N` suffix is wider than
          // a time label; capped at half the row, it scales down on a narrow
          // sheet or with large text instead of overflowing.
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth / 2),
            child: _buildTrailingButton(style),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailingButton(TextStyle? style) {
    return Semantics(
      button: widget.onTrailingLabelTap != null,
      label: widget.trailingLabelSemanticsLabel,
      excludeSemantics: widget.trailingLabelSemanticsLabel != null,
      // Excluding the children drops the gesture's tap action, so the
      // node offers it itself.
      onTap: widget.trailingLabelSemanticsLabel != null
          ? widget.onTrailingLabelTap
          : null,
      child: GestureDetector(
        key: _trailingLabelKey,
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTrailingLabelTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: _buildTrailingLabel(style),
          ),
        ),
      ),
    );
  }

  Widget _buildTrailingLabel(TextStyle? style) {
    final text = Text(widget.trailingLabel, style: style);
    final icon = widget.trailingLabelIcon;
    if (icon == null) return text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconTheme.merge(
          data: IconThemeData(size: style?.fontSize, color: style?.color),
          child: icon,
        ),
        const SizedBox(width: 2),
        text,
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
    // Scaled down rather than ellipsized: on a narrow sheet the band name at
    // the end of the label is the part the user needs while fine scrubbing.
    return ExcludeSemantics(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(label, style: style, maxLines: 1),
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
    _pointerCancelled = false;
    _fingerTravel = 0.0;
    _releaseTracker = SeekReleaseTracker(
      startValue: start,
      startTime: _lastPointerTime,
      trackWidth: _trackWidth,
      startFinger: _fingerTravel,
    );
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
    // The recognizer may follow a newer finger, so re-read it on each update.
    _dragPointer = _lastMovedPointer;
    _fingerTravel += delta;
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
    // Recorded even when clamped at an end of the track, so the finger
    // position the release rule compares against stays current while the
    // finger pushes past the end.
    _releaseTracker?.update(next, _lastPointerTime, finger: _fingerTravel);
    if (next == _dragValue) return;
    setState(() => _dragValue = next);
    widget.onChanged?.call(next);
  }

  // On lift-off, commit the settled position when the last move was roll.
  // The parent hears the corrected value through onChanged first, so a
  // parent that shows the drag value displays what is committed.
  void _handleDragEnd() {
    final tracker = _releaseTracker;
    if (!_isDragging || tracker == null) return;
    if (_pointerCancelled) return _finishDrag(_dragValue);
    final end = tracker.resolveRelease(_lastPointerTime);
    if (end != _dragValue) {
      setState(() => _dragValue = end);
      widget.onChanged?.call(end);
    }
    _finishDrag(end);
  }

  // A cancel is not a lift-off, so it commits the position as it stands.
  void _finishDrag(double end) {
    if (!_isDragging) return;
    _releaseTracker = null;
    _dragPointer = null;
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
    this.segmentGap = 0.0,
  });

  final double value;
  final double trackHeight;
  final List<SeekBarSegment> segments;

  /// Width removed where two segments meet, split between both sides. The
  /// outer ends of the track are never inset.
  final double segmentGap;
  final Color activeColor;
  final Color inactiveColor;

  @override
  void paint(Canvas canvas, Size size) {
    final top = (size.height - trackHeight) / 2;
    final radius = Radius.circular(trackHeight / 2);
    final activePaint = Paint()..color = activeColor;
    final inactivePaint = Paint()..color = inactiveColor;
    final playedX = size.width * value;

    final halfGap = segmentGap / 2;

    for (final segment in segments) {
      final left =
          size.width * segment.start + (0 < segment.start ? halfGap : 0);
      final right = size.width * segment.end - (segment.end < 1 ? halfGap : 0);
      // A segment narrower than the gap would draw inverted; skip it.
      if (right <= left) continue;
      final rect = Rect.fromLTRB(left, top, right, top + trackHeight);
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
      oldDelegate.segmentGap != segmentGap ||
      oldDelegate.activeColor != activeColor ||
      oldDelegate.inactiveColor != inactiveColor ||
      !listEquals(oldDelegate.segments, segments);
}

/// Rounded bubble around the tooltip content, in the inverse surface colors
/// so it reads against both the artwork and the sheet background.
class _TooltipBubble extends StatelessWidget {
  const _TooltipBubble({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: colorScheme.onInverseSurface,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return DecoratedBox(
      key: PlayerSeekBar.tooltipKey,
      decoration: BoxDecoration(
        color: colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: DefaultTextStyle.merge(
          style: textStyle,
          textAlign: TextAlign.center,
          child: IconTheme.merge(
            data: IconThemeData(color: colorScheme.onInverseSurface),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Centers its child over the [anchor] fraction of the available width,
/// shifted inward as needed so it never extends past either edge.
class _TooltipPositioner extends SingleChildRenderObjectWidget {
  const _TooltipPositioner({required this.anchor, super.child});

  final double anchor;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderTooltipPositioner(anchor);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderTooltipPositioner renderObject,
  ) {
    renderObject.anchor = anchor;
  }
}

class _RenderTooltipPositioner extends RenderShiftedBox {
  _RenderTooltipPositioner(this._anchor) : super(null);

  double _anchor;

  set anchor(double value) {
    if (value == _anchor) return;
    _anchor = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final child = this.child;
    final width = constraints.maxWidth;
    if (child == null) {
      size = constraints.constrain(Size(width, 0));
      return;
    }
    child.layout(BoxConstraints(maxWidth: width), parentUsesSize: true);
    final childSize = child.size;
    size = constraints.constrain(Size(width, childSize.height));
    final maxLeft = math.max(0.0, width - childSize.width);
    final left = (width * _anchor - childSize.width / 2).clamp(0.0, maxLeft);
    (child.parentData! as BoxParentData).offset = Offset(left, 0);
  }
}
