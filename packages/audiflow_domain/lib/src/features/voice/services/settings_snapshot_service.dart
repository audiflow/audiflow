import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter/material.dart';

import '../../settings/repositories/app_settings_repository.dart';
import '../models/settings_metadata.dart';
import 'settings_metadata_registry.dart';

/// Builds a prompt-ready text snapshot of all voice-controllable settings
/// with their current values and constraints.
///
/// Intended for injection into AI prompts so the model has full context on
/// what settings exist, what values are currently set, and what values are
/// valid.
class SettingsSnapshotService {
  const SettingsSnapshotService({
    required SettingsMetadataRegistry registry,
    required AppSettingsRepository settingsRepository,
  }) : _registry = registry,
       _settingsRepository = settingsRepository;

  final SettingsMetadataRegistry _registry;
  final AppSettingsRepository _settingsRepository;

  /// Generates a prompt-ready text block listing every registered setting,
  /// its current value, valid constraints, and voice synonyms.
  String buildPromptSnapshot() {
    final buffer = StringBuffer();
    for (final metadata in _registry.allSettings) {
      final value = getCurrentValue(metadata.key);
      final constraint = _describeConstraint(metadata.constraints);
      final synonymList = metadata.synonyms.join(', ');
      buffer.writeln(
        '- ${metadata.key}: $value $constraint [synonyms: $synonymList]',
      );
    }
    return buffer.toString();
  }

  /// Returns the current value of the setting identified by [key] as a
  /// human-readable string.
  ///
  /// Returns an empty string if [key] is not a registered voice-controllable
  /// setting.
  String getCurrentValue(String key) {
    return switch (key) {
      SettingsKeys.themeMode => _themeModeValue(),
      SettingsKeys.locale => _settingsRepository.getLocale() ?? 'system',
      SettingsKeys.textScale => _settingsRepository.getTextScale().toString(),
      SettingsKeys.playbackSpeed =>
        _settingsRepository.getPlaybackSpeed().toString(),
      SettingsKeys.skipForwardSeconds =>
        _settingsRepository.getSkipForwardSeconds().toString(),
      SettingsKeys.skipBackwardSeconds =>
        _settingsRepository.getSkipBackwardSeconds().toString(),
      SettingsKeys.autoCompleteThreshold =>
        _settingsRepository.getAutoCompleteThreshold().toString(),
      SettingsKeys.continuousPlayback =>
        _settingsRepository.getContinuousPlayback().toString(),
      SettingsKeys.autoPlayOrder => _autoPlayOrderValue(),
      SettingsKeys.wifiOnlyDownload =>
        _settingsRepository.getWifiOnlyDownload().toString(),
      SettingsKeys.autoDeletePlayed =>
        _settingsRepository.getAutoDeletePlayed().toString(),
      SettingsKeys.maxConcurrentDownloads =>
        _settingsRepository.getMaxConcurrentDownloads().toString(),
      SettingsKeys.autoSync => _settingsRepository.getAutoSync().toString(),
      SettingsKeys.syncIntervalMinutes =>
        _settingsRepository.getSyncIntervalMinutes().toString(),
      SettingsKeys.wifiOnlySync =>
        _settingsRepository.getWifiOnlySync().toString(),
      SettingsKeys.notifyNewEpisodes =>
        _settingsRepository.getNotifyNewEpisodes().toString(),
      SettingsKeys.searchCountry =>
        _settingsRepository.getSearchCountry() ?? 'system',
      _ => '',
    };
  }

  String _themeModeValue() {
    final mode = _settingsRepository.getThemeMode();
    return switch (mode) {
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
    };
  }

  String _autoPlayOrderValue() => _settingsRepository.getAutoPlayOrder().name;

  String _describeConstraint(SettingConstraints constraints) {
    return switch (constraints) {
      BooleanConstraints() => '(boolean)',
      RangeConstraints(:final min, :final max, :final step) =>
        '(range: $min-$max, step: $step)',
      OptionsConstraints(:final values) => '(options: ${values.join(', ')})',
    };
  }
}
