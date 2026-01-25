import 'package:audiflow_domain/audiflow_domain.dart';

/// Diagnostic result from running episode number extraction.
class EpisodeDiagnosticResult {
  const EpisodeDiagnosticResult({
    this.extractedValue,
    this.patternUsed,
    this.matchResult,
    this.usedRssFallback = false,
    this.error,
  });

  final int? extractedValue;
  final String? patternUsed;
  final String? matchResult;
  final bool usedRssFallback;
  final String? error;
}

/// Wraps [EpisodeNumberExtractor] to capture diagnostic information.
class EpisodeExtractorDiagnostics {
  const EpisodeExtractorDiagnostics(this.extractor);

  final EpisodeNumberExtractor extractor;

  /// Runs extraction and captures diagnostic details.
  EpisodeDiagnosticResult run(Episode episode) {
    final seasonNum = episode.seasonNumber;

    // Step 1: For null/zero seasonNumber, use RSS episodeNumber directly
    if (seasonNum == null || 1 > seasonNum) {
      return EpisodeDiagnosticResult(
        extractedValue: episode.episodeNumber,
        usedRssFallback: true,
      );
    }

    // Step 2: Try regex extraction from title
    final regex = RegExp(extractor.pattern);
    final match = regex.firstMatch(episode.title);

    if (match != null && extractor.captureGroup <= match.groupCount) {
      final captured = match.group(extractor.captureGroup);
      if (captured != null) {
        final parsed = int.tryParse(captured);
        if (parsed != null) {
          return EpisodeDiagnosticResult(
            extractedValue: parsed,
            patternUsed: extractor.pattern,
            matchResult: captured,
          );
        }
      }
    }

    // Step 3: Fall back to RSS episodeNumber if enabled
    if (extractor.fallbackToRss && episode.episodeNumber != null) {
      return EpisodeDiagnosticResult(
        extractedValue: episode.episodeNumber,
        patternUsed: extractor.pattern,
        usedRssFallback: true,
      );
    }

    // Step 4: No match, no fallback
    return EpisodeDiagnosticResult(
      patternUsed: extractor.pattern,
      error:
          'pattern did not match and fallbackToRss=${extractor.fallbackToRss}',
    );
  }
}
