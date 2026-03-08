import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../controllers/podcast_detail_controller.dart';

part 'podcast_detail_state.freezed.dart';

/// Consolidated view state for the podcast detail screen.
///
/// Merges data from multiple providers into a single snapshot
/// so the screen can watch one provider instead of 7+.
@freezed
sealed class PodcastDetailViewState with _$PodcastDetailViewState {
  const factory PodcastDetailViewState({
    required ParsedFeed feed,
    required PodcastViewMode viewMode,
    required EpisodeFilter episodeFilter,
    required SortOrder episodeSortOrder,
    required List<PodcastItem> filteredEpisodes,
    required EpisodeProgressMap progressMap,
    required List<SmartPlaylist> smartPlaylists,
    required bool isSubscribed,
    required bool hasSmartPlaylistView,
    SmartPlaylist? activePlaylist,
    String? feedImageUrl,
    int? subscriptionId,
    SmartPlaylistPatternConfig? pattern,
  }) = _PodcastDetailViewState;
}
