import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

// Forward durations always use flipped replay + text overlay for visual
// consistency with the backward icons. No dedicated forward_N glyphs.

IconData? _skipBackwardIconData(int seconds) => switch (seconds) {
  5 => Symbols.replay_5,
  10 => Symbols.replay_10,
  30 => Symbols.replay_30,
  _ => null,
};

/// Displays a skip-duration icon that dynamically reflects the configured
/// number of [seconds].
///
/// Backward 5, 10, and 30 use dedicated Material Symbols (`replay_5`, etc.).
/// All forward durations use a horizontally flipped `replay` icon with a text
/// overlay so the style is consistent across all values.
class SkipDurationIcon extends StatelessWidget {
  const SkipDurationIcon({
    required this.seconds,
    required this.isForward,
    required this.size,
    this.color,
    super.key,
  });

  final int seconds;
  final bool isForward;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    // Backward 5/10/30 use dedicated Material Symbol glyphs.
    if (!isForward) {
      final dedicated = _skipBackwardIconData(seconds);
      if (dedicated != null) {
        return Icon(dedicated, size: size, color: color);
      }
    }

    // All forward durations and non-dedicated backward durations use
    // replay icon + text overlay. Forward flips the icon horizontally.
    // ExcludeSemantics prevents duplicate screen reader announcements --
    // the parent Semantics widget already provides the accessibility label.
    final icon = isForward
        ? Transform.flip(
            flipX: true,
            child: Icon(Symbols.replay, size: size, color: color),
          )
        : Icon(Symbols.replay, size: size, color: color);

    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            icon,
            Padding(
              padding: EdgeInsets.only(top: size * 0.16),
              child: Text(
                '$seconds',
                style: TextStyle(
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w700,
                  color: color ?? IconTheme.of(context).color,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
