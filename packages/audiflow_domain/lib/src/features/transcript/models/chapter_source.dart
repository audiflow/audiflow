/// Where an episode's stored chapters came from.
///
/// An episode keeps chapters from one source at a time. Higher [priority]
/// wins: chapters from a lower-priority source never replace stored ones
/// from a higher-priority source.
///
/// Declaration order is not the priority order: [podlove] comes first
/// because Isar reads a missing value as the first enum value, and rows
/// written before sources were recorded all came from `<psc:chapters>`.
enum ChapterSource {
  /// `<psc:chapters>` (Podlove Simple Chapters) inside the feed.
  podlove(priority: 1),

  /// Derived from timestamps in the episode description.
  description(priority: 0),

  /// JSON file linked by `<podcast:chapters>`.
  podcastChaptersJson(priority: 2);

  const ChapterSource({required this.priority});

  final int priority;

  /// Whether chapters from this source may replace stored chapters
  /// from [stored].
  bool canReplace(ChapterSource stored) => stored.priority <= priority;
}
