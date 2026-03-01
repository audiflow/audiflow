import 'transcript_segment.dart';

/// Parser for WebVTT (.vtt) transcript files.
///
/// Supports speaker identification via `<v SpeakerName>` voice tags
/// and strips all HTML-like tags from cue text.
class VttParser {
  /// Creates a VTT parser instance.
  const VttParser();

  static final _timestampPattern = RegExp(
    r'(\d{2}):(\d{2}):(\d{2})\.(\d{3})\s*-->\s*'
    r'(\d{2}):(\d{2}):(\d{2})\.(\d{3})',
  );

  static final _voiceTagPattern = RegExp(r'<v\s+([^>]+)>');
  static final _htmlTagPattern = RegExp(r'<[^>]+>');

  /// Parses VTT content into a list of [TranscriptSegment].
  ///
  /// Skips the WEBVTT header block, NOTE blocks, and cue blocks
  /// that lack a timestamp or text.
  List<TranscriptSegment> parse(String content) {
    if (content.trim().isEmpty) return [];

    final blocks = _splitIntoBlocks(content);
    final segments = <TranscriptSegment>[];

    for (final block in blocks) {
      if (_shouldSkipBlock(block)) continue;

      final segment = _parseBlock(block);
      if (segment != null) segments.add(segment);
    }

    return segments;
  }

  /// Splits content into blocks separated by blank lines.
  List<String> _splitIntoBlocks(String content) {
    return content
        .split(RegExp(r'\n\s*\n'))
        .map((block) => block.trim())
        .where((block) => block.isNotEmpty)
        .toList();
  }

  /// Returns true for blocks that should be skipped.
  bool _shouldSkipBlock(String block) {
    return block.startsWith('WEBVTT') || block.startsWith('NOTE');
  }

  /// Parses a single cue block into a [TranscriptSegment].
  ///
  /// Returns null if the block has no valid timestamp or text.
  TranscriptSegment? _parseBlock(String block) {
    final lines = block.split('\n');
    final timestampIndex = _findTimestampLine(lines);
    if (timestampIndex == null) return null;

    final timestamps = _parseTimestamps(lines[timestampIndex]);
    if (timestamps == null) return null;

    final textLines = lines.sublist(timestampIndex + 1);
    if (textLines.isEmpty) return null;

    final rawText = textLines.join(' ').trim();
    if (rawText.isEmpty) return null;

    final speaker = _extractSpeaker(rawText);
    final cleanedText = _stripTags(rawText);
    if (cleanedText.isEmpty) return null;

    return TranscriptSegment(
      startMs: timestamps.$1,
      endMs: timestamps.$2,
      text: cleanedText,
      speaker: speaker,
    );
  }

  /// Finds the index of the line containing a timestamp.
  int? _findTimestampLine(List<String> lines) {
    for (var i = 0; lines.length != i; i++) {
      if (_timestampPattern.hasMatch(lines[i])) return i;
    }
    return null;
  }

  /// Parses a timestamp line into start and end milliseconds.
  (int, int)? _parseTimestamps(String line) {
    final match = _timestampPattern.firstMatch(line);
    if (match == null) return null;

    final startMs = _toMilliseconds(
      hours: int.parse(match.group(1)!),
      minutes: int.parse(match.group(2)!),
      seconds: int.parse(match.group(3)!),
      milliseconds: int.parse(match.group(4)!),
    );
    final endMs = _toMilliseconds(
      hours: int.parse(match.group(5)!),
      minutes: int.parse(match.group(6)!),
      seconds: int.parse(match.group(7)!),
      milliseconds: int.parse(match.group(8)!),
    );

    return (startMs, endMs);
  }

  /// Converts time components to total milliseconds.
  int _toMilliseconds({
    required int hours,
    required int minutes,
    required int seconds,
    required int milliseconds,
  }) {
    return hours * 3600000 + minutes * 60000 + seconds * 1000 + milliseconds;
  }

  /// Extracts speaker name from a `<v SpeakerName>` voice tag.
  String? _extractSpeaker(String text) {
    final match = _voiceTagPattern.firstMatch(text);
    return match?.group(1)?.trim();
  }

  /// Strips all HTML-like tags from text.
  String _stripTags(String text) {
    return text.replaceAll(_htmlTagPattern, '').trim();
  }
}
