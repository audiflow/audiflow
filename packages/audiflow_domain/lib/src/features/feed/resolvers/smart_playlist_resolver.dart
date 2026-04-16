import '../models/episode.dart';
import '../models/smart_playlist.dart';
import '../models/smart_playlist_definition.dart';
import '../models/smart_playlist_sort.dart';

/// Interface for smart playlist resolvers that group episodes into
/// smart playlists.
abstract class SmartPlaylistResolver {
  /// Unique identifier for this resolver type.
  String get type;

  /// Bump when auto-detect logic changes so cached results
  /// are invalidated. See docs/architecture/smart-playlist-cache.md.
  int get heuristicVersion;

  /// Default sort rule for smart playlists produced by this resolver.
  SmartPlaylistSortRule get defaultSort;

  /// Attempts to group episodes into smart playlists.
  ///
  /// Returns null if this resolver cannot handle the given
  /// episodes. The [definition] provides resolver-specific
  /// configuration when available.
  SmartPlaylistGrouping? resolve(
    List<Episode> episodes,
    SmartPlaylistDefinition? definition,
  );
}
