import 'package:audiflow_domain/audiflow_domain.dart' show PodcastViewMode;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_view_mode_controller.g.dart';

/// Controller for the podcast detail screen view mode toggle.
@riverpod
class PodcastViewModeController extends _$PodcastViewModeController {
  @override
  PodcastViewMode build(String podcastId) => PodcastViewMode.episodes;

  /// Sets the view mode to episodes (flat list).
  void setEpisodes() => state = PodcastViewMode.episodes;

  /// Sets the view mode to seasons (grouped view).
  void setSeasons() => state = PodcastViewMode.seasons;

  /// Toggles between episodes and seasons view modes.
  void toggle() {
    state = switch (state) {
      PodcastViewMode.episodes => PodcastViewMode.seasons,
      PodcastViewMode.seasons => PodcastViewMode.episodes,
    };
  }
}
