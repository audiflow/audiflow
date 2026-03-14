import 'package:isar_community/isar.dart';

import '../../models/episode_transcript.dart';
import '../../models/transcript_search_result.dart';
import '../../models/transcript_segment_table.dart';

/// Local datasource for transcript CRUD operations using Isar.
///
/// Handles both transcript metadata (EpisodeTranscript) and
/// transcript content (TranscriptSegment) collections.
class TranscriptLocalDatasource {
  TranscriptLocalDatasource(this._isar);

  final Isar _isar;

  /// Returns transcript metadata for an episode.
  Future<List<EpisodeTranscript>> getMetasByEpisodeId(int episodeId) {
    return _isar.episodeTranscripts
        .filter()
        .episodeIdEqualTo(episodeId)
        .findAll();
  }

  /// Upserts transcript metadata records.
  ///
  /// On conflict (same episodeId + url), updates the existing row.
  Future<void> upsertMetas(List<EpisodeTranscript> metas) async {
    await _isar.writeTxn(() async {
      for (final meta in metas) {
        final existing = await _isar.episodeTranscripts.getByEpisodeIdUrl(
          meta.episodeId,
          meta.url,
        );
        if (existing != null) {
          meta.id = existing.id;
        }
      }
      await _isar.episodeTranscripts.putAll(metas);
    });
  }

  /// Bulk inserts transcript segments.
  Future<void> insertSegments(List<TranscriptSegment> segments) async {
    await _isar.writeTxn(() => _isar.transcriptSegments.putAll(segments));
  }

  /// Returns all segments for a transcript, ordered by startMs.
  Future<List<TranscriptSegment>> getAllSegments(int transcriptId) {
    return _isar.transcriptSegments
        .filter()
        .transcriptIdEqualTo(transcriptId)
        .sortByStartMs()
        .findAll();
  }

  /// Returns segments overlapping the given time range.
  ///
  /// A segment overlaps [startMs, endMs) when its start is before
  /// [endMs] and its end is after [startMs].
  /// Rewritten: segment.startMs < endMs AND startMs < segment.endMs
  Future<List<TranscriptSegment>> getSegments(
    int transcriptId, {
    required int startMs,
    required int endMs,
  }) {
    return _isar.transcriptSegments
        .filter()
        .transcriptIdEqualTo(transcriptId)
        .and()
        .startMsLessThan(endMs)
        .and()
        .endMsGreaterThan(startMs)
        .sortByStartMs()
        .findAll();
  }

  /// Marks a transcript as fetched by setting fetchedAt.
  Future<void> markAsFetched(int transcriptId) async {
    final transcript = await _isar.episodeTranscripts.get(transcriptId);
    if (transcript == null) return;

    transcript.fetchedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.episodeTranscripts.put(transcript));
  }

  /// Whether transcript content has been fetched.
  Future<bool> isContentFetched(int transcriptId) async {
    final result = await _isar.episodeTranscripts.get(transcriptId);
    return result?.fetchedAt != null;
  }

  /// Deletes all segments for a transcript.
  Future<int> deleteSegments(int transcriptId) {
    return _isar.writeTxn(
      () => _isar.transcriptSegments
          .filter()
          .transcriptIdEqualTo(transcriptId)
          .deleteAll(),
    );
  }

  /// Searches transcript segments using case-insensitive string matching.
  ///
  /// Returns up to 50 results.
  /// Returns an empty list when [query] is blank.
  Future<List<TranscriptSearchResult>> search(String query) async {
    if (query.trim().isEmpty) return [];

    final segments = await _isar.transcriptSegments
        .filter()
        .bodyContains(query, caseSensitive: false)
        .limit(50)
        .findAll();

    final results = <TranscriptSearchResult>[];
    for (final segment in segments) {
      // Look up the transcript to get episodeId
      final transcript = await _isar.episodeTranscripts.get(
        segment.transcriptId,
      );
      if (transcript == null) continue;

      results.add(
        TranscriptSearchResult(
          segmentId: segment.id,
          transcriptId: segment.transcriptId,
          episodeId: transcript.episodeId,
          startMs: segment.startMs,
          endMs: segment.endMs,
          body: segment.body,
          speaker: segment.speaker,
        ),
      );
    }
    return results;
  }
}
