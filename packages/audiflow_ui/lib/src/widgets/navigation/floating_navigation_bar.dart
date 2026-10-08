import 'package:flutter/material.dart';

import '../../styles/spacing.dart';
import '../../themes/app_colors.dart';
import '../../themes/text_styles.dart';
import 'navigation_search_field.dart';

/// Navigation overlaid on a detail screen's content (redesign 3.3).
///
/// Leading back button, centered title, trailing action pill. The title
/// and the `bg` fill with its hairline are driven by [titleOpacity] and
/// [backgroundOpacity] (see `FloatingNavScroll`). When [search] is set,
/// it replaces the whole row (redesign 3.4). Place it at the top of a
/// `Stack` over the scroll view; it pads itself below the status bar.
class FloatingNavigationBar extends StatelessWidget {
  const FloatingNavigationBar({
    super.key,
    required this.leading,
    this.title,
    this.titleOpacity = 0,
    this.backgroundOpacity = 0,
    this.trailing,
    this.search,
  });

  /// Height of the bar below the status bar inset.
  static const double barHeight = 60;

  /// Duration of the cross-fade between the toolbar and [search].
  static const Duration switchDuration = Duration(milliseconds: 260);

  @visibleForTesting
  static const Key backgroundKey = ValueKey('floatingNavigationBackground');

  final Widget leading;
  final String? title;
  final double titleOpacity;
  final double backgroundOpacity;
  final Widget? trailing;
  final NavigationSearchField? search;

  /// Total height including the status bar inset, for content padding.
  static double heightOf(BuildContext context) {
    return MediaQuery.paddingOf(context).top + barHeight;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final fill = backgroundOpacity.clamp(0.0, 1.0);
    return DecoratedBox(
      key: backgroundKey,
      decoration: BoxDecoration(
        color: colors.bg.withValues(alpha: fill),
        border: Border(
          bottom: BorderSide(color: colors.hairline.withValues(alpha: fill)),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        child: SizedBox(
          height: barHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: AnimatedSwitcher(
              duration: switchDuration,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              layoutBuilder: (current, previous) => Stack(
                fit: StackFit.expand,
                children: [...previous, ?current],
              ),
              transitionBuilder: _crossSlide,
              child: search == null
                  ? KeyedSubtree(
                      key: const ValueKey('toolbar'),
                      child: _toolbar(colors),
                    )
                  : KeyedSubtree(key: const ValueKey('search'), child: search!),
            ),
          ),
        ),
      ),
    );
  }

  // A short horizontal drift with the fade, so the search field reads as
  // arriving rather than the row blinking into something else.
  static Widget _crossSlide(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0.04, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  Widget _toolbar(AppColors colors) {
    final opacity = titleOpacity.clamp(0.0, 1.0);
    return NavigationToolbar(
      leading: leading,
      trailing: trailing,
      middleSpacing: Spacing.sm,
      middle: title == null
          ? null
          : Opacity(
              opacity: opacity,
              child: ExcludeSemantics(
                excluding: opacity == 0,
                child: Text(
                  title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.rowTitle.copyWith(
                    fontSize: 17,
                    color: colors.ink,
                  ),
                ),
              ),
            ),
    );
  }
}
