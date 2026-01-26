import 'package:audiflow_domain/patterns.dart';

/// Diagnostic result from running season+episode extraction.
class SeasonEpisodeDiagnosticResult {
  const SeasonEpisodeDiagnosticResult({
    this.extractedSeasonNumber,
    this.extractedEpisodeNumber,
    this.primaryPatternUsed,
    this.primaryMatchResult,
    this.fallbackPatternUsed,
    this.fallbackMatchResult,
    this.usedFallback = false,
    this.error,
  });

  final int? extractedSeasonNumber;
  final int? extractedEpisodeNumber;
  final String? primaryPatternUsed;
  final String? primaryMatchResult;
  final String? fallbackPatternUsed;
  final String? fallbackMatchResult;
  final bool usedFallback;
  final String? error;

  /// Returns true if at least one value was extracted.
  bool get hasValues =>
      extractedSeasonNumber != null || extractedEpisodeNumber != null;
}

/// Wraps [SeasonEpisodeExtractor] to capture diagnostic information.
class SeasonEpisodeExtractorDiagnostics {
  const SeasonEpisodeExtractorDiagnostics(this.extractor);

  final SeasonEpisodeExtractor extractor;

  /// Runs extraction and captures diagnostic details.
  SeasonEpisodeDiagnosticResult run(EpisodeData episode) {
    final sourceValue = _getSourceValue(episode);
    if (sourceValue == null) {
      return SeasonEpisodeDiagnosticResult(
        error: 'source "${extractor.source}" returned null',
      );
    }

    // Step 1: Try primary pattern
    final primaryRegex = RegExp(extractor.pattern);
    final primaryMatch = primaryRegex.firstMatch(sourceValue);

    if (primaryMatch != null) {
      int? season;
      int? episode;

      if (extractor.seasonGroup <= primaryMatch.groupCount) {
        final captured = primaryMatch.group(extractor.seasonGroup);
        if (captured != null) {
          season = int.tryParse(captured);
        }
      }

      if (extractor.episodeGroup <= primaryMatch.groupCount) {
        final captured = primaryMatch.group(extractor.episodeGroup);
        if (captured != null) {
          episode = int.tryParse(captured);
        }
      }

      if (season != null || episode != null) {
        return SeasonEpisodeDiagnosticResult(
          extractedSeasonNumber: season,
          extractedEpisodeNumber: episode,
          primaryPatternUsed: extractor.pattern,
          primaryMatchResult: primaryMatch.group(0),
        );
      }
    }

    // Step 2: Try fallback pattern if configured
    if (extractor.fallbackEpisodePattern != null) {
      final fallbackRegex = RegExp(extractor.fallbackEpisodePattern!);
      final fallbackMatch = fallbackRegex.firstMatch(sourceValue);

      if (fallbackMatch != null) {
        int? episode;
        if (extractor.fallbackEpisodeCaptureGroup <= fallbackMatch.groupCount) {
          final captured = fallbackMatch.group(
            extractor.fallbackEpisodeCaptureGroup,
          );
          if (captured != null) {
            episode = int.tryParse(captured);
          }
        }

        return SeasonEpisodeDiagnosticResult(
          extractedSeasonNumber: extractor.fallbackSeasonNumber,
          extractedEpisodeNumber: episode,
          primaryPatternUsed: extractor.pattern,
          fallbackPatternUsed: extractor.fallbackEpisodePattern,
          fallbackMatchResult: fallbackMatch.group(0),
          usedFallback: true,
        );
      }
    }

    // Step 3: No match
    return SeasonEpisodeDiagnosticResult(
      primaryPatternUsed: extractor.pattern,
      fallbackPatternUsed: extractor.fallbackEpisodePattern,
      error: 'no pattern matched title: "$sourceValue"',
    );
  }

  String? _getSourceValue(EpisodeData episode) {
    return switch (extractor.source) {
      'title' => episode.title,
      'description' => episode.description,
      _ => null,
    };
  }
}
