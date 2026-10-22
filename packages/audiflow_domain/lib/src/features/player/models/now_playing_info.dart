import 'package:freezed_annotation/freezed_annotation.dart';

import '../../feed/models/episode.dart';
import '../../subscription/models/subscriptions.dart';

part 'now_playing_info.freezed.dart';

/// Metadata about the currently playing episode.
///
/// Used by the mini player to display episode information without
/// needing to fetch it from the database.
@freezed
sealed class NowPlayingInfo with _$NowPlayingInfo {
  const factory NowPlayingInfo({
    required String episodeUrl,
    required String episodeTitle,
    required String podcastTitle,
    String? artworkUrl,
    Duration? totalDuration,
    Duration? savedPosition,
    Episode? episode,
    String? itunesId,
    String? episodeGuid,
    String? feedUrl,
  }) = _NowPlayingInfo;
}

/// Builds the now-playing metadata for [episode] of [subscription].
///
/// Artwork falls back from the episode image to the podcast artwork, and a
/// missing [subscription] leaves the podcast fields empty rather than
/// blocking playback.
NowPlayingInfo nowPlayingInfoForEpisode(
  Episode episode,
  Subscription? subscription,
) {
  final durationMs = episode.durationMs;
  return NowPlayingInfo(
    episodeUrl: episode.audioUrl,
    episodeTitle: episode.title,
    podcastTitle: subscription?.title ?? '',
    artworkUrl: episode.imageUrl ?? subscription?.artworkUrl,
    totalDuration: durationMs == null
        ? null
        : Duration(milliseconds: durationMs),
    episode: episode,
    itunesId: subscription?.itunesId,
    episodeGuid: episode.guid,
    feedUrl: subscription?.feedUrl,
  );
}
