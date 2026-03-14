import 'package:isar_community/isar.dart';

import '../../models/podcast_view_preference.dart';

/// Local datasource for podcast view preferences using Isar.
class PodcastViewPreferenceLocalDatasource {
  PodcastViewPreferenceLocalDatasource(this._isar);

  final Isar _isar;

  /// Gets preference for a podcast, returns null if not set.
  Future<PodcastViewPreference?> getPreference(int podcastId) {
    return _isar.podcastViewPreferences.getByPodcastId(podcastId);
  }

  /// Watches preference for a podcast (emits null if not set).
  Stream<PodcastViewPreference?> watchPreference(int podcastId) {
    return _isar.podcastViewPreferences
        .filter()
        .podcastIdEqualTo(podcastId)
        .watch(fireImmediately: true)
        .map((list) => list.isEmpty ? null : list.first);
  }

  /// Upserts preference (insert or update on conflict).
  Future<void> upsertPreference(PodcastViewPreference pref) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.podcastViewPreferences.getByPodcastId(
        pref.podcastId,
      );
      if (existing != null) {
        pref.id = existing.id;
      }
      await _isar.podcastViewPreferences.put(pref);
    });
  }

  /// Deletes preference for a podcast.
  Future<int> deletePreference(int podcastId) {
    return _isar.writeTxn(
      () => _isar.podcastViewPreferences
          .filter()
          .podcastIdEqualTo(podcastId)
          .deleteAll(),
    );
  }
}
