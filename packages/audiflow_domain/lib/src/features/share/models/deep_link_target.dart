import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../player/models/episode_with_progress.dart';

part 'deep_link_target.freezed.dart';

@freezed
sealed class DeepLinkTarget with _$DeepLinkTarget {
  const factory DeepLinkTarget.podcast({
    required String itunesId,
    required String feedUrl,
    required String title,
    String? artworkUrl,
  }) = PodcastDeepLinkTarget;

  const factory DeepLinkTarget.episode({
    required String itunesId,
    required PodcastItem episode,
    required String podcastTitle,
    String? artworkUrl,
    EpisodeWithProgress? progress,
  }) = EpisodeDeepLinkTarget;
}
