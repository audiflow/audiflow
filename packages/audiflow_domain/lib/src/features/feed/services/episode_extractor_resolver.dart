import '../models/smart_playlist_episode_extractor.dart';
import '../models/smart_playlist_group_def.dart';
import '../models/smart_playlist_pattern_config.dart';

/// Resolves the appropriate [SmartPlaylistEpisodeExtractor] for an episode
/// by matching it against group patterns within the pattern config.
///
/// For each episode, iterates definitions and their groups to find a
/// matching group's extractor, falling back to the definition-level
/// extractor when no group match is found.
class EpisodeExtractorResolver {
  /// Resolves the extractor for an episode based on its title and
  /// description.
  ///
  /// Returns the most specific extractor (group-level > definition-level),
  /// or null if no extractor is configured.
  SmartPlaylistEpisodeExtractor? resolve(
    String title,
    String? description,
    SmartPlaylistPatternConfig config,
  ) {
    for (final definition in config.playlists) {
      final groups = definition.groups;
      if (groups != null) {
        final groupExtractor = _findGroupExtractor(title, description, groups);
        if (groupExtractor != null) return groupExtractor;
      }

      // Fall back to definition-level extractor if episode matches
      // definition's filter (or if no filter exists).
      if (definition.episodeExtractor != null) {
        return definition.episodeExtractor;
      }
    }
    return null;
  }

  /// Finds a group-level extractor by matching the episode title
  /// against group patterns.
  SmartPlaylistEpisodeExtractor? _findGroupExtractor(
    String title,
    String? description,
    List<SmartPlaylistGroupDef> groups,
  ) {
    for (final group in groups) {
      if (group.pattern == null) continue;

      final regex = RegExp(group.pattern!, caseSensitive: false);
      if (regex.hasMatch(title)) {
        // Group matched; return its extractor (may be null, meaning
        // fall through to definition-level).
        if (group.episodeExtractor != null) {
          return group.episodeExtractor;
        }
      }
    }
    return null;
  }
}
