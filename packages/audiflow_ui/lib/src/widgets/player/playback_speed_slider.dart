import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Slider over [PlaybackSpeedScale.steps] with a light haptic per step.
///
/// [onChanged] fires once for every step the thumb crosses, so callers
/// can apply the speed immediately. [onChangeEnd] fires with the final
/// speed when the gesture ends, which is where callers commit side
/// effects that should happen once per gesture (history, analytics).
class PlaybackSpeedSlider extends StatefulWidget {
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
  // Index under the thumb during (and just after) a drag. Applying a
  // speed is async, so [widget.speed] lags the gesture; tracking the
  // index locally keeps the thumb responsive and stops repeated
  // callbacks for the same step.
  int? _dragIndex;
  bool _isDragging = false;

  int get _index =>
      _dragIndex ?? PlaybackSpeedScale.indexForSpeed(widget.speed);

  @override
  void didUpdateWidget(PlaybackSpeedSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Once the gesture is over, the first speed update from the parent
    // takes over so the thumb never disagrees with the real speed.
    if (!_isDragging && widget.speed != oldWidget.speed) _dragIndex = null;
  }

  void _handleChangeStart(double value) => _isDragging = true;

  void _handleChanged(double value) {
    final index = value.round();
    if (index == _index) return;
    setState(() => _dragIndex = index);
    HapticFeedback.lightImpact();
    widget.onChanged(PlaybackSpeedScale.speedForIndex(index));
  }

  void _handleChangeEnd(double value) {
    _isDragging = false;
    final speed = PlaybackSpeedScale.speedForIndex(value.round());
    // Keep the dragged index until the parent catches up, unless it
    // already has, to avoid the thumb snapping back for a frame.
    if (PlaybackSpeedScale.snap(widget.speed) == speed) {
      setState(() => _dragIndex = null);
    }
    widget.onChangeEnd?.call(speed);
  }

  @override
  Widget build(BuildContext context) {
    final maxIndex = PlaybackSpeedScale.maxIndex;
    final speed = PlaybackSpeedScale.speedForIndex(_index);
    final label = PlaybackSpeedScale.label(speed);
    return Slider(
      value: _index.toDouble(),
      max: maxIndex.toDouble(),
      divisions: maxIndex,
      label: label,
      semanticFormatterCallback: (_) => label,
      onChangeStart: _handleChangeStart,
      onChanged: _handleChanged,
      onChangeEnd: _handleChangeEnd,
    );
  }
}
