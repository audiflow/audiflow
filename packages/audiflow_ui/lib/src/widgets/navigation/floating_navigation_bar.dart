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
            child: search ?? _toolbar(colors),
          ),
        ),
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
