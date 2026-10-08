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

  /// Height above the bottom safe-area inset.
  static const double height = 56;

  final List<AppTabBarItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return Material(
      color: colors.bg,
      child: Container(
        height: height + bottomInset,
        padding: EdgeInsets.only(bottom: bottomInset),
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
