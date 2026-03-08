import 'package:audiflow_domain/audiflow_domain.dart'
    show
        SmartPlaylistGroup,
        SmartPlaylistSortCondition,
        SmartPlaylistSortField,
        SmartPlaylistSortSpec,
        SortKeyGreaterThan,
        SortOrder;

/// Sorts groups using the playlist's [customSort] rules and
/// the user's [sortOrder] toggle.
List<SmartPlaylistGroup> sortGroupsByCustomSort(
  List<SmartPlaylistGroup> groups,
  SmartPlaylistSortSpec? customSort,
  SortOrder sortOrder,
) {
  final sorted = List<SmartPlaylistGroup>.from(groups);

  if (customSort == null || customSort.rules.isEmpty) {
    sorted.sort((a, b) {
      final cmp = a.sortKey.compareTo(b.sortKey);
      return sortOrder == SortOrder.ascending ? cmp : -cmp;
    });
    return sorted;
  }

  // When sortOrder matches the first rule's order, use rules as written.
  // Otherwise invert.
  final invert = sortOrder != customSort.rules.first.order;

  sorted.sort((a, b) {
    for (final rule in customSort.rules) {
      if (rule.condition != null) {
        final bothMatch =
            matchesGroupCondition(a, rule.condition!) &&
            matchesGroupCondition(b, rule.condition!);
        if (!bothMatch) continue;
      }

      final cmp = compareGroupsByField(a, b, rule.field);
      if (cmp != 0) {
        final directed = rule.order == SortOrder.ascending ? cmp : -cmp;
        return invert ? -directed : directed;
      }
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
    SmartPlaylistSortField.progress => a.sortKey.compareTo(b.sortKey),
  };
}

int compareNullableDates(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return a.compareTo(b);
}

bool matchesGroupCondition(
  SmartPlaylistGroup group,
  SmartPlaylistSortCondition condition,
) {
  return switch (condition) {
    SortKeyGreaterThan(:final value) => value < group.sortKey,
  };
}
