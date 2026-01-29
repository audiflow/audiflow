/// Fields by which smart playlists can be sorted.
enum SmartPlaylistSortField {
  /// Sort by playlist number.
  playlistNumber,

  /// Sort by newest episode date in smart playlist.
  newestEpisodeDate,

  /// Sort by playback progress (least complete first).
  progress,

  /// Sort alphabetically by display name.
  alphabetical,
}

/// Sort direction.
enum SortOrder { ascending, descending }

/// Specification for how to sort smart playlists.
sealed class SmartPlaylistSortSpec {
  const SmartPlaylistSortSpec();
}

/// Simple single-field sort.
final class SimpleSmartPlaylistSort extends SmartPlaylistSortSpec {
  const SimpleSmartPlaylistSort(this.field, this.order);

  final SmartPlaylistSortField field;
  final SortOrder order;
}

/// Composite sort with multiple rules and optional conditions.
final class CompositeSmartPlaylistSort extends SmartPlaylistSortSpec {
  const CompositeSmartPlaylistSort(this.rules);

  final List<SmartPlaylistSortRule> rules;
}

/// A single rule in a composite sort.
final class SmartPlaylistSortRule {
  const SmartPlaylistSortRule({
    required this.field,
    required this.order,
    this.condition,
  });

  final SmartPlaylistSortField field;
  final SortOrder order;

  /// Optional condition for when this rule applies.
  final SmartPlaylistSortCondition? condition;
}

/// Conditions for conditional sorting rules.
sealed class SmartPlaylistSortCondition {
  const SmartPlaylistSortCondition();
}

/// Condition: smart playlist sort key greater than value.
final class SortKeyGreaterThan extends SmartPlaylistSortCondition {
  const SortKeyGreaterThan(this.value);
  final int value;
}
