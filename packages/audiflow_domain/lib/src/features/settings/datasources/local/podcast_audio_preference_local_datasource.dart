import 'package:isar_community/isar.dart';

import '../../models/podcast_audio_preference.dart';

/// Local datasource for [PodcastAudioPreference] rows using Isar.
class PodcastAudioPreferenceLocalDatasource {
  PodcastAudioPreferenceLocalDatasource(this._isar);

  final Isar _isar;

  /// Returns the override row for [podcastId], or null when none exists.
  Future<PodcastAudioPreference?> get(int podcastId) {
    return _isar.podcastAudioPreferences.getByPodcastId(podcastId);
  }

  /// Creates or replaces the override row for [podcastId].
  Future<void> upsert(
    int podcastId, {
    required double speed,
    required bool skipSilence,
    required bool voiceBoost,
  }) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.podcastAudioPreferences.getByPodcastId(
        podcastId,
      );
      final pref =
          (existing ?? (PodcastAudioPreference()..podcastId = podcastId))
            ..speed = speed
            ..skipSilence = skipSilence
            ..voiceBoost = voiceBoost;
      await _isar.podcastAudioPreferences.put(pref);
    });
  }

  /// Deletes the override row for [podcastId], if any.
  Future<void> delete(int podcastId) async {
    await _isar.writeTxn(
      () => _isar.podcastAudioPreferences.deleteByPodcastId(podcastId),
    );
  }
}
