import 'package:isar_community/isar.dart';

part 'episode.g.dart';

@collection
class Episode {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('guid')], unique: true)
  late int podcastId;

  late String guid;
  late String title;
  String? description;
  late String audioUrl;
  int? durationMs;
  DateTime? publishedAt;
  String? imageUrl;
  int? episodeNumber;
  int? seasonNumber;

  /// Rich HTML content from <content:encoded>.
  String? contentEncoded;

  /// iTunes summary (fallback for show notes).
  String? summary;

  /// Episode web page URL.
  String? link;

  /// Whether the feed marks this episode as explicit content.
  ///
  /// Sourced from the iTunes `<itunes:explicit>` element. Values `true`, `yes`,
  /// and `explicit` are treated as explicit; all other values (including absent)
  /// default to `false`.
  bool itunesExplicit = false;

  bool isFavorited = false;
  DateTime? favoritedAt;

  /// Whether this episode has been considered for auto-download enqueueing.
  ///
  /// Set to true after the auto-download path inspects the episode (regardless
  /// of whether a download was actually created — duplicates and disabled
  /// auto-download both still mark the episode processed). This makes
  /// auto-download idempotent across foreground and background sync paths so
  /// new episodes detected by either path are not lost.
  @Index()
  bool autoDownloadEnqueued = false;
}
