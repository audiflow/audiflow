import 'dart:math' as math;

import 'package:flutter/material.dart';

const int _barCount = 12;
const double _barWidth = 3.0;
const double _barSpacing = 3.0;
const double _phaseOffsetPerBar = 0.5;

/// Defines the visual and timing parameters for each animation state.
enum WaveformAnimationMode {
  listening(
    duration: Duration(milliseconds: 800),
    minHeight: 4.0,
    maxHeight: 40.0,
    bottomColor: Color(0xFF0D47A1),
    topColor: Color(0xFFFFC107),
  ),
  processing(
    duration: Duration(milliseconds: 2000),
    minHeight: 4.0,
    maxHeight: 16.0,
    bottomColor: Color(0xFF0D47A1),
    topColor: Color(0xFF1976D2),
  ),
  idle(
    // Duration(milliseconds: 1) avoids AnimationController zero-duration assertion.
    duration: Duration(milliseconds: 1),
    minHeight: 4.0,
    maxHeight: 4.0,
    bottomColor: Color(0xFF0D47A1),
    topColor: Color(0xFF1976D2),
  );

  const WaveformAnimationMode({
    required this.duration,
    required this.minHeight,
    required this.maxHeight,
    required this.bottomColor,
    required this.topColor,
  });

  final Duration duration;
  final double minHeight;
  final double maxHeight;
  final Color bottomColor;
  final Color topColor;
}

/// Paints animated frequency bars driven by [animation].
///
/// Each bar height follows a sinusoidal curve with a per-bar phase offset
/// to create organic wave motion.
class WaveformPainter extends CustomPainter {
  WaveformPainter({required this.animation, required this.mode})
    : super(repaint: animation);

  final Animation<double> animation;
  final WaveformAnimationMode mode;

  /// Computes the rendered bar height for [barIndex] at the current
  /// animation value. Exposed for unit testing.
  double barHeightForIndex(int barIndex) {
    final amplitude = mode.maxHeight - mode.minHeight;
    if (amplitude == 0.0) {
      return mode.minHeight;
    }
    final phase = barIndex * _phaseOffsetPerBar;
    final sinValue = math.sin(animation.value * 2 * math.pi + phase);
    // sinValue is in [-1, 1]; normalise to [0, 1].
    final normalised = (sinValue + 1.0) / 2.0;
    return mode.minHeight + amplitude * normalised;
  }

  /// Midpoint color used for the glow shadow beneath each bar.
  Color get _glowColor {
    return Color.lerp(mode.bottomColor, mode.topColor, 0.5) ?? mode.bottomColor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final totalWidth = _barCount * _barWidth + (_barCount - 1) * _barSpacing;
    var startX = (size.width - totalWidth) / 2.0;
    final centerY = size.height / 2.0;

    // Hoist paint objects out of the loop to avoid per-bar allocation.
    final shadowPaint = Paint()
      ..color = _glowColor.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    final gradientPaint = Paint()..style = PaintingStyle.fill;
    final gradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [mode.bottomColor, mode.topColor],
    );

    for (var i = 0; i < _barCount; i++) {
      final barHeight = barHeightForIndex(i);
      final barRect = Rect.fromLTWH(
        startX,
        centerY - barHeight / 2.0,
        _barWidth,
        barHeight,
      );

      // Glow shadow beneath the bar.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          barRect.inflate(1.0),
          const Radius.circular(_barWidth / 2.0),
        ),
        shadowPaint,
      );

      // Gradient bar -- reuse paint, only update shader per bar rect.
      gradientPaint.shader = gradient.createShader(barRect);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          barRect,
          const Radius.circular(_barWidth / 2.0),
        ),
        gradientPaint,
      );

      startX += _barWidth + _barSpacing;
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.animation.value != animation.value ||
        oldDelegate.mode != mode;
  }
}

/// Stateful widget that owns the [AnimationController] and exposes
/// [WaveformPainter] via [CustomPaint].
class WaveformWidget extends StatefulWidget {
  const WaveformWidget({super.key, required this.mode});

  final WaveformAnimationMode mode;

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.mode.duration,
    );
    _startAnimationForMode(widget.mode);
  }

  @override
  void didUpdateWidget(WaveformWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      _controller.duration = widget.mode.duration;
      _startAnimationForMode(widget.mode);
    }
  }

  void _startAnimationForMode(WaveformAnimationMode mode) {
    switch (mode) {
      case WaveformAnimationMode.listening:
      case WaveformAnimationMode.processing:
        _controller.repeat();
      case WaveformAnimationMode.idle:
        _controller.stop();
        _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WaveformPainter(animation: _controller, mode: widget.mode),
      size: Size.infinite,
    );
  }
}
