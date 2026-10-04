import 'package:audiflow_podcast/audiflow_podcast.dart';

import '../models/episode_chapter.dart';

const _parser = DescriptionChaptersParser();

/// Derives chapters from an episode's show notes.
///
/// Tries [description] first and falls back to [contentEncoded], since some
/// feeds keep the full notes, timestamp list included, only in
/// `<content:encoded>`. Returns an empty list when neither has a qualifying
/// timestamp list.
List<PodcastChapter> deriveDescriptionChapters({
  required String? description,
  String? contentEncoded,
  Duration? duration,
}) {
  for (final text in [description, contentEncoded]) {
    if (text == null || text.isEmpty) continue;
    final chapters = _parser.parse(text, episodeDuration: duration);
    if (chapters.isNotEmpty) return chapters;
  }
  return const [];
}

/// Builds chapter rows for [episodeId] from parsed [chapters].
List<EpisodeChapter> toEpisodeChapters(
  int episodeId,
  List<PodcastChapter> chapters, {
  String? sourceUrl,
}) => [
  for (final (index, chapter) in chapters.indexed)
    EpisodeChapter()
      ..episodeId = episodeId
      ..sortOrder = index
      ..title = chapter.title
      ..startMs = chapter.startTime.inMilliseconds
      ..endMs = chapter.endTime?.inMilliseconds
      ..url = chapter.url
      ..imageUrl = chapter.imageUrl
      ..sourceUrl = sourceUrl,
];
