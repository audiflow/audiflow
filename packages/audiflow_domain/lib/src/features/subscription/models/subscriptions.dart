import 'package:drift/drift.dart';

/// Drift table for podcast subscriptions.
///
/// Stores user's subscribed podcasts with core metadata from iTunes Search API.
/// The itunesId serves as a unique identifier for each subscription.
class Subscriptions extends Table {
  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// iTunes collection/track ID (unique identifier from iTunes API).
  TextColumn get itunesId => text().unique()();

  /// RSS feed URL for the podcast.
  TextColumn get feedUrl => text()();

  /// The name/title of the podcast.
  TextColumn get title => text()();

  /// Name of the podcast creator or host.
  TextColumn get artistName => text()();

  /// URL to podcast artwork image (nullable).
  TextColumn get artworkUrl => text().nullable()();

  /// Text description of the podcast (nullable).
  TextColumn get description => text().nullable()();

  /// Comma-separated list of genres (stored as empty string by default).
  TextColumn get genres => text().withDefault(const Constant(''))();

  /// Whether this podcast contains explicit content.
  BoolColumn get explicit => boolean().withDefault(const Constant(false))();

  /// When the user subscribed to this podcast.
  DateTimeColumn get subscribedAt => dateTime()();

  /// Last time the podcast feed was refreshed (nullable).
  DateTimeColumn get lastRefreshedAt => dateTime().nullable()();
}
