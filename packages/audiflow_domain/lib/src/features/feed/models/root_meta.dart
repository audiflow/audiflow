import 'dart:convert';

import 'pattern_summary.dart';

/// Root meta.json from the split config repository.
///
/// Contains schema version and pattern summaries for discovery.
final class RootMeta {
  const RootMeta({required this.version, required this.patterns});

  static const _supportedVersion = 2;

  factory RootMeta.fromJson(Map<String, dynamic> json) {
    return RootMeta(
      version: json['version'] as int,
      patterns: (json['patterns'] as List<dynamic>)
          .map((p) => PatternSummary.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Parses a JSON string into a [RootMeta].
  ///
  /// Throws [FormatException] if version is unsupported.
  static RootMeta parseJson(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final version = data['version'] as int?;
    if (version == null || version != _supportedVersion) {
      throw FormatException(
        'Unsupported root meta version: $version '
        '(supported: $_supportedVersion)',
      );
    }
    return RootMeta.fromJson(data);
  }

  /// Schema version of the root meta.
  final int version;

  /// Available pattern summaries for discovery.
  final List<PatternSummary> patterns;

  /// Converts to JSON representation.
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'patterns': patterns.map((p) => p.toJson()).toList(),
    };
  }
}
