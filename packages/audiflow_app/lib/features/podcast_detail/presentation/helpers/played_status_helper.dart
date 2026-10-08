import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/podcast_detail_controller.dart';

/// Toggles an episode's played state and refreshes cached progress.
///
/// Takes a [ProviderContainer] instead of a [WidgetRef] because marking an
/// episode played can rebuild the calling list and unmount the tile before
/// the awaits finish; a [WidgetRef] from an unmounted widget throws on use.
Future<void> togglePlayedStatus(
  ProviderContainer container, {
  required String audioUrl,
  required bool isCurrentlyCompleted,
}) async {
  final episodeRepo = container.read(episodeRepositoryProvider);
  final episode = await episodeRepo.getByAudioUrl(audioUrl);
  if (episode == null) return;

  final historyService = container.read(playbackHistoryServiceProvider);
  if (isCurrentlyCompleted) {
    await historyService.markIncomplete(episode.id);
  } else {
    await historyService.markCompleted(episode.id);
  }

  _refreshPlayedState(container);
}

/// Marks every episode in [episodeIds] played (or not played) and
/// refreshes cached progress. Returns how many episodes were marked.
///
/// Takes a [ProviderContainer] for the same reason as
/// [togglePlayedStatus]: the list rebuilds while the writes run.
Future<int> setEpisodesPlayedStatus(
  ProviderContainer container, {
  required Iterable<int> episodeIds,
  required bool played,
}) async {
  final historyService = container.read(playbackHistoryServiceProvider);
  try {
    return played
        ? await historyService.markAllCompleted(episodeIds)
        : await historyService.markAllIncomplete(episodeIds);
  } finally {
    // A batch that fails partway has still changed some episodes; refresh
    // so open lists show what was actually written.
    _refreshPlayedState(container);
  }
}

/// Family-level invalidate covers every keyed instance any open screen
/// might watch (episode by audio URL, podcast batch by feed URL, smart
/// playlist by episode-id list), and the filtered episode list, which
/// reads history once and would keep showing episodes an Unplayed or
/// In progress filter should now drop.
void _refreshPlayedState(ProviderContainer container) {
  container
    ..invalidate(episodeProgressProvider)
    ..invalidate(podcastEpisodeProgressProvider)
    ..invalidate(filteredSortedEpisodesProvider)
    ..invalidate(smartPlaylistEpisodesProvider);
}

/// [setEpisodesPlayedStatus] for every stored episode of [podcastId].
Future<int> setPodcastPlayedStatus(
  ProviderContainer container, {
  required int podcastId,
  required bool played,
}) async {
  final episodes = await container
      .read(episodeRepositoryProvider)
      .getByPodcastId(podcastId);
  return setEpisodesPlayedStatus(
    container,
    episodeIds: episodes.map((episode) => episode.id),
    played: played,
  );
}
