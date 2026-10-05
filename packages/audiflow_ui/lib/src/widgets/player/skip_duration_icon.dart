import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Displays a skip-duration icon that dynamically reflects the configured
/// number of [seconds].
///
/// Both directions render a `replay` glyph with a text overlay; forward flips
/// the glyph horizontally. Dedicated glyphs such as `replay_10` are avoided on
/// purpose: their embedded digits differ in size and weight from the overlay,
/// so backward and forward buttons would not match.
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

  // The replay arc is centered 54% down the icon box (the arrow head takes
  // the top). Digits with `height: 1` sit about 1.4% of the icon size above
  // their line box's center, so a top inset of 10% of the size centers them
  // in the arc. The previous 16% left them visibly low.
  static const double _digitTopInsetFactor = 0.10;

  @override
  Widget build(BuildContext context) {
    final glyph = Icon(Symbols.replay, size: size, color: color);
    final icon = isForward ? Transform.flip(flipX: true, child: glyph) : glyph;

    // ExcludeSemantics prevents duplicate screen reader announcements --
    // the parent Semantics widget already provides the accessibility label.
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            icon,
            Padding(
              padding: EdgeInsets.only(top: size * _digitTopInsetFactor),
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
