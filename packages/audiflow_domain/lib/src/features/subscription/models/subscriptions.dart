import 'package:isar_community/isar.dart';

part 'subscriptions.g.dart';

@collection
class Subscription {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String itunesId;

  late String feedUrl;
  late String title;
  late String artistName;
  String? artworkUrl;
  String? description;
  String genres = '';
  bool explicit = false;
  late DateTime subscribedAt;
  DateTime? lastRefreshedAt;

  /// Whether this is a cache-only entry (not user-subscribed).
  ///
  /// When true, the podcast was visited but not subscribed to.
  /// Episodes are persisted for smart playlist resolution.
  /// Promoted to a real subscription via [isCached] = false.
  bool isCached = false;

  /// Last time the user accessed this podcast detail page.
  ///
  /// Used for cache eviction of non-subscribed podcasts.
  DateTime? lastAccessedAt;

  /// Whether new episodes should be auto-downloaded during background refresh.
  bool autoDownload = false;

  /// When the RSS channel metadata was last read into this subscription.
  ///
  /// Null means the feed has never been parsed under the backfill policy, so
  /// the next refresh asks unconditionally to obtain artwork. Set on every
  /// successful parse, including one whose channel carried no image, so a
  /// feed without artwork does not disable conditional requests forever.
  DateTime? feedMetadataSyncedAt;

  /// HTTP ETag header from the last successful feed fetch.
  ///
  /// Sent as `If-None-Match` on subsequent requests to avoid
  /// re-downloading unchanged RSS feeds.
  String? httpEtag;

  /// HTTP Last-Modified header from the last successful feed fetch.
  ///
  /// Sent as `If-Modified-Since` on subsequent requests to avoid
  /// re-downloading unchanged RSS feeds.
  String? httpLastModified;
}
