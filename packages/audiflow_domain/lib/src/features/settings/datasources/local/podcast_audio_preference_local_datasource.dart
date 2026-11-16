import 'package:isar_community/isar.dart';

import '../../../user_state/models/podcast_user_state.dart';
import '../../../user_state/services/podcast_user_state_access.dart';
import '../../../user_state/services/user_state_store.dart';
import '../../models/podcast_audio_preference.dart';

/// Local datasource for per-podcast audio overrides.
///
/// The override lives in [PodcastUserState]; see [PodcastUserStateAccess].
class PodcastAudioPreferenceLocalDatasource {
  PodcastAudioPreferenceLocalDatasource(this._isar);

  final Isar _isar;

  /// User state writes go through the store; see [UserStateStore].
  late final _store = UserStateStore(_isar);
  late final _access = PodcastUserStateAccess(_isar);

  /// Returns the override for [podcastId], or null when none exists.
  Future<PodcastAudioPreference?> get(int podcastId) {
    return _access.audio(podcastId);
  }

  /// Creates or replaces the override for [podcastId].
  Future<void> upsert(
    int podcastId, {
    required double speed,
    required bool skipSilence,
    required bool voiceBoost,
  }) async {
    await _store.write((txn) async {
      final pref =
          (await _access.audio(podcastId) ??
                (PodcastAudioPreference()..podcastId = podcastId))
            ..speed = speed
            ..skipSilence = skipSilence
            ..voiceBoost = voiceBoost;
      await _access.saveAudio(podcastId, pref, txn);
    });
  }

  /// Removes the override for [podcastId], if any.
  Future<void> delete(int podcastId) async {
    await _store.write((txn) => _access.saveAudio(podcastId, null, txn));
  }
}
