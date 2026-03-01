import 'package:drift/drift.dart';

import '../../../../common/database/app_database.dart';
import '../../models/transcript_search_result.dart';

/// Local datasource for transcript CRUD operations using Drift.
///
/// Handles both transcript metadata (EpisodeTranscripts) and
/// transcript content (TranscriptSegments) tables.
class TranscriptLocalDatasource {
  TranscriptLocalDatasource(this._db);

  final AppDatabase _db;

  /// Returns transcript metadata for an episode.
  Future<List<EpisodeTranscript>> getMetasByEpisodeId(int episodeId) {
    return (_db.select(
      _db.episodeTranscripts,
    )..where((t) => t.episodeId.equals(episodeId))).get();
  }

  /// Upserts transcript metadata records.
  ///
  /// On conflict (same episodeId + url), updates the existing row.
  Future<void> upsertMetas(List<EpisodeTranscriptsCompanion> companions) async {
    await _db.batch((batch) {
      for (final companion in companions) {
        batch.insert(
          _db.episodeTranscripts,
          companion,
          onConflict: DoUpdate(
            (old) => companion,
            target: [
              _db.episodeTranscripts.episodeId,
              _db.episodeTranscripts.url,
            ],
          ),
        );
      }
    });
  }

  /// Bulk inserts transcript segments.
  Future<void> insertSegments(
    List<TranscriptSegmentsCompanion> segments,
  ) async {
    await _db.batch((batch) {
      batch.insertAll(_db.transcriptSegments, segments);
    });
  }

  /// Returns all segments for a transcript, ordered by startMs.
  Future<List<TranscriptSegment>> getAllSegments(int transcriptId) {
    return (_db.select(_db.transcriptSegments)
          ..where((s) => s.transcriptId.equals(transcriptId))
          ..orderBy([(s) => OrderingTerm.asc(s.startMs)]))
        .get();
  }

  /// Returns segments overlapping the given time range.
  ///
  /// A segment overlaps [startMs, endMs) when its start is before
  /// [endMs] and its end is after [startMs].
  Future<List<TranscriptSegment>> getSegments(
    int transcriptId, {
    required int startMs,
    required int endMs,
  }) {
    return (_db.select(_db.transcriptSegments)
          ..where(
            (s) =>
                s.transcriptId.equals(transcriptId) &
                s.startMs.isSmallerThanValue(endMs) &
                s.endMs.isBiggerThanValue(startMs),
          )
          ..orderBy([(s) => OrderingTerm.asc(s.startMs)]))
        .get();
  }

  /// Marks a transcript as fetched by setting fetchedAt.
  Future<void> markAsFetched(int transcriptId) {
    return (_db.update(_db.episodeTranscripts)
          ..where((t) => t.id.equals(transcriptId)))
        .write(EpisodeTranscriptsCompanion(fetchedAt: Value(DateTime.now())));
  }

  /// Whether transcript content has been fetched.
  Future<bool> isContentFetched(int transcriptId) async {
    final result = await (_db.select(
      _db.episodeTranscripts,
    )..where((t) => t.id.equals(transcriptId))).getSingleOrNull();
    return result?.fetchedAt != null;
  }

  /// Deletes all segments for a transcript.
  Future<int> deleteSegments(int transcriptId) {
    return (_db.delete(
      _db.transcriptSegments,
    )..where((s) => s.transcriptId.equals(transcriptId))).go();
  }

  /// Searches transcript segments using FTS5.
  ///
  /// Returns up to 50 results ranked by relevance.
  /// Returns an empty list when [query] is blank.
  Future<List<TranscriptSearchResult>> search(String query) async {
    if (query.trim().isEmpty) return [];

    final results = await _db
        .customSelect(
          '''
          SELECT ts.id, ts.transcript_id, ts.start_ms, ts.end_ms,
                 ts.body, ts.speaker, et.episode_id
          FROM transcript_segments_fts fts
          JOIN transcript_segments ts ON fts.rowid = ts.id
          JOIN episode_transcripts et ON ts.transcript_id = et.id
          WHERE fts.body MATCH ?
          ORDER BY rank
          LIMIT 50
          ''',
          variables: [Variable.withString(query)],
        )
        .get();

    return results
        .map(
          (row) => TranscriptSearchResult(
            segmentId: row.read<int>('id'),
            transcriptId: row.read<int>('transcript_id'),
            episodeId: row.read<int>('episode_id'),
            startMs: row.read<int>('start_ms'),
            endMs: row.read<int>('end_ms'),
            body: row.read<String>('body'),
            speaker: row.readNullable<String>('speaker'),
          ),
        )
        .toList();
  }
}
