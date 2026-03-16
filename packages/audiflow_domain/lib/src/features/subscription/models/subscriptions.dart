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
}
