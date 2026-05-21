import 'dart:convert';

import 'preset_summary.dart';

/// Root meta.json from the split config repository.
///
/// Contains data version, schema version, and preset summaries
/// for discovery.
final class RootMeta {
  const RootMeta({
    required this.dataVersion,
    required this.schemaVersion,
    required this.presets,
  });

  factory RootMeta.fromJson(Map<String, dynamic> json) {
    return RootMeta(
      dataVersion: json['dataVersion'] as int,
      schemaVersion: json['schemaVersion'] as int,
      presets: (json['presets'] as List<dynamic>)
          .map((p) => PresetSummary.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Parses a JSON string into a [RootMeta].
  ///
  /// Throws [FormatException] if dataVersion field is missing.
  static RootMeta parseJson(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final dataVersion = data['dataVersion'] as int?;
    if (dataVersion == null) {
      throw const FormatException(
        'Missing required "dataVersion" field in root meta.json',
      );
    }
    return RootMeta.fromJson(data);
  }

  /// Data format version.
  final int dataVersion;

  /// Schema definition version.
  final int schemaVersion;

  /// Available preset summaries for discovery.
  final List<PresetSummary> presets;

  /// Converts to JSON representation.
  Map<String, dynamic> toJson() {
    return {
      'dataVersion': dataVersion,
      'schemaVersion': schemaVersion,
      'presets': presets.map((p) => p.toJson()).toList(),
    };
  }
}
