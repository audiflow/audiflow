import 'dart:convert';

import '../models/preset_config.dart';

/// Parses preset JSON into typed models.
///
/// Pure function with no Flutter dependency. The JSON source
/// can be a bundled asset or a server response.
final class PresetLoader {
  PresetLoader._();

  /// Parses a JSON string into a list of preset configs.
  static List<PresetConfig> parse(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final presets = data['presets'] as List<dynamic>;
    return presets
        .map((p) => PresetConfig.fromJson(p as Map<String, dynamic>))
        .toList();
  }
}
