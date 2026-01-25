import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_podcast/audiflow_podcast.dart';

/// Converts a [PodcastItem] from RSS parsing to an [Episode] for extractors.
///
/// Stub values are used for database-only fields (id, podcastId).
Episode toEpisode(PodcastItem item) {
  return Episode(
    id: 0,
    podcastId: 0,
    guid: item.guid ?? '',
    title: item.title,
    audioUrl: item.enclosureUrl ?? '',
    description: item.description.isEmpty ? null : item.description,
    seasonNumber: item.seasonNumber,
    episodeNumber: item.episodeNumber,
    publishedAt: item.publishDate,
  );
}
