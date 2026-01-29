import '../../../common/database/app_database.dart';
import '../models/smart_playlist.dart';
import '../models/smart_playlist_pattern.dart';
import '../resolvers/smart_playlist_resolver.dart';

/// Service that orchestrates the smart playlist resolver chain.
///
/// Tries resolvers in order until one succeeds. Custom patterns for
/// specific podcasts are checked first.
class SmartPlaylistResolverService {
  SmartPlaylistResolverService({
    required List<SmartPlaylistResolver> resolvers,
    required List<SmartPlaylistPattern> patterns,
  }) : _resolvers = resolvers,
       _patterns = patterns;

  final List<SmartPlaylistResolver> _resolvers;
  final List<SmartPlaylistPattern> _patterns;

  /// Attempts to group episodes into smart playlists.
  ///
  /// Returns null if no resolver succeeds.
  SmartPlaylistGrouping? resolveSmartPlaylists({
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

  SmartPlaylistPattern? _findMatchingPattern(String? guid, String feedUrl) {
    for (final pattern in _patterns) {
      if (pattern.matchesPodcast(guid, feedUrl)) {
        return pattern;
      }
    }
    return null;
  }

  SmartPlaylistResolver? _findResolverByType(String type) {
    for (final resolver in _resolvers) {
      if (resolver.type == type) {
        return resolver;
      }
    }
    return null;
  }
}
