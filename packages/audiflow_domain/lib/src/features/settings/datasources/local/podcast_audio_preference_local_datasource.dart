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

  /// Creates or updates the override row for [podcastId].
  ///
  /// Only [speed] is written; the reserved columns of an existing row
  /// are kept as they are.
  Future<void> upsertSpeed(int podcastId, double speed) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.podcastAudioPreferences.getByPodcastId(
        podcastId,
      );
      final pref =
          existing ?? (PodcastAudioPreference()..podcastId = podcastId);
      pref.speed = speed;
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
