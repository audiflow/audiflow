import 'package:audiflow_domain/patterns.dart';

import '../diagnostics/title_extractor_diagnostics.dart';

/// Command to test pattern extraction against a single title.
class PatternTestCommand {
  PatternTestCommand([StringSink? sink]) : _sink = sink ?? StringBuffer();

  final StringSink _sink;

  /// Runs the command and returns exit code.
  int run({
    required String title,
    required String? titlePattern,
    int titleGroup = 1,
    String? titleFallback,
    int? seasonNumber,
    int? episodeNumber,
  }) {
    // Create a simple episode data for testing
    final episode = SimpleEpisodeData(
      title: title,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
    );

    _sink.writeln('Input:');
    _sink.writeln('  title: $title');
    _sink.writeln('  seasonNumber: $seasonNumber');
    _sink.writeln('  episodeNumber: $episodeNumber');
    _sink.writeln();

    var hasError = false;

    // Test title extraction
    if (titlePattern != null || titleFallback != null) {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'title',
        pattern: titlePattern,
        group: titleGroup,
        fallbackValue: titleFallback,
      );

      final diagnostics = TitleExtractorDiagnostics(extractor);
      final result = diagnostics.run(episode);

      _sink.writeln('Title Extraction:');
      if (result.extractedValue != null) {
        _sink.writeln('  result: ${result.extractedValue}');
        if (result.fallbackConditionMet == true) {
          _sink.writeln('  (used fallback)');
        } else if (result.matchResult != null) {
          _sink.writeln('  match: ${result.matchResult}');
        }
      } else {
        _sink.writeln('  ERROR: ${result.error}');
        hasError = true;
      }
      _sink.writeln();
    }

    return hasError ? 1 : 0;
  }
}
