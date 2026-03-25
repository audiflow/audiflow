import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../player/services/audio_playback_controller.dart';
import '../../player/services/audio_player_service.dart';
import '../../queue/services/queue_service.dart';
import '../../settings/providers/settings_providers.dart';
import '../../settings/repositories/app_settings_repository.dart';

part 'voice_command_executor.freezed.dart';
part 'voice_command_executor.g.dart';

/// Result of applying a setting via [VoiceCommandExecutor.applySetting].
///
/// Carries [previousValue] so the caller can offer an undo action.
@freezed
sealed class SettingApplyResult with _$SettingApplyResult {
  const factory SettingApplyResult({
    required bool isSuccess,
    String? previousValue,
    String? errorMessage,
  }) = _SettingApplyResult;
}

/// Executes voice command actions against player and queue services.
@riverpod
VoiceCommandExecutor voiceCommandExecutor(Ref ref) {
  return VoiceCommandExecutor(
    audioController: ref.watch(audioPlayerControllerProvider.notifier),
    queueService: ref.watch(queueServiceProvider),
    settingsRepository: ref.watch(appSettingsRepositoryProvider),
  );
}

/// Executes voice command intents by delegating to
/// the appropriate domain services.
class VoiceCommandExecutor {
  VoiceCommandExecutor({
    required AudioPlaybackController audioController,
    required QueueService queueService,
    required AppSettingsRepository settingsRepository,
  }) : _audioController = audioController,
       _queueService = queueService,
       _settingsRepository = settingsRepository;

  final AudioPlaybackController _audioController;
  final QueueService _queueService;
  final AppSettingsRepository _settingsRepository;

  /// Resumes the current playback.
  Future<void> resume() async {
    await _audioController.resume();
  }

  /// Pauses the current playback.
  Future<void> pause() async {
    await _audioController.pause();
  }

  /// Stops the current playback.
  Future<void> stop() async {
    await _audioController.stop();
  }

  /// Skips forward by the user-configured duration.
  Future<void> skipForward() async {
    await _audioController.skipForward();
  }

  /// Skips backward by the user-configured duration.
  Future<void> skipBackward() async {
    await _audioController.skipBackward();
  }

  /// Seeks to an absolute position.
  Future<void> seek(Duration position) async {
    await _audioController.seek(position);
  }

  /// Clears the playback queue.
  Future<void> clearQueue() async {
    await _queueService.clearQueue();
  }

  /// Applies a setting change identified by [key] to [value].
  ///
  /// Reads the current value before applying so [SettingApplyResult.previousValue]
  /// is available for undo. For playback-affecting settings (e.g. playbackSpeed),
  /// both the repository and the audio controller are updated.
  ///
  /// Returns a failure result when [key] is unknown or [value] cannot be parsed.
  Future<SettingApplyResult> applySetting({
    required String key,
    required String value,
  }) async {
    final previous = _readCurrentValue(key);
    if (previous == null) {
      return SettingApplyResult(
        isSuccess: false,
        errorMessage: 'Unknown setting key: $key',
      );
    }

    try {
      await _applySettingValue(key, value);
      return SettingApplyResult(isSuccess: true, previousValue: previous);
    } catch (e) {
      return SettingApplyResult(
        isSuccess: false,
        previousValue: previous,
        errorMessage: 'Failed to apply setting "$key": $e',
      );
    }
  }

  /// Returns the current value of [key] as a string, or null for unknown keys.
  String? _readCurrentValue(String key) {
    return switch (key) {
      SettingsKeys.themeMode => _themeModeToString(
        _settingsRepository.getThemeMode(),
      ),
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
      SettingsKeys.autoPlayOrder => _settingsRepository.getAutoPlayOrder().name,
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
      _ => null,
    };
  }

  Future<void> _applySettingValue(String key, String value) async {
    switch (key) {
      case SettingsKeys.themeMode:
        await _settingsRepository.setThemeMode(_parseThemeMode(value));
      case SettingsKeys.locale:
        final locale = value == 'system' ? null : value;
        await _settingsRepository.setLocale(locale);
      case SettingsKeys.textScale:
        await _settingsRepository.setTextScale(double.parse(value));
      case SettingsKeys.playbackSpeed:
        final speed = double.parse(value);
        // setSpeed() persists to the repository AND updates the live player,
        // so a separate setPlaybackSpeed() call is unnecessary.
        await _audioController.setSpeed(speed);
      case SettingsKeys.skipForwardSeconds:
        await _settingsRepository.setSkipForwardSeconds(_safeParseInt(value));
      case SettingsKeys.skipBackwardSeconds:
        await _settingsRepository.setSkipBackwardSeconds(_safeParseInt(value));
      case SettingsKeys.autoCompleteThreshold:
        await _settingsRepository.setAutoCompleteThreshold(double.parse(value));
      case SettingsKeys.continuousPlayback:
        await _settingsRepository.setContinuousPlayback(_parseBool(value));
      case SettingsKeys.autoPlayOrder:
        await _settingsRepository.setAutoPlayOrder(_parseAutoPlayOrder(value));
      case SettingsKeys.wifiOnlyDownload:
        await _settingsRepository.setWifiOnlyDownload(_parseBool(value));
      case SettingsKeys.autoDeletePlayed:
        await _settingsRepository.setAutoDeletePlayed(_parseBool(value));
      case SettingsKeys.maxConcurrentDownloads:
        await _settingsRepository.setMaxConcurrentDownloads(
          _safeParseInt(value),
        );
      case SettingsKeys.autoSync:
        await _settingsRepository.setAutoSync(_parseBool(value));
      case SettingsKeys.syncIntervalMinutes:
        await _settingsRepository.setSyncIntervalMinutes(_safeParseInt(value));
      case SettingsKeys.wifiOnlySync:
        await _settingsRepository.setWifiOnlySync(_parseBool(value));
      case SettingsKeys.notifyNewEpisodes:
        await _settingsRepository.setNotifyNewEpisodes(_parseBool(value));
      case SettingsKeys.searchCountry:
        final country = value == 'system' ? null : value;
        await _settingsRepository.setSearchCountry(country);
      default:
        throw ArgumentError('Unknown setting key: $key');
    }
  }

  static String _themeModeToString(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
    };
  }

  static ThemeMode _parseThemeMode(String value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => throw ArgumentError('Invalid ThemeMode value: $value'),
    };
  }

  static AutoPlayOrder _parseAutoPlayOrder(String value) {
    return AutoPlayOrder.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Invalid AutoPlayOrder value: $value'),
    );
  }

  /// Parses an integer from a string that may contain decimals (e.g. "30.0").
  static int _safeParseInt(String value) => double.parse(value).toInt();

  static bool _parseBool(String value) {
    return switch (value) {
      'true' => true,
      'false' => false,
      _ => throw ArgumentError('Invalid boolean value: $value'),
    };
  }
}
