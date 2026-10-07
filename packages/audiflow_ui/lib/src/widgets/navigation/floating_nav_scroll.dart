import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';

/// Scroll-driven visibility for detail screens with a hero under a
/// floating navigation bar (redesign sections 3.3, 4.2, 4.3).
///
/// All values are in `[0, 1]`. The hero collapses across its own height;
/// the navigation title and background fade in over the [fadeDistance]
/// pixels after the hero has fully scrolled away.
@immutable
class FloatingNavScroll {
  const FloatingNavScroll._({
    required this.hero,
    required this.title,
    required this.background,
  });

  /// Distance over which the title and background fade in.
  static const double fadeDistance = 24;

  /// 0 = hero fully shown, 1 = hero scrolled away.
  final double hero;

  /// Opacity of the navigation title.
  final double title;

  /// Opacity of the navigation bar's `bg` fill and hairline.
  final double background;

  factory FloatingNavScroll.at({
    required double offset,
    required double heroExtent,
  }) {
    final heroProgress = heroExtent <= 0
        ? 1.0
        : (offset / heroExtent).clamp(0.0, 1.0);
    // Without a hero there is nothing to wait for: the bar shows at once.
    final barProgress = heroExtent <= 0
        ? 1.0
        : ((offset - heroExtent) / fadeDistance).clamp(0.0, 1.0);
    return FloatingNavScroll._(
      hero: heroProgress,
      title: barProgress,
      background: barProgress,
    );
  }

  /// This state with an in-navigation search [progress] (0 to 1) folded
  /// in: as search takes over, the hero collapses, the bar fills, and the
  /// title gives way to the search field.
  FloatingNavScroll withSearch(double progress) {
    final t = progress.clamp(0.0, 1.0);
    return FloatingNavScroll._(
      hero: math.max(hero, t),
      title: title * (1 - t),
      background: math.max(background, t),
    );
  }
}

/// Fades and shrinks a hero toward its bottom edge as [progress] goes
/// from 0 to 1, so the upper part (artwork, title) visibly recedes while
/// the content below keeps scrolling at its normal pace.
class CollapsingHero extends StatelessWidget {
  const CollapsingHero({
    super.key,
    required this.progress,
    required this.child,
  });

  /// Scale at full collapse.
  static const double minScale = 0.85;

  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = progress.clamp(0.0, 1.0);
    return Opacity(
      opacity: 1 - t,
      child: Transform.scale(
        scale: lerpDouble(1, minScale, t)!,
        alignment: Alignment.bottomCenter,
        child: child,
      ),
    );
  }
}
