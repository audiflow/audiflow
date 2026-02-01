import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'year_divider.dart';

/// Builds slivers for subcategory-grouped episodes with two-level sticky
/// headers: subcategory name (level 1) and year (level 2).
///
/// Each subcategory becomes a [MultiSliver] with `pushPinnedChildren: true`,
/// so scrolling into the next subcategory pushes the previous header up.
///
/// Subcategory headers are tappable to expand/collapse their content.
/// All subcategories start expanded by default.
List<Widget> buildSubCategorySlivers<T>({
  required List<SubCategoryData<T>> subCategories,
  required Widget Function(BuildContext, T) itemBuilder,
  required Map<String, bool> expandedState,
  required ValueChanged<String> onToggle,
}) {
  return [
    for (final sub in subCategories)
      _SubCategorySliver<T>(
        key: ValueKey('sub_${sub.id}'),
        sub: sub,
        itemBuilder: itemBuilder,
        expanded: expandedState[sub.id] ?? false,
        onToggle: () => onToggle(sub.id),
      ),
  ];
}

class _SubCategorySliver<T> extends StatelessWidget {
  const _SubCategorySliver({
    super.key,
    required this.sub,
    required this.itemBuilder,
    required this.expanded,
    required this.onToggle,
  });

  final SubCategoryData<T> sub;
  final Widget Function(BuildContext, T) itemBuilder;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        SliverPinnedHeader(
          child: _SubCategoryHeader(
            name: sub.displayName,
            episodeCount: sub.itemCount,
            expanded: expanded,
            onTap: onToggle,
          ),
        ),
        if (expanded) ..._buildContent(),
      ],
    );
  }

  List<Widget> _buildContent() {
    if (sub.yearGrouped && sub.itemsByYear != null) {
      return _buildYearSlivers(
        itemsByYear: sub.itemsByYear!,
        sortedYears: sub.sortedYears!,
        itemBuilder: itemBuilder,
      );
    }
    return [
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => itemBuilder(context, sub.items[index]),
          childCount: sub.items.length,
        ),
      ),
    ];
  }
}

List<Widget> _buildYearSlivers<T>({
  required Map<int, List<T>> itemsByYear,
  required List<int> sortedYears,
  required Widget Function(BuildContext, T) itemBuilder,
}) {
  return [
    for (final year in sortedYears)
      MultiSliver(
        pushPinnedChildren: true,
        children: [
          SliverPinnedHeader(child: YearDivider(year: year)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  itemBuilder(context, itemsByYear[year]![index]),
              childCount: itemsByYear[year]!.length,
            ),
          ),
        ],
      ),
  ];
}

/// Data for a single subcategory to render as slivers.
class SubCategoryData<T> {
  const SubCategoryData({
    required this.id,
    required this.displayName,
    required this.items,
    this.yearGrouped = false,
    this.itemsByYear,
    this.sortedYears,
  });

  final String id;
  final String displayName;
  final List<T> items;
  final bool yearGrouped;
  final Map<int, List<T>>? itemsByYear;
  final List<int>? sortedYears;

  int get itemCount => items.length;
}

/// Pinned subcategory header with expand/collapse chevron.
class _SubCategoryHeader extends StatelessWidget {
  const _SubCategoryHeader({
    required this.name,
    required this.episodeCount,
    required this.expanded,
    required this.onTap,
  });

  final String name;
  final int episodeCount;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$episodeCount episodes',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.expand_more,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
