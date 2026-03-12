import 'package:audiflow_domain/audiflow_domain.dart'
    show
        SmartPlaylistGroup,
        SmartPlaylistSortField,
        SmartPlaylistSortRule,
        SortOrder;

import '../widgets/inline_group_card.dart' show YearFilteredInlineGroup;

/// Sorts groups using the playlist's [groupSort] rule and
/// the user's [sortOrder] toggle.
List<SmartPlaylistGroup> sortGroupsBySort(
  List<SmartPlaylistGroup> groups,
  SmartPlaylistSortRule? groupSort,
  SortOrder sortOrder,
) {
  final sorted = List<SmartPlaylistGroup>.from(groups);

  if (groupSort == null) {
    sorted.sort((a, b) {
      final cmp = a.sortKey.compareTo(b.sortKey);
      return sortOrder == SortOrder.ascending ? cmp : -cmp;
    });
    return sorted;
  }

  final invert = sortOrder != groupSort.order;

  sorted.sort((a, b) {
    final cmp = compareGroupsByField(a, b, groupSort.field);
    if (cmp != 0) {
      final directed = groupSort.order == SortOrder.ascending ? cmp : -cmp;
      return invert ? -directed : directed;
    }
    return 0;
  });
  return sorted;
}

int compareGroupsByField(
  SmartPlaylistGroup a,
  SmartPlaylistGroup b,
  SmartPlaylistSortField field,
) {
  return switch (field) {
    SmartPlaylistSortField.playlistNumber => a.sortKey.compareTo(b.sortKey),
    SmartPlaylistSortField.newestEpisodeDate => compareNullableDates(
      a.latestDate,
      b.latestDate,
    ),
    SmartPlaylistSortField.alphabetical => a.displayName.compareTo(
      b.displayName,
    ),
  };
}

int compareNullableDates(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return a.compareTo(b);
}

/// Sorts [YearFilteredInlineGroup] items within a year bucket.
///
/// Uses filtered metadata (latestDate) when available,
/// falling back to the underlying group's values.
void sortFilteredGroupsInPlace(
  List<YearFilteredInlineGroup> items,
  SmartPlaylistSortRule? groupSort,
  SortOrder sortOrder,
) {
  if (groupSort == null) {
    items.sort((a, b) {
      final cmp = a.group.sortKey.compareTo(b.group.sortKey);
      return sortOrder == SortOrder.ascending ? cmp : -cmp;
    });
    return;
  }

  final invert = sortOrder != groupSort.order;

  items.sort((a, b) {
    final cmp = _compareFilteredByField(a, b, groupSort.field);
    if (cmp != 0) {
      final directed = groupSort.order == SortOrder.ascending ? cmp : -cmp;
      return invert ? -directed : directed;
    }
    return 0;
  });
}

int _compareFilteredByField(
  YearFilteredInlineGroup a,
  YearFilteredInlineGroup b,
  SmartPlaylistSortField field,
) {
  return switch (field) {
    SmartPlaylistSortField.playlistNumber => a.group.sortKey.compareTo(
      b.group.sortKey,
    ),
    SmartPlaylistSortField.newestEpisodeDate => compareNullableDates(
      a.latestDate ?? a.group.latestDate,
      b.latestDate ?? b.group.latestDate,
    ),
    SmartPlaylistSortField.alphabetical => a.group.displayName.compareTo(
      b.group.displayName,
    ),
  };
}
