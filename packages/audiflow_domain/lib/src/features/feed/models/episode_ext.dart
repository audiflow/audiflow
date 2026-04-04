import 'package:audiflow_podcast/audiflow_podcast.dart';

import 'episode.dart';

/// Extension to convert a persisted [Episode] into a [PodcastItem] for UI
/// display.  Centralises the mapping so that every call site carries all
/// available fields (description, summary, contentEncoded, link, etc.).
extension EpisodeToPodcastItem on Episode {
  PodcastItem toPodcastItem({String feedUrl = ''}) {
    return PodcastItem(
      parsedAt: DateTime.now(),
      sourceUrl: feedUrl,
      title: title,
      description: description ?? '',
      summary: summary,
      contentEncoded: contentEncoded,
      link: link,
      publishDate: publishedAt,
      duration: durationMs != null ? Duration(milliseconds: durationMs!) : null,
      enclosureUrl: audioUrl,
      guid: guid,
      episodeNumber: episodeNumber,
      seasonNumber: seasonNumber,
      images: imageUrl != null ? [PodcastImage(url: imageUrl!)] : const [],
    );
  }
}
