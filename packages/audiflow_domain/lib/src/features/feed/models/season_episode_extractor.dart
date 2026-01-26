import 'package:audiflow_core/audiflow_core.dart';

/// Result of extracting season and episode numbers from episode data.
final class SeasonEpisodeResult {
  const SeasonEpisodeResult({this.seasonNumber, this.episodeNumber});

  final int? seasonNumber;
  final int? episodeNumber;

  /// Returns true if at least one value was extracted.
  bool get hasValues => seasonNumber != null || episodeNumber != null;

  @override
  String toString() =>
      'SeasonEpisodeResult(season: $seasonNumber, episode: $episodeNumber)';
}

/// Extracts both season and episode numbers from episode title prefix.
///
/// Designed for podcasts like COTEN RADIO where RSS metadata is unreliable
/// but episode titles encode the data reliably:
/// - `【62-15】何が変わった?...` encodes Season 62, Episode 15
/// - `【番外編＃135】...` encodes a special episode (season 0, episode 135)
final class SeasonEpisodeExtractor {
  const SeasonEpisodeExtractor({
    required this.source,
    required this.pattern,
    this.seasonGroup = 1,
    this.episodeGroup = 2,
    this.fallbackSeasonNumber,
    this.fallbackEpisodePattern,
    this.fallbackEpisodeCaptureGroup = 1,
  });

  factory SeasonEpisodeExtractor.fromJson(Map<String, dynamic> json) {
    return SeasonEpisodeExtractor(
      source: json['source'] as String,
      pattern: json['pattern'] as String,
      seasonGroup: (json['seasonGroup'] as int?) ?? 1,
      episodeGroup: (json['episodeGroup'] as int?) ?? 2,
      fallbackSeasonNumber: json['fallbackSeasonNumber'] as int?,
      fallbackEpisodePattern: json['fallbackEpisodePattern'] as String?,
      fallbackEpisodeCaptureGroup:
          (json['fallbackEpisodeCaptureGroup'] as int?) ?? 1,
    );
  }

  /// Episode field to extract from ("title" or "description").
  final String source;

  /// Primary regex pattern to extract both season and episode.
  ///
  /// Example: `【(\d+)-(\d+)】` for `【62-15】`
  final String pattern;

  /// Capture group index for season number (default: 1).
  final int seasonGroup;

  /// Capture group index for episode number (default: 2).
  final int episodeGroup;

  /// Season number to use when primary pattern fails but fallback matches.
  ///
  /// Example: `0` for 番外編 episodes.
  final int? fallbackSeasonNumber;

  /// Fallback regex pattern for special episodes (e.g., 番外編).
  ///
  /// Example: `【番外編[＃#](\d+)】`
  final String? fallbackEpisodePattern;

  /// Capture group index for episode number in fallback pattern (default: 1).
  final int fallbackEpisodeCaptureGroup;

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'pattern': pattern,
      'seasonGroup': seasonGroup,
      'episodeGroup': episodeGroup,
      if (fallbackSeasonNumber != null)
        'fallbackSeasonNumber': fallbackSeasonNumber,
      if (fallbackEpisodePattern != null)
        'fallbackEpisodePattern': fallbackEpisodePattern,
      if (fallbackEpisodeCaptureGroup != 1)
        'fallbackEpisodeCaptureGroup': fallbackEpisodeCaptureGroup,
    };
  }

  /// Extracts season and episode numbers from episode data.
  ///
  /// Returns a [SeasonEpisodeResult] with extracted values (may be null).
  SeasonEpisodeResult extract(EpisodeData episode) {
    final sourceValue = _getSourceValue(episode);
    if (sourceValue == null) {
      return const SeasonEpisodeResult();
    }

    // Try primary pattern first
    final primaryResult = _extractFromPrimary(sourceValue);
    if (primaryResult.hasValues) {
      return primaryResult;
    }

    // Try fallback pattern if configured
    if (fallbackEpisodePattern != null) {
      return _extractFromFallback(sourceValue);
    }

    return const SeasonEpisodeResult();
  }

  String? _getSourceValue(EpisodeData episode) {
    return switch (source) {
      'title' => episode.title,
      'description' => episode.description,
      _ => null,
    };
  }

  SeasonEpisodeResult _extractFromPrimary(String value) {
    final regex = RegExp(pattern);
    final match = regex.firstMatch(value);

    if (match == null) {
      return const SeasonEpisodeResult();
    }

    int? season;
    int? episode;

    if (seasonGroup <= match.groupCount) {
      final captured = match.group(seasonGroup);
      if (captured != null) {
        season = int.tryParse(captured);
      }
    }

    if (episodeGroup <= match.groupCount) {
      final captured = match.group(episodeGroup);
      if (captured != null) {
        episode = int.tryParse(captured);
      }
    }

    return SeasonEpisodeResult(seasonNumber: season, episodeNumber: episode);
  }

  SeasonEpisodeResult _extractFromFallback(String value) {
    final regex = RegExp(fallbackEpisodePattern!);
    final match = regex.firstMatch(value);

    if (match == null) {
      return const SeasonEpisodeResult();
    }

    int? episode;
    if (fallbackEpisodeCaptureGroup <= match.groupCount) {
      final captured = match.group(fallbackEpisodeCaptureGroup);
      if (captured != null) {
        episode = int.tryParse(captured);
      }
    }

    return SeasonEpisodeResult(
      seasonNumber: fallbackSeasonNumber,
      episodeNumber: episode,
    );
  }
}
