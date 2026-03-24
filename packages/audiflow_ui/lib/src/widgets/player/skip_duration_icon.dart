import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Returns the Material Symbol [IconData] for a forward-skip of [seconds],
/// or `null` when no dedicated icon exists (e.g. 15, 45, 60).
IconData? skipForwardIconData(int seconds) => switch (seconds) {
  5 => Symbols.forward_5,
  10 => Symbols.forward_10,
  30 => Symbols.forward_30,
  _ => null,
};

/// Returns the Material Symbol [IconData] for a backward-skip of [seconds],
/// or `null` when no dedicated icon exists (e.g. 15).
IconData? skipBackwardIconData(int seconds) => switch (seconds) {
  5 => Symbols.replay_5,
  10 => Symbols.replay_10,
  30 => Symbols.replay_30,
  _ => null,
};

/// Displays a skip-duration icon that dynamically reflects the configured
/// number of [seconds].
///
/// For 5, 10, and 30 seconds, a dedicated Material Symbol is used (e.g.
/// `forward_30`, `replay_10`). For other values (15, 45, 60), a base
/// forward/replay icon is shown with the number overlaid as text.
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
    final dedicated = isForward
        ? skipForwardIconData(seconds)
        : skipBackwardIconData(seconds);

    if (dedicated != null) {
      return Icon(dedicated, size: size, color: color);
    }

    // Fallback: base icon with text overlay
    final baseIcon = isForward ? Symbols.forward : Symbols.replay;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(baseIcon, size: size, color: color),
          Positioned(
            bottom: size * 0.18,
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
    );
  }
}
