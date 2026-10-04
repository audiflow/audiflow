import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Slider over [PlaybackSpeedScale.steps] with a light haptic per step.
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_buildSlider(context), const _LandmarkLabels()],
    );
  }

  Widget _buildSlider(BuildContext context) {
    final maxIndex = PlaybackSpeedScale.maxIndex;
    final label = PlaybackSpeedScale.label(
      PlaybackSpeedScale.speedForIndex(_index),
    );
    // Pinning the padding and track height makes the tick positions
    // computable, which the landmark labels below rely on.
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
