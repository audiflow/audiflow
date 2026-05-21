import '../models/preset_config.dart';
import '../models/preset_meta.dart';
import '../models/smart_playlist_definition.dart';

/// Assembles a [PresetConfig] from split config files.
///
/// Combines a [PresetMeta] with its playlist definitions into
/// the unified config that resolvers expect.
final class ConfigAssembler {
  ConfigAssembler._();

  /// Assembles a full config from preset metadata and playlist
  /// definitions.
  ///
  /// Playlists are ordered according to [meta.playlists]. Any
  /// playlists not listed in meta are appended at the end.
  static PresetConfig assemble(
    PresetMeta meta,
    List<SmartPlaylistDefinition> playlists,
  ) {
    final playlistMap = {for (final p in playlists) p.id: p};

    final ordered = <SmartPlaylistDefinition>[];
    for (final id in meta.playlists) {
      final playlist = playlistMap.remove(id);
      if (playlist != null) {
        ordered.add(playlist);
      }
    }
    ordered.addAll(playlistMap.values);

    return PresetConfig(
      id: meta.id,
      podcastGuid: meta.podcastGuid,
      feedUrls: meta.feedUrls,
      yearGroupedEpisodes: meta.yearGroupedEpisodes,
      showEpisodeThumbnail: meta.showEpisodeThumbnail,
      playlists: ordered,
    );
  }
}
