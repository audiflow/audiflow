/// Fields by which smart playlists can be sorted.
enum SmartPlaylistSortField {
  /// Sort by playlist number.
  playlistNumber,

  /// Sort by newest episode date in smart playlist.
  newestEpisodeDate,

  /// Sort alphabetically by display name.
  alphabetical,
}

/// Sort direction.
enum SortOrder { ascending, descending }

/// A single sort rule for ordering smart playlists.
final class SmartPlaylistSortRule {
  const SmartPlaylistSortRule({required this.field, required this.order});

  /// Deserializes from JSON.
  factory SmartPlaylistSortRule.fromJson(Map<String, dynamic> json) {
    return SmartPlaylistSortRule(
      field: SmartPlaylistSortField.values.byName(json['field'] as String),
      order: SortOrder.values.byName(json['order'] as String),
    );
  }

  /// Sort field.
  final SmartPlaylistSortField field;

  /// Sort direction.
  final SortOrder order;

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => {'field': field.name, 'order': order.name};
}
