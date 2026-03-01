import '../../../common/database/app_database.dart';

/// Repository interface for chapter operations.
abstract class ChapterRepository {
  /// Returns chapters for an episode, ordered by startMs.
  Future<List<EpisodeChapter>> getByEpisodeId(int episodeId);

  /// Watches chapters for an episode, emitting updates on change.
  Stream<List<EpisodeChapter>> watchByEpisodeId(int episodeId);

  /// Upserts chapter records in a batch.
  Future<void> upsertChapters(List<EpisodeChaptersCompanion> companions);

  /// Deletes all chapters for an episode.
  ///
  /// Returns the number of deleted rows.
  Future<int> deleteByEpisodeId(int episodeId);
}
