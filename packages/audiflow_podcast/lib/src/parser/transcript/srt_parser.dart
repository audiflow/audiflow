import 'transcript_segment.dart';

/// Parses SubRip (.srt) transcript files into [TranscriptSegment] lists.
class SrtParser {
  /// Creates an SRT parser.
  const SrtParser();

  // Matches: HH:MM:SS,mmm --> HH:MM:SS,mmm (comma or dot as separator)
  static final _timestampPattern = RegExp(
    r'(\d{2}):(\d{2}):(\d{2})[,.](\d{3})'
    r'\s*-->\s*'
    r'(\d{2}):(\d{2}):(\d{2})[,.](\d{3})',
  );

  /// Parses SRT content into a list of transcript segments.
  ///
  /// Malformed blocks are skipped gracefully.
  /// Returns an empty list for empty or whitespace-only content.
  List<TranscriptSegment> parse(String content) {
    if (content.trim().isEmpty) return [];

    final blocks = _splitIntoBlocks(content);
    final segments = <TranscriptSegment>[];
    for (final block in blocks) {
      final segment = _parseBlock(block);
      if (segment != null) segments.add(segment);
    }
    return segments;
  }

  /// Splits SRT content into blocks separated by blank lines.
  List<List<String>> _splitIntoBlocks(String content) {
    final lines = content.split('\n');
    final blocks = <List<String>>[];
    var currentBlock = <String>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        if (currentBlock.isNotEmpty) {
          blocks.add(currentBlock);
          currentBlock = <String>[];
        }
      } else {
        currentBlock.add(line.trim());
      }
    }
    if (currentBlock.isNotEmpty) blocks.add(currentBlock);

    return blocks;
  }

  /// Parses a single SRT block into a segment.
  ///
  /// Returns null if the block is malformed or has no text.
  TranscriptSegment? _parseBlock(List<String> lines) {
    // Need at least: sequence number, timestamp, one text line
    if (3 <= lines.length) {
      return _parseFullBlock(lines);
    }
    return null;
  }

  TranscriptSegment? _parseFullBlock(List<String> lines) {
    // Line 0: sequence number (skip)
    // Line 1: timestamp
    final match = _timestampPattern.firstMatch(lines[1]);
    if (match == null) return null;

    final startMs = _toMilliseconds(match, startGroup: 1);
    final endMs = _toMilliseconds(match, startGroup: 5);
    final text = lines.sublist(2).join(' ');

    if (text.isEmpty) return null;

    return TranscriptSegment(
      startMs: startMs,
      endMs: endMs,
      text: text,
    );
  }

  /// Converts regex groups to milliseconds.
  ///
  /// Groups at [startGroup] offset: hours, minutes, seconds, millis.
  int _toMilliseconds(RegExpMatch match, {required int startGroup}) {
    final hours = int.parse(match.group(startGroup)!);
    final minutes = int.parse(match.group(startGroup + 1)!);
    final seconds = int.parse(match.group(startGroup + 2)!);
    final millis = int.parse(match.group(startGroup + 3)!);
    return hours * 3600000 + minutes * 60000 + seconds * 1000 + millis;
  }
}
