import 'package:audiflow_domain/audiflow_domain.dart'
    show
        SmartPlaylistGroup,
        SmartPlaylistSortField,
        SmartPlaylistSortRule,
        SortOrder;

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
