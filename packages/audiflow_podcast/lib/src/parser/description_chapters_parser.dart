import '../models/podcast_chapter.dart';

/// Derives chapters from a timestamp list in an episode description.
///
/// Many feeds publish chapters only as lines such as `02:57 Topic` in the
/// show notes. The description is reduced to text lines, consecutive
/// timestamped lines form a block, and the first block that looks like a
/// chapter list wins. Times inside prose never form a block, because a line
/// only counts when it starts with a timestamp.
final class DescriptionChaptersParser {
  const DescriptionChaptersParser();

  /// Fewest entries a block needs to count as a chapter list.
  static const minimumEntries = 3;

  /// Latest start allowed for the first entry, leaving room for a short
  /// intro before a list that would otherwise start at `0:00`.
  static const maximumFirstStart = Duration(seconds: 10);

  static final _lineBreakTag = RegExp(
    r'<\s*/?\s*(?:br|p|li|div|ul|ol|h[1-6]|tr)\b[^>]*>',
    caseSensitive: false,
  );
  // `<` is excluded inside the tag so stray `<` runs cannot backtrack.
  static final _anyTag = RegExp(r'<[^<>]*>');
  static final _entity = RegExp(
    r'&(?:([a-zA-Z]+)|#(\d+)|#x([0-9a-fA-F]+));',
  );
  static const _namedEntities = {
    'amp': '&',
    'lt': '<',
    'gt': '>',
    'quot': '"',
    'apos': "'",
    'nbsp': ' ',
    'ndash': '–',
    'mdash': '—',
    'hellip': '…',
    'lsquo': '‘',
    'rsquo': '’',
    'ldquo': '“',
    'rdquo': '”',
    'middot': '·',
    'bull': '•',
  };

  // Optional bullet, optional opening bracket, the time, then the title
  // after either a closing bracket (`【00:00】Title` needs no separator) or
  // a separator (dash, colon, wave dash or whitespace).
  static final _entryLine = RegExp(
    r'^[\s•·・*\-–—▶►]*[\[(（【]?'
    r'(\d{1,3}(?::\d{2}){1,2})'
    r'(?:[\])）】]\s*[-–—:：〜~]?\s*|\s*[-–—:：〜~]\s*|\s+)(.+)$',
  );
  static const _trailingSeparators = ' \t-–—:：|/・•〜~';

  /// Returns the derived chapters, or an empty list when no block in
  /// [description] qualifies.
  ///
  /// When [episodeDuration] is known, every chapter must start before it.
  List<PodcastChapter> parse(String description, {Duration? episodeDuration}) {
    for (final block in _blocks(_textLines(description))) {
      if (!_qualifies(block, episodeDuration)) continue;
      return [
        for (final entry in block)
          PodcastChapter(title: entry.title, startTime: entry.start),
      ];
    }
    return const [];
  }

  /// Parses the first of [texts] that yields chapters.
  ///
  /// Used with an episode's description and then its `<content:encoded>`,
  /// since some feeds keep the full notes only in the latter.
  List<PodcastChapter> parseFirst(
    Iterable<String?> texts, {
    Duration? episodeDuration,
  }) {
    for (final text in texts) {
      if (text == null || text.isEmpty) continue;
      final chapters = parse(text, episodeDuration: episodeDuration);
      if (chapters.isNotEmpty) return chapters;
    }
    return const [];
  }

  /// Reduces HTML to plain text lines; plain text passes through.
  static List<String> _textLines(String description) {
    final text = description
        .replaceAll(_lineBreakTag, '\n')
        .replaceAll(_anyTag, '')
        .replaceAllMapped(_entity, _decodeEntity);
    return text.split(RegExp(r'\r\n|\r|\n'));
  }

  /// Groups consecutive timestamped lines; blank lines do not end a block,
  /// since paragraph-per-line HTML leaves them between entries.
  static Iterable<List<_Entry>> _blocks(List<String> lines) sync* {
    var block = <_Entry>[];
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final entry = _parseLine(line);
      if (entry != null) {
        block.add(entry);
        continue;
      }
      if (block.isNotEmpty) yield block;
      block = <_Entry>[];
    }
    if (block.isNotEmpty) yield block;
  }

  static _Entry? _parseLine(String line) {
    final match = _entryLine.firstMatch(line.trim());
    if (match == null) return null;
    final start = _parseTimestamp(match.group(1)!);
    final title = _trimTrailingSeparators(match.group(2)!);
    if (start == null || title.isEmpty) return null;
    return _Entry(start, title);
  }

  /// Parses `m:ss`, `mm:ss` or `h:mm:ss`; null when a field is out of range.
  static Duration? _parseTimestamp(String value) {
    final parts = value.split(':').map(int.parse).toList();
    final seconds = parts.last;
    if (59 < seconds) return null;
    if (parts.length == 2) {
      return Duration(minutes: parts[0], seconds: seconds);
    }
    final minutes = parts[1];
    if (59 < minutes) return null;
    return Duration(hours: parts[0], minutes: minutes, seconds: seconds);
  }

  static bool _qualifies(List<_Entry> block, Duration? episodeDuration) {
    if (block.length < minimumEntries) return false;
    if (maximumFirstStart < block.first.start) return false;
    for (var i = 1; i < block.length; i++) {
      if (block[i].start <= block[i - 1].start) return false;
    }
    if (episodeDuration == null || episodeDuration == Duration.zero) {
      return true;
    }
    return block.last.start < episodeDuration;
  }

  // A loop rather than a `[...]+$` regex, which backtracks quadratically
  // on long separator runs.
  static String _trimTrailingSeparators(String value) {
    var end = value.length;
    while (0 < end && _trailingSeparators.contains(value[end - 1])) {
      end--;
    }
    return value.substring(0, end).trim();
  }

  static String _decodeEntity(Match match) {
    final named = match.group(1);
    if (named != null) {
      return _namedEntities[named.toLowerCase()] ?? match.group(0)!;
    }
    final decimal = match.group(2);
    final code = decimal != null
        ? int.tryParse(decimal)
        : int.tryParse(match.group(3)!, radix: 16);
    // Out-of-range references would make fromCharCode throw.
    if (code == null || 0x10FFFF < code) return ' ';
    return String.fromCharCode(code);
  }
}

final class _Entry {
  const _Entry(this.start, this.title);

  final Duration start;
  final String title;
}
