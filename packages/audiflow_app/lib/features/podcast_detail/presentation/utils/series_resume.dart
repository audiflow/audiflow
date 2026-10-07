import 'package:audiflow_domain/audiflow_domain.dart';

/// The episode a series hero's play button starts, in series order.
class SeriesResumeTarget {
  const SeriesResumeTarget({
    required this.data,
    required this.number,
    required this.resuming,
  });

  final SmartPlaylistEpisodeData data;

  /// Feed episode number, or the 1-based position in series order when
  /// the feed has none.
  final int number;

  /// True when [data] was started and is resumed rather than started.
  final bool resuming;
}

/// Picks the episode to continue a series with: the first started but
/// unfinished episode in series (oldest-first) order, else the first
/// unplayed one. Null when every episode is played.
SeriesResumeTarget? seriesResumeTarget(
  List<SmartPlaylistEpisodeData> episodes, {
  EpisodeSortField field = EpisodeSortField.publishedAt,
}) {
  final ordered = List.of(episodes);
  sortEpisodeData(
    ordered,
    EpisodeSortRule(field: field, order: SortOrder.ascending),
  );
  SeriesResumeTarget target(int index, {required bool resuming}) {
    final data = ordered[index];
    return SeriesResumeTarget(
      data: data,
      number: data.episode.episodeNumber ?? index + 1,
      resuming: resuming,
    );
  }

  final started = ordered.indexWhere((d) => d.progress?.isInProgress ?? false);
  if (started != -1) return target(started, resuming: true);
  final unplayed = ordered.indexWhere(
    (d) => !(d.progress?.isCompleted ?? false),
  );
  if (unplayed != -1) return target(unplayed, resuming: false);
  return null;
}
