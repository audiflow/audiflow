/// A search result from transcript FTS5 search.
class TranscriptSearchResult {
  const TranscriptSearchResult({
    required this.segmentId,
    required this.transcriptId,
    required this.episodeId,
    required this.startMs,
    required this.endMs,
    required this.body,
    this.speaker,
  });

  final int segmentId;
  final int transcriptId;
  final int episodeId;
  final int startMs;
  final int endMs;
  final String body;
  final String? speaker;
}
