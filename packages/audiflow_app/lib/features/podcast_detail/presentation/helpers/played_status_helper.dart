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

  // Family-level invalidate covers every keyed instance any open
  // screen might watch (episode by audio URL, podcast batch by feed
  // URL, smart playlist by episode-id list).
  container
    ..invalidate(episodeProgressProvider)
    ..invalidate(podcastEpisodeProgressProvider)
    ..invalidate(smartPlaylistEpisodesProvider);
}
