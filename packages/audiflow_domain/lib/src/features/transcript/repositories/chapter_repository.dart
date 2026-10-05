import '../models/chapter_source.dart';
import '../models/episode_chapter.dart';

/// Repository interface for chapter operations.
abstract class ChapterRepository {
  /// Returns chapters for an episode, ordered by startMs.
  Future<List<EpisodeChapter>> getByEpisodeId(int episodeId);

  /// Watches chapters for an episode, emitting updates on change.
  Stream<List<EpisodeChapter>> watchByEpisodeId(int episodeId);

  /// Upserts chapter records in a batch.
  Future<void> upsertChapters(List<EpisodeChapter> chapters);

  /// Replaces each episode's chapters with the given ones from [source],
  /// unless its stored chapters come from a higher-priority source.
  ///
  /// Stored JSON chapters lose that priority when [linkedJsonUrls] shows the
  /// episode no longer links their file. Returns the ids of episodes whose
  /// chapters were replaced.
  Future<Set<int>> replaceChapters(
    Map<int, List<EpisodeChapter>> chaptersByEpisode, {
    required ChapterSource source,
    Map<int, String?> linkedJsonUrls = const {},
  });

  /// Deletes all chapters for an episode.
  ///
  /// Returns the number of deleted rows.
  Future<int> deleteByEpisodeId(int episodeId);
}
