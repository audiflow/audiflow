import '../../../../common/database/app_database.dart';

/// Local datasource for podcast view preferences using Drift.
class PodcastViewPreferenceLocalDatasource {
  PodcastViewPreferenceLocalDatasource(this._db);

  final AppDatabase _db;

  /// Gets preference for a podcast, returns null if not set.
  Future<PodcastViewPreference?> getPreference(int podcastId) {
    return (_db.select(
      _db.podcastViewPreferences,
    )..where((p) => p.podcastId.equals(podcastId))).getSingleOrNull();
  }

  /// Watches preference for a podcast (emits null if not set).
  Stream<PodcastViewPreference?> watchPreference(int podcastId) {
    return (_db.select(
      _db.podcastViewPreferences,
    )..where((p) => p.podcastId.equals(podcastId))).watchSingleOrNull();
  }

  /// Upserts preference (insert or update on conflict).
  Future<void> upsertPreference(PodcastViewPreferencesCompanion companion) {
    return _db
        .into(_db.podcastViewPreferences)
        .insertOnConflictUpdate(companion);
  }

  /// Deletes preference for a podcast.
  Future<int> deletePreference(int podcastId) {
    return (_db.delete(
      _db.podcastViewPreferences,
    )..where((p) => p.podcastId.equals(podcastId))).go();
  }
}
