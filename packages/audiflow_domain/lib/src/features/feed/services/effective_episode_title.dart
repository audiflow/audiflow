import 'package:logger/logger.dart';

import '../extensions/episode_extensions.dart';
import '../models/episode.dart';
import '../models/smart_playlist_definition.dart';

/// Returns the playlist-extracted display title for [episode], or null
/// when no playlist-level extractor is configured or extraction yields
/// no value. Callers fall back to the raw episode title.
final class EffectiveEpisodeTitle {
  const EffectiveEpisodeTitle._();

  /// Applies [playlist]'s `episodeItem.titleExtractor` to [episode].
  ///
  /// Returns null when:
  /// - [playlist] is null,
  /// - no extractor is configured,
  /// - extraction produces no match, an empty string, or throws.
  ///
  /// Throws are swallowed (logged via [logger] when provided) so a
  /// malformed template cannot crash the surrounding list builder.
  static String? forPlaylist({
    required SmartPlaylistDefinition? playlist,
    required Episode episode,
    Logger? logger,
  }) {
    final extractor = playlist?.episodeItem?.titleExtractor;
    if (extractor == null) return null;
    try {
      final result = extractor.extract(episode.toEpisodeData());
      if (result == null || result.isEmpty) return null;
      return result;
    } on Object catch (e, st) {
      logger?.e(
        '[EffectiveEpisodeTitle] extract threw for '
        'playlist=${playlist?.id} episode=${episode.guid}',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
