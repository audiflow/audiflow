import 'package:audiflow_domain/presets.dart';

/// Registry of all available presets.
///
/// Presets are loaded from JSON configuration via [PresetLoader].
class PresetRegistry {
  /// Creates a registry with optional pre-loaded presets.
  PresetRegistry([List<PresetConfig>? presets]) : _presets = presets ?? [];

  /// Creates a registry from a JSON string.
  factory PresetRegistry.fromJson(String jsonString) {
    final presets = PresetLoader.parse(jsonString);
    return PresetRegistry(presets);
  }

  final List<PresetConfig> _presets;

  /// All registered preset configs.
  List<PresetConfig> get presets => _presets;

  /// Finds a preset config by its ID.
  PresetConfig? findById(String id) {
    for (final preset in presets) {
      if (preset.id == id) {
        return preset;
      }
    }
    return null;
  }

  /// Detects a preset config from a feed URL.
  PresetConfig? detectFromUrl(String feedUrl) {
    for (final preset in presets) {
      if (preset.matchesPodcast(null, feedUrl)) {
        return preset;
      }
    }
    return null;
  }

  /// Lists all preset configs with their metadata.
  List<PresetConfig> listPresets() => presets;
}
