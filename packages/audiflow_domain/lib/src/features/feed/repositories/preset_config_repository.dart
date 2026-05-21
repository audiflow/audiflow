import '../models/preset_config.dart';
import '../models/preset_summary.dart';
import '../models/root_meta.dart';

/// Repository for fetching and caching split preset configs.
abstract class PresetConfigRepository {
  /// Fetches root meta from remote, falls back to cache on
  /// error.
  Future<RootMeta> fetchRootMeta();

  /// Returns assembled config for a preset. Uses disk cache
  /// if version matches, otherwise fetches remotely.
  Future<PresetConfig> getConfig(PresetSummary summary);

  /// Finds matching preset summary for a podcast.
  ///
  /// Uses `feedUrlHint` for quick pre-filtering.
  PresetSummary? findMatchingPreset(String? podcastGuid, String feedUrl);

  /// Evicts stale presets based on version comparison.
  ///
  /// Removes cached presets not in [latest] and presets
  /// whose version has changed.
  Future<void> reconcileCache(List<PresetSummary> latest);

  /// Sets the current preset summaries for matching.
  void setPresetSummaries(List<PresetSummary> summaries);

  /// Deletes all disk-cached config files.
  Future<void> clearDiskCache();
}
