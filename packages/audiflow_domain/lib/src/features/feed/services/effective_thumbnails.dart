import '../models/smart_playlist_definition.dart';
import '../models/smart_playlist_group_def.dart';

/// Resolves thumbnail visibility for the smart playlist surfaces
/// introduced by schema v6.
///
/// Rule: the pattern-level `showEpisodeThumbnail` flag flips the
/// default for unset descendants. Explicit per-surface flags always
/// win. Group card and episode row visibility are independent —
/// turning group cards off does not hide episode rows.
final class EffectiveThumbnails {
  const EffectiveThumbnails._();

  /// `true` unless the pattern explicitly opts out via
  /// `showEpisodeThumbnail = false`.
  static bool _metaDefault(bool? showEpisodeThumbnail) =>
      showEpisodeThumbnail != false;

  /// Visibility of episode thumbnails in the main podcast episode
  /// list (outside any smart playlist).
  static bool podcastEpisodeList({bool? showEpisodeThumbnail}) =>
      showEpisodeThumbnail ?? true;

  /// Visibility of the thumbnail on a smart playlist group card.
  static bool groupCard({
    bool? showEpisodeThumbnail,
    required SmartPlaylistDefinition playlist,
    SmartPlaylistGroupDef? group,
  }) =>
      group?.groupItem?.showThumbnail ??
      playlist.groupItem?.showThumbnail ??
      _metaDefault(showEpisodeThumbnail);

  /// Visibility of the thumbnail on an episode row rendered inside
  /// a smart playlist group.
  static bool episodeRowInGroup({
    bool? showEpisodeThumbnail,
    required SmartPlaylistDefinition playlist,
    SmartPlaylistGroupDef? group,
  }) =>
      group?.episodeItem?.showThumbnail ??
      playlist.episodeItem?.showThumbnail ??
      _metaDefault(showEpisodeThumbnail);
}
