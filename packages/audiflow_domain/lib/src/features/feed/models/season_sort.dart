/// Fields by which seasons can be sorted.
enum SeasonSortField {
  /// Sort by season number.
  seasonNumber,

  /// Sort by newest episode date in season.
  newestEpisodeDate,

  /// Sort by playback progress (least complete first).
  progress,

  /// Sort alphabetically by display name.
  alphabetical,
}

/// Sort direction.
enum SortOrder { ascending, descending }

/// Specification for how to sort seasons.
sealed class SeasonSortSpec {
  const SeasonSortSpec();
}

/// Simple single-field sort.
final class SimpleSeasonSort extends SeasonSortSpec {
  const SimpleSeasonSort(this.field, this.order);

  final SeasonSortField field;
  final SortOrder order;
}

/// Composite sort with multiple rules and optional conditions.
final class CompositeSeasonSort extends SeasonSortSpec {
  const CompositeSeasonSort(this.rules);

  final List<SeasonSortRule> rules;
}

/// A single rule in a composite sort.
final class SeasonSortRule {
  const SeasonSortRule({
    required this.field,
    required this.order,
    this.condition,
  });

  final SeasonSortField field;
  final SortOrder order;

  /// Optional condition for when this rule applies.
  final SeasonSortCondition? condition;
}

/// Conditions for conditional sorting rules.
sealed class SeasonSortCondition {
  const SeasonSortCondition();
}

/// Condition: season sort key greater than value.
final class SortKeyGreaterThan extends SeasonSortCondition {
  const SortKeyGreaterThan(this.value);
  final int value;
}
