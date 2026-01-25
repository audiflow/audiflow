import 'package:audiflow_domain/patterns.dart';
import 'package:audiflow_podcast/parser.dart';

/// Converts a [PodcastItem] from RSS parsing to [EpisodeData] for extractors.
SimpleEpisodeData toEpisode(PodcastItem item) {
  return SimpleEpisodeData(
    title: item.title,
    description: item.description.isEmpty ? null : item.description,
    seasonNumber: item.seasonNumber,
    episodeNumber: item.episodeNumber,
  );
}
