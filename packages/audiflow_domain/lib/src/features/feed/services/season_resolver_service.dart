import '../../../common/database/app_database.dart';
import '../models/season.dart';
import '../models/season_pattern.dart';
import '../resolvers/season_resolver.dart';

/// Service that orchestrates the season resolver chain.
///
/// Tries resolvers in order until one succeeds. Custom patterns for specific
/// podcasts are checked first.
class SeasonResolverService {
  SeasonResolverService({
    required List<SeasonResolver> resolvers,
    required List<SeasonPattern> patterns,
  }) : _resolvers = resolvers,
       _patterns = patterns;

  final List<SeasonResolver> _resolvers;
  final List<SeasonPattern> _patterns;

  /// Attempts to group episodes into seasons.
  ///
  /// Returns null if no resolver succeeds.
  SeasonGrouping? resolveSeasons({
    required String? podcastGuid,
    required String feedUrl,
    required List<Episode> episodes,
  }) {
    if (episodes.isEmpty) return null;

    // Check for matching custom pattern first
    final pattern = _findMatchingPattern(podcastGuid, feedUrl);
    if (pattern != null) {
      final resolver = _findResolverByType(pattern.resolverType);
      if (resolver != null) {
        final result = resolver.resolve(episodes, pattern);
        if (result != null) return result;
      }
    }

    // Try resolvers in order
    for (final resolver in _resolvers) {
      final result = resolver.resolve(episodes, null);
      if (result != null) return result;
    }

    return null;
  }

  SeasonPattern? _findMatchingPattern(String? guid, String feedUrl) {
    for (final pattern in _patterns) {
      if (pattern.matchesPodcast(guid, feedUrl)) {
        return pattern;
      }
    }
    return null;
  }

  SeasonResolver? _findResolverByType(String type) {
    for (final resolver in _resolvers) {
      if (resolver.type == type) {
        return resolver;
      }
    }
    return null;
  }
}
