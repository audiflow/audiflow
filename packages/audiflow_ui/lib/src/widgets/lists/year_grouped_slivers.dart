import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'grouped_section.dart';
import 'year_divider.dart';
import 'year_picker_bottom_sheet.dart';

/// Height of the sticky year header and inline year dividers.
const double yearHeaderHeight = 44.0;

/// Builds a list of slivers with a single sticky year header.
///
/// Returns `List<Widget>` to be spread into a `CustomScrollView.slivers`.
/// Uses a [SliverPinnedHeader] whose label updates as the user scrolls,
/// followed by per-year [SliverFixedExtentList] sections separated by
/// inline year dividers.
///
/// [SliverFixedExtentList] enables O(1) scroll-to-offset for any distance
/// because Flutter can compute which items are visible at any offset without
/// building intermediate items.
///
/// Year offsets are estimated from [itemExtent] and item counts
/// for jump-to-year navigation.
///
/// A [SliverLayoutBuilder] captures the preceding scroll extent (height of
/// all slivers before the year-grouped content) so jump-to-year accounts
/// for headers, tabs, and other content above.
///
/// Tapping the pinned header or any inline year divider opens a year picker
/// bottom sheet for quick navigation.
///
/// When [yearGroupingEnabled] is false or there are fewer than 2 years,
/// returns a single flat list with no headers.
List<Widget> buildYearGroupedSlivers<T>({
  required Map<int, List<T>> itemsByYear,
  required List<int> sortedYears,
  required Widget Function(BuildContext, T) itemBuilder,
  required ScrollController scrollController,
  required bool yearGroupingEnabled,
  double? itemExtent,
  bool grouped = false,
}) {
  // Grouped rows sit on one rounded surface per year (redesign "grouped
  // lists over cards"); row heights then come from the rows themselves.
  Widget list(List<T> items) {
    if (grouped) {
      return SliverGroupedSection(
        itemCount: items.length,
        itemBuilder: (context, index) => itemBuilder(context, items[index]),
      );
    }
    final delegate = SliverChildBuilderDelegate(
      (context, index) => itemBuilder(context, items[index]),
      childCount: items.length,
    );
    return itemExtent != null
        ? SliverFixedExtentList(itemExtent: itemExtent, delegate: delegate)
        : SliverList(delegate: delegate);
  }

  if (!yearGroupingEnabled || sortedYears.length < 2) {
    final allItems = <T>[];
    for (final year in sortedYears) {
      allItems.addAll(itemsByYear[year] ?? []);
    }
    return [list(allItems)];
  }

  // Estimated year offsets, used only until layout has measured the real
  // ones (see yearStarts).
  final yearOffsets = <int, double>{};
  double runningOffset = 0.0;
  for (final year in sortedYears) {
    yearOffsets[year] = runningOffset;
    runningOffset += yearHeaderHeight;
    runningOffset += (itemsByYear[year]?.length ?? 0) * (itemExtent ?? 88.0);
  }

  final firstYear = sortedYears.first;
  final currentYearNotifier = ValueNotifier<int>(firstYear);

  // Captured during layout — height of all slivers preceding our content.
  double precedingExtent = 0.0;

  // Measured during layout: the scroll offset where each later year's
  // inline divider starts. Row heights vary (grouped surfaces, multi-line
  // rows), so estimates drift; these are exact.
  final yearStarts = <int, double>{};

  // Height of headers pinned above the sticky year header (e.g. a
  // floating navigation and a sticky bar). Content under them is hidden,
  // so a year counts as reached when its divider slides under them. Only
  // observable once content has scrolled beneath them, hence the max.
  double topInset = 0.0;

  double startOf(int year) =>
      yearStarts[year] ?? precedingExtent + (yearOffsets[year] ?? 0.0);

  int resolveYear(double offset) {
    int resolved = firstYear;
    for (final year in sortedYears.skip(1)) {
      if (startOf(year) <= offset + topInset) {
        resolved = year;
      } else {
        break;
      }
    }
    return resolved;
  }

  void onScroll() {
    final resolved = resolveYear(scrollController.offset);
    if (resolved != currentYearNotifier.value) {
      currentYearNotifier.value = resolved;
    }
  }

  scrollController.addListener(onScroll);

  // Lands the year's rows right under the sticky header. The first year
  // has no inline divider; its rows start below the sticky header itself.
  double targetFor(int year) {
    final target = year == firstYear
        ? precedingExtent - yearHeaderHeight - topInset
        : startOf(year) - topInset;
    return target.clamp(0.0, scrollController.position.maxScrollExtent);
  }

  void jumpToYear(int selected) {
    final insetBefore = topInset;
    final target = targetFor(selected);
    final distance = (target - scrollController.offset).abs();

    // The pinned inset is only known once content has scrolled under it,
    // so a jump from the top may need one correction afterwards.
    void correct() {
      if (topInset == insetBefore || !scrollController.hasClients) return;
      scrollController.jumpTo(targetFor(selected));
    }

    if (500.0 < distance) {
      scrollController.jumpTo(target);
      WidgetsBinding.instance.addPostFrameCallback((_) => correct());
    } else {
      scrollController
          .animateTo(
            target,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          )
          .then((_) => correct());
    }
  }

  Future<void> onYearHeaderTap(BuildContext context, int currentYear) async {
    final selected = await showYearPickerBottomSheet(
      context: context,
      years: sortedYears,
      currentYear: currentYear,
    );
    if (selected == null || selected == currentYear) return;
    jumpToYear(selected);
  }

  final slivers = <Widget>[
    SliverLayoutBuilder(
      builder: (context, constraints) {
        if (topInset < constraints.overlap) topInset = constraints.overlap;
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    ),
    SliverPinnedHeader(
      child: _StickyYearHeader(
        currentYearNotifier: currentYearNotifier,
        onTap: onYearHeaderTap,
      ),
    ),
    // Capture preceding scroll extent (includes all slivers above + pinned header).
    SliverLayoutBuilder(
      builder: (context, constraints) {
        precedingExtent = constraints.precedingScrollExtent;
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    ),
  ];

  for (final year in sortedYears) {
    final items = itemsByYear[year]!;

    if (year != firstYear) {
      slivers
        ..add(
          SliverLayoutBuilder(
            builder: (context, constraints) {
              yearStarts[year] = constraints.precedingScrollExtent;
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
        )
        ..add(
          SliverToBoxAdapter(
            child: _InlineYearDivider(year: year, onTap: onYearHeaderTap),
          ),
        );
    }

    slivers.add(list(items));
  }

  return slivers;
}

/// Inline year divider that scrolls with content.
///
/// Tapping opens the year picker bottom sheet.
class _InlineYearDivider extends StatelessWidget {
  const _InlineYearDivider({required this.year, required this.onTap});

  final int year;
  final Future<void> Function(BuildContext, int) onTap;

  @override
  Widget build(BuildContext context) {
    return YearDivider(year: year, onTap: () => onTap(context, year));
  }
}

/// Pinned header widget that shows the current year and opens a picker.
class _StickyYearHeader extends StatelessWidget {
  const _StickyYearHeader({
    required this.currentYearNotifier,
    required this.onTap,
  });

  final ValueNotifier<int> currentYearNotifier;
  final Future<void> Function(BuildContext, int) onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: currentYearNotifier,
      builder: (context, year, _) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Material(
          color: colorScheme.surface,
          child: InkWell(
            onTap: () => onTap(context, year),
            child: SizedBox(
              height: yearHeaderHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    year == 0 ? 'Unknown' : '$year',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
