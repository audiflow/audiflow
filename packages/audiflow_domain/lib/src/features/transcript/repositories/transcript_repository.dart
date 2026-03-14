import '../models/episode_transcript.dart';
import '../models/transcript_segment_table.dart';

/// Repository interface for transcript operations.
abstract class TranscriptRepository {
  /// Returns transcript metadata for an episode.
  Future<List<EpisodeTranscript>> getMetasByEpisodeId(int episodeId);

  /// Returns all segments for a transcript, ordered by startMs.
  Future<List<TranscriptSegment>> getAllSegments(int transcriptId);

  /// Returns segments overlapping the given time range.
  Future<List<TranscriptSegment>> getSegments(
    int transcriptId, {
    required int startMs,
    required int endMs,
  });

  /// Upserts transcript metadata records.
  Future<void> upsertMetas(List<EpisodeTranscript> metas);

  /// Bulk inserts transcript segments.
  Future<void> insertSegments(List<TranscriptSegment> segments);

  /// Marks a transcript as fetched.
  Future<void> markAsFetched(int transcriptId);

  /// Whether transcript content has been fetched.
  Future<bool> isContentFetched(int transcriptId);

  /// Deletes all segments for a transcript.
  Future<int> deleteSegments(int transcriptId);
}
