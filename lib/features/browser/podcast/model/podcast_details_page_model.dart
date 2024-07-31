import 'package:audiflow/features/browser/common/model/episode_filter_mode.dart';
import 'package:isar/isar.dart';

part 'podcast_details_page_model.g.dart';

enum PodcastDetailsPageViewMode { episodes, seasons }

@collection
class PodcastDetailsPageModel {
  PodcastDetailsPageModel({
    required int pid,
    this.viewMode = PodcastDetailsPageViewMode.episodes,
    this.episodeFilterMode = EpisodeFilterMode.none,
    this.episodesAscending = false,
    this.seasonsAscending = false,
    this.seasonEpisodesAscending = true,
  }) : id = pid;

  int get pid => id;

  final Id id;
  @enumerated
  final PodcastDetailsPageViewMode viewMode;
  @enumerated
  final EpisodeFilterMode episodeFilterMode;
  final bool episodesAscending;
  final bool seasonsAscending;
  final bool seasonEpisodesAscending;

  PodcastDetailsPageModel copyWith({
    PodcastDetailsPageViewMode? viewMode,
    EpisodeFilterMode? episodeFilterMode,
    bool? episodesAscending,
    bool? seasonsAscending,
    bool? seasonEpisodesAscending,
  }) {
    return PodcastDetailsPageModel(
      pid: id,
      viewMode: viewMode ?? this.viewMode,
      episodeFilterMode: episodeFilterMode ?? this.episodeFilterMode,
      episodesAscending: episodesAscending ?? this.episodesAscending,
      seasonsAscending: seasonsAscending ?? this.seasonsAscending,
      seasonEpisodesAscending:
          seasonEpisodesAscending ?? this.seasonEpisodesAscending,
    );
  }
}

class PodcastDetailsPageModelUpdateParam {
  const PodcastDetailsPageModelUpdateParam({
    required int pid,
    this.viewMode,
    this.episodeFilterMode,
    this.episodesAscending,
    this.seasonsAscending,
    this.seasonEpisodesAscending,
  }) : id = pid;

  int get pid => id;

  final Id id;
  final PodcastDetailsPageViewMode? viewMode;
  final EpisodeFilterMode? episodeFilterMode;
  final bool? episodesAscending;
  final bool? seasonsAscending;
  final bool? seasonEpisodesAscending;

  PodcastDetailsPageModelUpdateParam copyWith({
    PodcastDetailsPageViewMode? viewMode,
    EpisodeFilterMode? episodeFilterMode,
    bool? episodesAscending,
    bool? seasonsAscending,
    bool? seasonEpisodesAscending,
  }) {
    return PodcastDetailsPageModelUpdateParam(
      pid: id,
      viewMode: viewMode ?? this.viewMode,
      episodeFilterMode: episodeFilterMode ?? this.episodeFilterMode,
      episodesAscending: episodesAscending ?? this.episodesAscending,
      seasonsAscending: seasonsAscending ?? this.seasonsAscending,
      seasonEpisodesAscending:
          seasonEpisodesAscending ?? this.seasonEpisodesAscending,
    );
  }
}
