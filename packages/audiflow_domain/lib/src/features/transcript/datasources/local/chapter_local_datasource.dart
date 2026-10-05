import 'package:isar_community/isar.dart';

import '../../models/chapter_source.dart';
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

  /// Replaces each episode's chapters with the given ones from [source].
  ///
  /// Episodes whose stored chapters come from a higher-priority source are
  /// left untouched, except stored JSON chapters whose file the episode no
  /// longer links according to [linkedJsonUrls] (episode id to its current
  /// JSON chapters URL; episodes missing from it keep the plain ranking).
  /// Returns the ids of episodes whose chapters were replaced. Each list must
  /// belong to the episode id it is keyed by.
  Future<Set<int>> replaceChapters(
    Map<int, List<EpisodeChapter>> chaptersByEpisode, {
    required ChapterSource source,
    Map<int, String?> linkedJsonUrls = const {},
  }) {
    return _isar.writeTxn(() async {
      final replaced = <int>{};
      for (final MapEntry(key: episodeId, value: chapters)
          in chaptersByEpisode.entries) {
        final stored = _isar.episodeChapters.filter().episodeIdEqualTo(
          episodeId,
        );
        final storedFirst = await stored.findFirst();
        if (storedFirst != null &&
            !_mayReplace(storedFirst, source, linkedJsonUrls)) {
          continue;
        }
        await stored.deleteAll();
        for (final chapter in chapters) {
          chapter.source = source;
        }
        await _isar.episodeChapters.putAll(chapters);
        replaced.add(episodeId);
      }
      return replaced;
    });
  }

  // JSON chapters outrank feed chapters only while the episode still links
  // the file they came from.
  static bool _mayReplace(
    EpisodeChapter storedFirst,
    ChapterSource source,
    Map<int, String?> linkedJsonUrls,
  ) {
    if (source.canReplace(storedFirst.source)) return true;
    if (storedFirst.source != ChapterSource.podcastChaptersJson) return false;
    if (!linkedJsonUrls.containsKey(storedFirst.episodeId)) return false;
    return linkedJsonUrls[storedFirst.episodeId] != storedFirst.sourceUrl;
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
