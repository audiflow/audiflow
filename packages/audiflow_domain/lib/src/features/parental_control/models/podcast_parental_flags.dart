import 'package:isar_community/isar.dart';

part 'podcast_parental_flags.g.dart';

/// Per-podcast parental-control flags persisted in Isar.
///
/// Each podcast has at most one row, enforced by the unique index on
/// [itunesId]. Rows are pruned when a subscription is removed.
@collection
class PodcastParentalFlags {
  Id id = Isar.autoIncrement;

  /// iTunes podcast ID — unique; one row per podcast at most.
  @Index(unique: true)
  late int itunesId;

  /// When true, explicit-tagged episodes are hidden for this podcast.
  bool hideExplicitEpisodes = false;
}
