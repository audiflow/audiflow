import 'dart:convert';

/// Preset-level meta.json from the split config repository.
///
/// Contains feed matching rules and ordered playlist IDs.
final class PresetMeta {
  const PresetMeta({
    required this.dataVersion,
    required this.id,
    this.podcastGuid,
    required this.feedUrls,
    this.yearGroupedEpisodes = false,
    this.showEpisodeThumbnail,
    required this.playlists,
  });

  factory PresetMeta.fromJson(Map<String, dynamic> json) {
    return PresetMeta(
      dataVersion: (json['dataVersion'] as int?) ?? 1,
      id: json['id'] as String,
      podcastGuid: json['podcastGuid'] as String?,
      feedUrls: (json['feedUrls'] as List<dynamic>).cast<String>(),
      yearGroupedEpisodes: (json['yearGroupedEpisodes'] as bool?) ?? false,
      showEpisodeThumbnail: json['showEpisodeThumbnail'] as bool?,
      playlists: (json['playlists'] as List<dynamic>).cast<String>(),
    );
  }

  /// Parses a JSON string into a [PresetMeta].
  static PresetMeta parseJson(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    return PresetMeta.fromJson(data);
  }

  /// Data format version for this preset.
  final int dataVersion;

  /// Unique identifier for this preset.
  final String id;

  /// Optional podcast GUID for direct matching.
  final String? podcastGuid;

  /// Exact feed URLs for matching.
  final List<String> feedUrls;

  /// Whether episodes should be grouped by year.
  final bool yearGroupedEpisodes;

  /// Whether the main podcast episode list shows per-episode thumbnails.
  /// Tri-state: `null` means unset (defaults to `true` per schema).
  final bool? showEpisodeThumbnail;

  /// Ordered list of playlist IDs. Each corresponds to
  /// `playlists/{id}.json` in the preset directory.
  final List<String> playlists;

  /// Converts to JSON representation.
  Map<String, dynamic> toJson() {
    return {
      'dataVersion': dataVersion,
      'id': id,
      if (podcastGuid != null) 'podcastGuid': podcastGuid,
      'feedUrls': feedUrls,
      if (yearGroupedEpisodes) 'yearGroupedEpisodes': yearGroupedEpisodes,
      if (showEpisodeThumbnail != null)
        'showEpisodeThumbnail': showEpisodeThumbnail,
      'playlists': playlists,
    };
  }
}
