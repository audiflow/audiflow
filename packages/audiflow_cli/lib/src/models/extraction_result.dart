/// Result of running extractors on a single episode.
class ExtractionResult {
  const ExtractionResult({
    required this.title,
    required this.rssSeasonNumber,
    required this.rssEpisodeNumber,
    required this.extractedTitle,
    required this.extractedEpisodeNumber,
    this.extractedSeasonNumber,
    this.diagnostics,
  });

  final String title;
  final int? rssSeasonNumber;
  final int? rssEpisodeNumber;
  final String? extractedTitle;
  final int? extractedEpisodeNumber;
  final int? extractedSeasonNumber;
  final ExtractionDiagnostics? diagnostics;

  /// Returns true if both title and episode number were extracted.
  bool get success => extractedTitle != null && diagnostics == null;

  /// Converts to JSON for --json output.
  Map<String, dynamic> toJson() {
    return {
      'status': success ? 'pass' : 'fail',
      'title': title,
      'rss_season': rssSeasonNumber,
      'rss_episode': rssEpisodeNumber,
      'extracted_title': extractedTitle,
      'extracted_episode': extractedEpisodeNumber,
      if (extractedSeasonNumber != null)
        'extracted_season': extractedSeasonNumber,
      if (diagnostics != null) 'diagnostics': diagnostics!.toJson(),
    };
  }
}

/// Diagnostic information for failed extractions.
class ExtractionDiagnostics {
  const ExtractionDiagnostics({
    this.titlePattern,
    this.titleMatch,
    this.episodePattern,
    this.episodeMatch,
    this.fallbackValue,
    this.fallbackConditionMet,
    required this.error,
  });

  final String? titlePattern;
  final String? titleMatch;
  final String? episodePattern;
  final String? episodeMatch;
  final String? fallbackValue;
  final bool? fallbackConditionMet;
  final String error;

  Map<String, dynamic> toJson() {
    return {
      if (titlePattern != null) 'title_pattern': titlePattern,
      if (titleMatch != null) 'title_match': titleMatch,
      if (episodePattern != null) 'episode_pattern': episodePattern,
      if (episodeMatch != null) 'episode_match': episodeMatch,
      if (fallbackValue != null) 'fallback_value': fallbackValue,
      if (fallbackConditionMet != null)
        'fallback_condition_met': fallbackConditionMet,
      'error': error,
    };
  }
}
