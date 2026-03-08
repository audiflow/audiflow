import 'smart_playlist_sort.dart';

/// Fields by which episodes can be sorted within a group.
enum EpisodeSortField {
  /// Sort by episode publication date.
  publishedAt,

  /// Sort by episode number.
  episodeNumber,

  /// Sort alphabetically by episode title.
  title,
}

/// Sort rule for ordering episodes within a group or playlist.
final class EpisodeSortRule {
  const EpisodeSortRule({required this.field, required this.order});

  factory EpisodeSortRule.fromJson(Map<String, dynamic> json) {
    return EpisodeSortRule(
      field: EpisodeSortField.values.byName(json['field'] as String),
      order: SortOrder.values.byName(json['order'] as String),
    );
  }

  final EpisodeSortField field;
  final SortOrder order;

  Map<String, dynamic> toJson() => {'field': field.name, 'order': order.name};
}
