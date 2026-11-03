import 'package:audiflow_domain/audiflow_domain.dart';

import '../../car/services/car_catalog.dart';
import '../../car/services/car_media_browser.dart';

/// A row of the queue published to the platform media session.
sealed class SessionQueueEntry {
  const SessionQueueEntry({
    required this.title,
    required this.podcastTitle,
    required this.artworkUrl,
  });

  final String title;
  final String? podcastTitle;
  final String? artworkUrl;

  /// The row's id for hosts. The session's own row id is its list position,
  /// so a tap is mapped back through the published list, not through this.
  String get mediaId;
}

/// The episode on Now Playing.
///
/// Its media id differs from the now-playing media item's (the audio URL) on
/// purpose: the plugin caches metadata by id, and sharing one would replace
/// the now-playing entry with this row's.
final class SessionNowPlayingEntry extends SessionQueueEntry {
  const SessionNowPlayingEntry({
    required this.episodeId,
    required super.title,
    required super.podcastTitle,
    required super.artworkUrl,
  });

  /// Null when playback started without an episode record.
  final int? episodeId;

  static const _unknownEpisodeMediaId = 'nowPlaying';

  @override
  String get mediaId => switch (episodeId) {
    final id? => CarMediaId.episode(id),
    null => _unknownEpisodeMediaId,
  };
}

/// An episode waiting in the app's queue.
final class SessionUpNextEntry extends SessionQueueEntry {
  const SessionUpNextEntry({
    required this.queueItemId,
    required super.title,
    required super.podcastTitle,
    required super.artworkUrl,
  });

  final int queueItemId;

  @override
  String get mediaId => CarMediaId.queueItem(queueItemId);
}

/// The published list and the position of the playing row in it.
typedef SessionQueue = ({List<SessionQueueEntry> entries, int? activeIndex});

/// Builds the session's list: the playing episode first, then what follows.
///
/// With nothing up next the list is empty rather than one row, so a queue
/// button does not open a list of only the playing episode. With nothing
/// loaded there is no playing row to mark.
SessionQueue buildSessionQueue({
  required PlaybackQueue queue,
  required NowPlayingInfo? nowPlaying,
}) {
  final upNext = queue.upNextItems(nowPlayingUrl: nowPlaying?.episodeUrl);
  if (upNext.isEmpty) return (entries: const [], activeIndex: null);
  final upNextEntries = upNext.map(
    (item) => SessionUpNextEntry(
      queueItemId: item.queueItem.id,
      title: item.episode.title,
      podcastTitle: item.podcastTitle,
      artworkUrl: item.artworkUrl,
    ),
  );
  if (nowPlaying == null) {
    return (
      entries: upNextEntries.take(CarCatalog.itemLimit).toList(),
      activeIndex: null,
    );
  }
  final head = SessionNowPlayingEntry(
    episodeId: nowPlaying.episode?.id,
    title: nowPlaying.episodeTitle,
    podcastTitle: nowPlaying.podcastTitle.isEmpty
        ? null
        : nowPlaying.podcastTitle,
    artworkUrl: nowPlaying.artworkUrl,
  );
  return (
    entries: [head, ...upNextEntries.take(CarCatalog.itemLimit - 1)],
    activeIndex: 0,
  );
}
