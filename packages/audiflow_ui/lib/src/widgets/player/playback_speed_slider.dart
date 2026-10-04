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
  // Index under the thumb while dragging. The parent may rebuild with
  // the new speed a moment later; tracking the index locally keeps the
  // thumb responsive and stops repeated callbacks for the same step.
  int? _dragIndex;
  int? _gestureStartIndex;

  int get _index =>
      _dragIndex ?? PlaybackSpeedScale.indexForSpeed(widget.speed);

  void _handleChangeStart(double value) => _gestureStartIndex = _index;

  void _handleChanged(double value) {
    final index = value.round();
    if (index == _index) return;
    setState(() => _dragIndex = index);
    HapticFeedback.lightImpact();
    widget.onChanged(PlaybackSpeedScale.speedForIndex(index));
  }

  void _handleChangeEnd(double value) {
    final index = value.round();
    final startIndex = _gestureStartIndex;
    _gestureStartIndex = null;
    setState(() => _dragIndex = null);
    // A tap on the thumb or a drag back to the start changes nothing, so
    // it must not count as a new choice.
    if (index == startIndex) return;
    widget.onChangeEnd?.call(PlaybackSpeedScale.speedForIndex(index));
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
