import 'package:audiflow_domain/patterns.dart';

/// Diagnostic result from running smart playlist
/// episode extraction.
class SmartPlaylistEpisodeDiagnosticResult {
  const SmartPlaylistEpisodeDiagnosticResult({
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

/// Wraps [NumberingExtractor] to capture diagnostic information.
class NumberingExtractorDiagnostics {
  const NumberingExtractorDiagnostics(this.extractor);

  final NumberingExtractor extractor;

  /// Runs extraction and captures diagnostic details.
  SmartPlaylistEpisodeDiagnosticResult run(EpisodeData episode) {
    final sourceValue = _getSourceValue(episode);
    if (sourceValue == null) {
      return SmartPlaylistEpisodeDiagnosticResult(
        error: 'source "${extractor.source}" returned null',
      );
    }

    // Step 1: Try primary pattern
    final primaryRegex = RegExp(extractor.pattern);
    final primaryMatch = primaryRegex.firstMatch(sourceValue);

    if (primaryMatch != null) {
      int? season;
      int? episodeNum;

      if (extractor.seasonGroup != null &&
          extractor.seasonGroup! <= primaryMatch.groupCount) {
        final captured = primaryMatch.group(extractor.seasonGroup!);
        if (captured != null) {
          season = int.tryParse(captured);
        }
      }

      if (extractor.episodeGroup <= primaryMatch.groupCount) {
        final captured = primaryMatch.group(extractor.episodeGroup);
        if (captured != null) {
          episodeNum = int.tryParse(captured);
        }
      }

      if (season != null || episodeNum != null) {
        return SmartPlaylistEpisodeDiagnosticResult(
          extractedSeasonNumber: season,
          extractedEpisodeNumber: episodeNum,
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
        int? episodeNum;
        if (extractor.fallbackEpisodeCaptureGroup <= fallbackMatch.groupCount) {
          final captured = fallbackMatch.group(
            extractor.fallbackEpisodeCaptureGroup,
          );
          if (captured != null) {
            episodeNum = int.tryParse(captured);
          }
        }

        return SmartPlaylistEpisodeDiagnosticResult(
          extractedSeasonNumber: extractor.fallbackSeasonNumber,
          extractedEpisodeNumber: episodeNum,
          primaryPatternUsed: extractor.pattern,
          fallbackPatternUsed: extractor.fallbackEpisodePattern,
          fallbackMatchResult: fallbackMatch.group(0),
          usedFallback: true,
        );
      }
    }

    // Step 3: RSS fallback if enabled
    if (extractor.fallbackToRss && episode.episodeNumber != null) {
      return SmartPlaylistEpisodeDiagnosticResult(
        extractedEpisodeNumber: episode.episodeNumber,
        primaryPatternUsed: extractor.pattern,
        fallbackPatternUsed: extractor.fallbackEpisodePattern,
        usedFallback: true,
      );
    }

    // Step 4: No match
    return SmartPlaylistEpisodeDiagnosticResult(
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
