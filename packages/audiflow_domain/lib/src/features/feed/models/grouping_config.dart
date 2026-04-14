import 'numbering_extractor.dart';
import 'smart_playlist_group_def.dart';

/// Defines how episodes are organized into groups.
final class GroupingConfig {
  const GroupingConfig({
    required this.by,
    this.discoveryHint,
    this.numberingExtractor,
    this.staticClassifiers,
  });

  factory GroupingConfig.fromJson(Map<String, dynamic> json) {
    return GroupingConfig(
      by: json['by'] as String,
      discoveryHint: json['discoveryHint'] as String?,
      numberingExtractor: json['numberingExtractor'] != null
          ? NumberingExtractor.fromJson(
              json['numberingExtractor'] as Map<String, dynamic>,
            )
          : null,
      staticClassifiers: (json['staticClassifiers'] as List<dynamic>?)
          ?.map(
            (g) => SmartPlaylistGroupDef.fromJson(g as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  /// Grouping strategy: seasonNumber, year, titleDiscovery, titleClassifier.
  final String by;

  /// Regex pattern for titleDiscovery fallback.
  final String? discoveryHint;

  /// Parses season/episode numbers from titles.
  final NumberingExtractor? numberingExtractor;

  /// Group definitions for titleClassifier.
  final List<SmartPlaylistGroupDef>? staticClassifiers;

  Map<String, dynamic> toJson() {
    return {
      'by': by,
      if (discoveryHint != null) 'discoveryHint': discoveryHint,
      if (numberingExtractor != null)
        'numberingExtractor': numberingExtractor!.toJson(),
      if (staticClassifiers != null)
        'staticClassifiers': staticClassifiers!.map((g) => g.toJson()).toList(),
    };
  }
}
