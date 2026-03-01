/// A single timed segment from a transcript file.
class TranscriptSegment {
  /// Creates a transcript segment with timing and text.
  const TranscriptSegment({
    required this.startMs,
    required this.endMs,
    required this.text,
    this.speaker,
  });

  /// Start time in milliseconds.
  final int startMs;

  /// End time in milliseconds.
  final int endMs;

  /// The transcript text for this segment.
  final String text;

  /// Optional speaker identifier.
  final String? speaker;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptSegment &&
          runtimeType == other.runtimeType &&
          startMs == other.startMs &&
          endMs == other.endMs &&
          text == other.text &&
          speaker == other.speaker;

  @override
  int get hashCode => Object.hash(startMs, endMs, text, speaker);

  @override
  String toString() =>
      'TranscriptSegment(startMs: $startMs, endMs: $endMs, '
      'text: $text, speaker: $speaker)';
}
