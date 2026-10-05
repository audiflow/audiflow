import 'package:audiflow_core/audiflow_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
import '../datasources/local/podcast_audio_preference_local_datasource.dart';
import '../models/audio_settings.dart';
import '../providers/settings_providers.dart';
import 'app_settings_repository.dart';

part 'podcast_audio_preference_repository.g.dart';

/// Repository for per-podcast audio settings overrides with
/// podcast -> global resolution.
abstract interface class PodcastAudioPreferenceRepository {
  /// Returns the override for [podcastId], or null when it has none.
  Future<AudioSettings?> get(int podcastId);

  /// Creates or replaces the override for [podcastId].
  Future<void> set(int podcastId, AudioSettings settings);

  /// Removes the override for [podcastId] so it follows the global
  /// settings again.
  Future<void> clear(int podcastId);

  /// Resolves the effective settings: podcast override -> global.
  Future<AudioSettings> resolveForPodcast(int podcastId);
}

/// Implementation of [PodcastAudioPreferenceRepository].
class PodcastAudioPreferenceRepositoryImpl
    implements PodcastAudioPreferenceRepository {
  PodcastAudioPreferenceRepositoryImpl(this._datasource, this._settings);

  final PodcastAudioPreferenceLocalDatasource _datasource;
  final AppSettingsRepository _settings;

  @override
  Future<AudioSettings?> get(int podcastId) async {
    final row = await _datasource.get(podcastId);
    if (row == null) return null;
    return AudioSettings(speed: PlaybackSpeedScale.snap(row.speed));
  }

  @override
  Future<void> set(int podcastId, AudioSettings settings) {
    return _datasource.upsertSpeed(
      podcastId,
      PlaybackSpeedScale.snap(settings.speed),
    );
  }

  @override
  Future<void> clear(int podcastId) => _datasource.delete(podcastId);

  @override
  Future<AudioSettings> resolveForPodcast(int podcastId) async {
    final override = await get(podcastId);
    return override ?? AudioSettings(speed: _settings.getPlaybackSpeed());
  }
}

/// Provider for [PodcastAudioPreferenceLocalDatasource].
@Riverpod(keepAlive: true)
PodcastAudioPreferenceLocalDatasource podcastAudioPreferenceLocalDatasource(
  Ref ref,
) {
  final isar = ref.watch(isarProvider);
  return PodcastAudioPreferenceLocalDatasource(isar);
}

/// Provider for [PodcastAudioPreferenceRepository].
@Riverpod(keepAlive: true)
PodcastAudioPreferenceRepository podcastAudioPreferenceRepository(Ref ref) {
  final datasource = ref.watch(podcastAudioPreferenceLocalDatasourceProvider);
  final settings = ref.watch(appSettingsRepositoryProvider);
  return PodcastAudioPreferenceRepositoryImpl(datasource, settings);
}
