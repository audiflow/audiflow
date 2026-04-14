import '../models/episode_filter_entry.dart';
import '../models/smart_playlist_definition.dart';
import '../models/numbering_extractor.dart';
import '../models/smart_playlist_group_def.dart';
import '../models/smart_playlist_pattern_config.dart';

/// Resolves the appropriate [NumberingExtractor] for an episode
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
  NumberingExtractor? resolve(
    String title,
    String? description,
    SmartPlaylistPatternConfig config,
  ) {
    for (final definition in config.playlists) {
      final groups = definition.grouping.staticClassifiers;
      if (groups != null) {
        final groupExtractor = _findGroupExtractor(title, description, groups);
        if (groupExtractor != null) return groupExtractor;
      }

      // Fall back to definition-level extractor only if episode
      // matches definition's filters (or if no filter exists).
      if (definition.grouping.numberingExtractor != null &&
          _matchesDefinition(title, description, definition)) {
        return definition.grouping.numberingExtractor;
      }
    }
    return null;
  }

  /// Checks whether an episode matches a definition's filters.
  ///
  /// Returns true if no filters are defined (acts as fallback).
  bool _matchesDefinition(
    String title,
    String? description,
    SmartPlaylistDefinition definition,
  ) {
    final filters = definition.episodeFilters;
    if (filters == null || !filters.hasFilters) return true;

    if (filters.require != null && filters.require!.isNotEmpty) {
      final matchesAny = filters.require!.any(
        (entry) => _entryMatches(entry, title, description),
      );
      if (!matchesAny) return false;
    }

    if (filters.exclude != null && filters.exclude!.isNotEmpty) {
      final matchesAny = filters.exclude!.any(
        (entry) => _entryMatches(entry, title, description),
      );
      if (matchesAny) return false;
    }

    return true;
  }

  /// Checks whether a single filter entry matches the episode.
  bool _entryMatches(
    EpisodeFilterEntry entry,
    String title,
    String? description,
  ) {
    if (entry.title != null) {
      final regex = RegExp(entry.title!, caseSensitive: false);
      if (!regex.hasMatch(title)) return false;
    }
    if (entry.description != null && description != null) {
      final regex = RegExp(entry.description!, caseSensitive: false);
      if (!regex.hasMatch(description)) return false;
    }
    return entry.title != null || entry.description != null;
  }

  /// Finds a group-level extractor by matching the episode title
  /// against group patterns.
  NumberingExtractor? _findGroupExtractor(
    String title,
    String? description,
    List<SmartPlaylistGroupDef> groups,
  ) {
    for (final group in groups) {
      if (group.pattern == null) continue;

      final regex = RegExp(group.pattern!.pattern, caseSensitive: false);
      final text = group.pattern!.source == 'description' ? description : title;
      if (text != null && regex.hasMatch(text)) {
        // Group matched; return its extractor (may be null, meaning
        // fall through to definition-level).
        if (group.numberingExtractor != null) {
          return group.numberingExtractor;
        }
      }
    }
    return null;
  }
}
