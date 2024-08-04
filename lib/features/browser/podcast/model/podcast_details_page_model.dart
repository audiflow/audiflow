import 'package:audiflow/features/browser/common/model/episode_filter_mode.dart';
import 'package:audiflow/features/browser/common/model/season_filter_mode.dart';
import 'package:isar/isar.dart';

part 'podcast_details_page_model.g.dart';

enum PodcastDetailsPageViewMode { episodes, seasons }

@collection
class PodcastDetailsPageModel {
  PodcastDetailsPageModel({
    required this.pid,
    this.viewMode = PodcastDetailsPageViewMode.episodes,
    this.episodeFilterMode = EpisodeFilterMode.all,
    this.episodesAscending = false,
    this.seasonFilterMode = SeasonFilterMode.all,
    this.seasonsAscending = false,
    this.seasonEpisodeFilterMode = EpisodeFilterMode.all,
    this.seasonEpisodesAscending = true,
  });

  Id get id => pid;

  final int pid;
  @enumerated
  final PodcastDetailsPageViewMode viewMode;
  @enumerated
  final EpisodeFilterMode episodeFilterMode;
  final bool episodesAscending;
  @enumerated
  final SeasonFilterMode seasonFilterMode;
  final bool seasonsAscending;
  @enumerated
  final EpisodeFilterMode seasonEpisodeFilterMode;
  final bool seasonEpisodesAscending;

  PodcastDetailsPageModel copyWith({
    PodcastDetailsPageViewMode? viewMode,
    EpisodeFilterMode? episodeFilterMode,
    bool? episodesAscending,
    SeasonFilterMode? seasonFilterMode,
    bool? seasonsAscending,
    EpisodeFilterMode? seasonEpisodeFilterMode,
    bool? seasonEpisodesAscending,
  }) {
    return PodcastDetailsPageModel(
      pid: id,
      viewMode: viewMode ?? this.viewMode,
      episodeFilterMode: episodeFilterMode ?? this.episodeFilterMode,
      episodesAscending: episodesAscending ?? this.episodesAscending,
      seasonFilterMode: seasonFilterMode ?? this.seasonFilterMode,
      seasonsAscending: seasonsAscending ?? this.seasonsAscending,
      seasonEpisodeFilterMode:
          seasonEpisodeFilterMode ?? this.seasonEpisodeFilterMode,
      seasonEpisodesAscending:
          seasonEpisodesAscending ?? this.seasonEpisodesAscending,
    );
  }

  @override
  String toString() {
    return 'PodcastDetailsPageModel('
        'pid: $pid, '
        'viewMode: $viewMode, '
        'episodeFilterMode: $episodeFilterMode, '
        'episodesAscending: $episodesAscending, '
        'seasonFilterMode: $seasonFilterMode, '
        'seasonsAscending: $seasonsAscending, '
        'seasonEpisodeFilterMode: $seasonEpisodeFilterMode, '
        'seasonEpisodesAscending: $seasonEpisodesAscending)';
  }
}

class PodcastDetailsPageModelUpdateParam {
  const PodcastDetailsPageModelUpdateParam({
    required int pid,
    this.viewMode,
    this.episodeFilterMode,
    this.episodesAscending,
    this.seasonFilterMode,
    this.seasonsAscending,
    this.seasonEpisodeFilterMode,
    this.seasonEpisodesAscending,
  }) : id = pid;

  int get pid => id;

  final Id id;
  final PodcastDetailsPageViewMode? viewMode;
  final EpisodeFilterMode? episodeFilterMode;
  final bool? episodesAscending;
  final SeasonFilterMode? seasonFilterMode;
  final bool? seasonsAscending;
  final EpisodeFilterMode? seasonEpisodeFilterMode;
  final bool? seasonEpisodesAscending;

  PodcastDetailsPageModelUpdateParam copyWith({
    PodcastDetailsPageViewMode? viewMode,
    EpisodeFilterMode? episodeFilterMode,
    bool? episodesAscending,
    SeasonFilterMode? seasonFilterMode,
    bool? seasonsAscending,
    EpisodeFilterMode? seasonEpisodeFilterMode,
    bool? seasonEpisodesAscending,
  }) {
    return PodcastDetailsPageModelUpdateParam(
      pid: id,
      viewMode: viewMode ?? this.viewMode,
      episodeFilterMode: episodeFilterMode ?? this.episodeFilterMode,
      episodesAscending: episodesAscending ?? this.episodesAscending,
      seasonFilterMode: seasonFilterMode ?? this.seasonFilterMode,
      seasonsAscending: seasonsAscending ?? this.seasonsAscending,
      seasonEpisodeFilterMode:
          seasonEpisodeFilterMode ?? this.seasonEpisodeFilterMode,
      seasonEpisodesAscending:
          seasonEpisodesAscending ?? this.seasonEpisodesAscending,
    );
  }
}
