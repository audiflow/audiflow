import 'package:isar_community/isar.dart';

import '../../models/episode_chapter.dart';

/// Local datasource for chapter CRUD operations using Isar.
///
/// Provides read, upsert, delete, and watch operations for the
/// EpisodeChapter collection.
class ChapterLocalDatasource {
  ChapterLocalDatasource(this._isar);

  final Isar _isar;

  /// Returns chapters for an episode, ordered by startMs.
  Future<List<EpisodeChapter>> getByEpisodeId(int episodeId) {
    return _isar.episodeChapters
        .filter()
        .episodeIdEqualTo(episodeId)
        .sortByStartMs()
        .findAll();
  }

  /// Watches chapters for an episode, ordered by startMs.
  Stream<List<EpisodeChapter>> watchByEpisodeId(int episodeId) {
    return _isar.episodeChapters
        .filter()
        .episodeIdEqualTo(episodeId)
        .sortByStartMs()
        .watch(fireImmediately: true);
  }

  /// Upserts chapter records in a batch.
  ///
  /// Inserts new chapters or updates existing ones on conflict
  /// (matching episodeId + sortOrder unique key).
  Future<void> upsertChapters(List<EpisodeChapter> chapters) async {
    await _isar.writeTxn(() async {
      for (final chapter in chapters) {
        final existing = await _isar.episodeChapters.getByEpisodeIdSortOrder(
          chapter.episodeId,
          chapter.sortOrder,
        );
        if (existing != null) {
          chapter.id = existing.id;
        }
      }
      await _isar.episodeChapters.putAll(chapters);
    });
  }

  /// Deletes all chapters for an episode.
  ///
  /// Returns the number of deleted rows.
  Future<int> deleteByEpisodeId(int episodeId) {
    return _isar.writeTxn(
      () => _isar.episodeChapters
          .filter()
          .episodeIdEqualTo(episodeId)
          .deleteAll(),
    );
  }
}
