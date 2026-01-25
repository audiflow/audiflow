import '../models/extraction_result.dart';

/// Formats extraction results as a human-readable table.
class TableReporter {
  TableReporter([StringSink? sink]) : _sink = sink ?? StringBuffer();

  final StringSink _sink;

  /// Writes the header with feed URL and pattern info.
  void writeHeader({
    required String feedUrl,
    required String? patternId,
    required int episodeCount,
  }) {
    _sink.writeln('Fetching: $feedUrl');
    _sink.writeln(
      'Pattern:  ${patternId ?? "(none)"}'
      '${patternId != null ? " (auto-detected)" : ""}',
    );
    _sink.writeln('Episodes: $episodeCount');
    _sink.writeln();
  }

  /// Writes a single extraction result.
  void writeResult(ExtractionResult result) {
    final season = result.rssSeasonNumber != null
        ? 'S${result.rssSeasonNumber}'.padRight(4)
        : 'null'.padRight(4);
    final episode = result.rssEpisodeNumber != null
        ? 'E${result.rssEpisodeNumber}'.padRight(4)
        : 'null'.padRight(4);

    final truncatedTitle = _truncate(result.title, 40);

    if (result.success) {
      _sink.writeln(
        'PASS | $season | $episode | $truncatedTitle | '
        'title="${result.extractedTitle}" ep=${result.extractedEpisodeNumber}',
      );
    } else {
      _sink.writeln('FAIL | $season | $episode | $truncatedTitle');
      _writeDiagnostics(result.diagnostics!);
    }
  }

  void _writeDiagnostics(ExtractionDiagnostics d) {
    const indent = '     |      |      |   ';
    if (d.titlePattern != null) {
      _sink.writeln('${indent}title_pattern: ${d.titlePattern}');
    }
    if (d.titleMatch != null) {
      _sink.writeln('${indent}title_match: ${d.titleMatch}');
    } else if (d.titlePattern != null) {
      _sink.writeln('${indent}title_match: none');
    }
    if (d.fallbackValue != null) {
      _sink.writeln('${indent}fallback_value: "${d.fallbackValue}"');
    }
    if (d.fallbackConditionMet != null) {
      final met = d.fallbackConditionMet! ? 'yes' : 'no';
      _sink.writeln('${indent}fallback_condition: $met');
    }
    _sink.writeln('${indent}error: ${d.error}');
  }

  /// Writes summary statistics.
  void writeSummary({
    required int total,
    required int passed,
    required int failed,
  }) {
    final passPercent = 0 < total
        ? (passed / total * 100).toStringAsFixed(1)
        : '0.0';
    final failPercent = 0 < total
        ? (failed / total * 100).toStringAsFixed(1)
        : '0.0';

    _sink.writeln();
    _sink.writeln('--- Summary ---');
    _sink.writeln('Total: $total');
    _sink.writeln('Pass:  $passed ($passPercent%)');
    _sink.writeln('Fail:  $failed ($failPercent%)');
  }

  String _truncate(String s, int maxLen) {
    if (s.length <= maxLen) return s.padRight(maxLen);
    return '${s.substring(0, maxLen - 3)}...';
  }
}
