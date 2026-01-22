import 'package:freezed_annotation/freezed_annotation.dart';

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
  }) = _NowPlayingInfo;
}
