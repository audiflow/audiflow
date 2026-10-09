import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../haptics/haptic_token.dart';
import '../../haptics/haptics_scope.dart';
import 'step_drag_tracker.dart';

/// Slider over [PlaybackSpeedScale.steps].
///
/// It gives no haptic per step: on a device, a tick for each of the 21
/// steps crossed in one drag felt like noise rather than feedback. The
/// one exception is a `detent` when a drag reaches or passes 1.0x, the
/// speed listeners most often return to.
///
/// Landmark speeds ([landmarkSpeeds]) are labelled under the exact tick
/// they belong to, so the uneven step grid (0.1 up to 2.0, then 0.2)
/// stays readable.
///
/// [onChanged] fires once for every step the thumb crosses, so callers
/// can apply the speed immediately. [onChangeEnd] fires with the final
/// speed when the gesture ends, which is where callers commit side
/// effects that should happen once per gesture (history, analytics).
class PlaybackSpeedSlider extends StatefulWidget {
  /// Speeds labelled under the track.
  static const List<double> landmarkSpeeds = [0.5, 1.0, 2.0, 3.0];

  const PlaybackSpeedSlider({
    super.key,
    required this.speed,
    required this.onChanged,
    this.onChangeEnd,
  });

  /// Current speed; snapped to the nearest step for display.
  final double speed;

  /// Called with the new speed each time the selected step changes.
  final ValueChanged<double> onChanged;

  /// Called with the selected speed when the user releases the slider.
  final ValueChanged<double>? onChangeEnd;

  @override
  State<PlaybackSpeedSlider> createState() => _PlaybackSpeedSliderState();
}

class _PlaybackSpeedSliderState extends State<PlaybackSpeedSlider> {
  // Index under the thumb while dragging. The parent may rebuild with
  // the new speed a moment later; tracking the index locally keeps the
  // thumb responsive and stops repeated callbacks for the same step.
  int? _dragIndex;
  int? _gestureStartIndex;
  StepDragTracker? _tracker;
  // Timestamp of the latest pointer event. Recorded by a Listener that
  // sees each event before the drag recognizer reports it.
  Duration _lastPointerTime = Duration.zero;
  // Where a tap went down. A tap commits this point rather than the
  // lift-off point, which can roll onto a neighbouring step.
  Offset? _tapDownPosition;

  int get _index =>
      _dragIndex ?? PlaybackSpeedScale.indexForSpeed(widget.speed);

  bool get _isDragging => _tracker != null;

  // -- Pointer gestures (handled above the Slider) --

  double _positionInSteps(Offset local, double width) {
    final first = _SliderGeometry.tickX(0, width);
    final last = _SliderGeometry.tickX(PlaybackSpeedScale.maxIndex, width);
    final fraction = ((local.dx - first) / (last - first)).clamp(0.0, 1.0);
    return fraction * PlaybackSpeedScale.maxIndex;
  }

  void _handleTapUp(double width) {
    final down = _tapDownPosition;
    _tapDownPosition = null;
    if (down == null) return;
    final startIndex = _index;
    final index = _positionInSteps(down, width).round();
    if (index == startIndex) return;
    _select(index);
    _commit(index, startIndex: startIndex);
  }

  void _handleDragStart(DragStartDetails details, double width) {
    _gestureStartIndex = _index;
    // The first contact jumps to the step under the finger, like a tap.
    final index = _positionInSteps(details.localPosition, width).round();
    _tracker = StepDragTracker(startIndex: index, startTime: _lastPointerTime);
    if (index == _index) return setState(() {});
    _select(index);
  }

  void _handleDragUpdate(DragUpdateDetails details, double width) {
    final tracker = _tracker;
    if (tracker == null) return;
    final position = _positionInSteps(details.localPosition, width);
    if (!tracker.update(position, _lastPointerTime)) return;
    // Only finger travel passes the mark; the first contact's jump to the
    // touched step does not.
    if (_reachesNormal(_index, tracker.index)) {
      HapticsScope.of(context).play(HapticToken.detent);
    }
    _select(tracker.index);
  }

  void _handleDragEnd() {
    final tracker = _tracker;
    if (tracker == null) return;
    final index = tracker.resolveRelease(_lastPointerTime);
    // Lift-off roll undone: put the player back on the settled step.
    if (index != _index) _select(index);
    _commit(index, startIndex: _gestureStartIndex);
  }

  void _select(int index) {
    setState(() => _dragIndex = index);
    widget.onChanged(PlaybackSpeedScale.speedForIndex(index));
  }

  static final int _normalIndex = PlaybackSpeedScale.indexForSpeed(
    PlaybackSpeedScale.normal,
  );

  bool _reachesNormal(int from, int to) {
    if (from == _normalIndex) return false;
    final low = from < to ? from : to;
    final high = from < to ? to : from;
    return low <= _normalIndex && _normalIndex <= high;
  }

  void _commit(int index, {required int? startIndex}) {
    setState(() {
      _tracker = null;
      _gestureStartIndex = null;
      _dragIndex = null;
    });
    // A tap on the thumb or a drag back to the start changes nothing, so
    // it must not count as a new choice.
    if (index == startIndex) return;
    widget.onChangeEnd?.call(PlaybackSpeedScale.speedForIndex(index));
  }

  // -- Slider callbacks (reached only by semantics and keyboard actions,
  // because pointer input is captured by the gesture layer) --

  void _handleChangeStart(double value) => _gestureStartIndex = _index;

  void _handleChanged(double value) {
    final index = value.round();
    if (index == _index) return;
    _select(index);
  }

  void _handleChangeEnd(double value) =>
      _commit(value.round(), startIndex: _gestureStartIndex);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) => Stack(
            clipBehavior: Clip.none,
            children: [
              _buildSlider(context),
              Positioned.fill(child: _gestureLayer(constraints.maxWidth)),
              if (_isDragging) _valueBubble(context, constraints.maxWidth),
            ],
          ),
        ),
        const _LandmarkLabels(),
      ],
    );
  }

  /// Captures pointer input before the Slider so drags go through the
  /// jitter filter. Sitting above the Slider (not wrapping it in
  /// IgnorePointer) keeps the Slider's semantics actions working.
  Widget _gestureLayer(double width) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      dragStartBehavior: DragStartBehavior.down,
      onTapDown: (details) => _tapDownPosition = details.localPosition,
      onTapUp: (_) => _handleTapUp(width),
      onTapCancel: () => _tapDownPosition = null,
      onHorizontalDragStart: (details) => _handleDragStart(details, width),
      onHorizontalDragUpdate: (details) => _handleDragUpdate(details, width),
      onHorizontalDragEnd: (_) => _handleDragEnd(),
      onHorizontalDragCancel: _handleDragEnd,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) => _lastPointerTime = event.timeStamp,
        onPointerMove: (event) => _lastPointerTime = event.timeStamp,
        onPointerUp: (event) => _lastPointerTime = event.timeStamp,
      ),
    );
  }

  /// Speed shown above the thumb while dragging. The Slider's own value
  /// indicator never appears because it does not receive the pointer.
  Widget _valueBubble(BuildContext context, double width) {
    final theme = Theme.of(context);
    final label = PlaybackSpeedScale.label(
      PlaybackSpeedScale.speedForIndex(_index),
    );
    return Positioned(
      left: _SliderGeometry.tickX(_index, width),
      top: 0,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -1),
        child: ExcludeSemantics(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(BuildContext context) {
    final maxIndex = PlaybackSpeedScale.maxIndex;
    final label = PlaybackSpeedScale.label(
      PlaybackSpeedScale.speedForIndex(_index),
    );
    // Pinning the padding and track height makes the tick positions
    // computable, which the gesture layer and labels rely on.
    return SliderTheme(
      data: SliderTheme.of(
        context,
      ).copyWith(trackHeight: _SliderGeometry.trackHeight),
      child: Slider(
        value: _index.toDouble(),
        max: maxIndex.toDouble(),
        divisions: maxIndex,
        label: label,
        padding: _SliderGeometry.padding,
        semanticFormatterCallback: (_) => label,
        onChangeStart: _handleChangeStart,
        onChanged: _handleChanged,
        onChangeEnd: _handleChangeEnd,
      ),
    );
  }
}

/// Track geometry shared by the slider and its landmark labels.
abstract final class _SliderGeometry {
  static const double horizontalInset = 24;
  static const double trackHeight = 4;
  static const EdgeInsets padding = EdgeInsets.symmetric(
    horizontal: horizontalInset,
    vertical: 12,
  );

  /// X offset of the tick at [index] within a slider of [width].
  ///
  /// Mirrors Flutter's discrete thumb placement on a rounded track: the
  /// usable span is shortened by the track height so the thumb never
  /// pokes past the rounded ends.
  static double tickX(int index, double width) {
    final span = width - 2 * horizontalInset - trackHeight;
    final fraction = index / PlaybackSpeedScale.maxIndex;
    return horizontalInset + trackHeight / 2 + fraction * span;
  }
}

class _LandmarkLabels extends StatelessWidget {
  const _LandmarkLabels();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return ExcludeSemantics(
      child: SizedBox(
        height: 16,
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            clipBehavior: Clip.none,
            children: [
              for (final speed in PlaybackSpeedSlider.landmarkSpeeds)
                _positionedLabel(speed, constraints.maxWidth, style),
            ],
          ),
        ),
      ),
    );
  }

  Widget _positionedLabel(double speed, double width, TextStyle? style) {
    final index = PlaybackSpeedScale.indexForSpeed(speed);
    return Positioned(
      left: _SliderGeometry.tickX(index, width),
      child: FractionalTranslation(
        translation: const Offset(-0.5, 0),
        child: Text(PlaybackSpeedScale.label(speed), style: style),
      ),
    );
  }
}
