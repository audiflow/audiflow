import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../themes/app_colors.dart';
import '../../themes/text_styles.dart';

/// One tab in [AppTabBar].
@immutable
class AppTabBarItem {
  const AppTabBarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  /// Drawn filled when [selected] (Material Symbols honor `fill`).
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
}

/// Bottom tab bar (redesign section 3.6).
///
/// The active tab uses `accent` with a filled icon and a 600 label;
/// inactive tabs use `inkTertiary`. Callers pass only the visible tabs,
/// so hiding one (e.g. Search under Restricted Mode) needs no index
/// mapping here.
class AppTabBar extends StatelessWidget {
  const AppTabBar({super.key, required this.items});

  /// Height above the bottom padding.
  static const double height = 56;

  /// How far the tabs sink into the iOS home-indicator inset.
  ///
  /// Padding by the full 34pt inset leaves the tabs visibly higher than
  /// native iOS tab bars, which draw part-way into that area. Android
  /// keeps the full inset because it can be the 3-button navigation bar.
  static const double homeIndicatorOverlap = 12;

  final List<AppTabBarItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final bottomPadding = _bottomPadding(context);
    return Material(
      color: colors.bg,
      child: Container(
        height: height + bottomPadding,
        padding: EdgeInsets.only(bottom: bottomPadding),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.hairline, width: 0.5)),
        ),
        child: Row(
          children: [
            for (final item in items) Expanded(child: _Tab(item: item)),
          ],
        ),
      ),
    );
  }

  static double _bottomPadding(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    if (Theme.of(context).platform != TargetPlatform.iOS) return bottomInset;
    return math.max(0, bottomInset - homeIndicatorOverlap);
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.item});

  final AppTabBarItem item;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final color = item.selected ? colors.accent : colors.inkTertiary;
    return Semantics(
      button: true,
      selected: item.selected,
      child: InkResponse(
        onTap: item.onTap,
        containedInkWell: true,
        highlightShape: BoxShape.rectangle,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 26,
              fill: item.selected ? 1 : 0,
              color: color,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: item.selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
