/// A single filter condition matched against episode fields.
///
/// When multiple fields are specified, all must match (AND logic).
final class EpisodeFilterEntry {
  const EpisodeFilterEntry({this.title, this.description});

  factory EpisodeFilterEntry.fromJson(Map<String, dynamic> json) {
    return EpisodeFilterEntry(
      title: json['title'] as String?,
      description: json['description'] as String?,
    );
  }

  /// Case-insensitive regex pattern matched against the episode title.
  final String? title;

  /// Case-insensitive regex pattern matched against the episode
  /// description.
  final String? description;

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
    };
  }
}
