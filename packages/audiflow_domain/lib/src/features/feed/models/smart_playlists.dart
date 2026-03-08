import 'package:drift/drift.dart';

import '../../subscription/models/subscriptions.dart';

/// Drift table for persisted smart playlist metadata.
///
/// Uses composite primary key (podcastId, playlistNumber) for natural
/// joins with Episodes table without requiring FK modifications.
///
/// Generates `SmartPlaylistEntity` data class to avoid conflict with
/// `SmartPlaylist` model.
@DataClassName('SmartPlaylistEntity')
class SmartPlaylists extends Table {
  /// Foreign key to Subscriptions table (part of composite PK).
  IntColumn get podcastId => integer().references(Subscriptions, #id)();

  /// Playlist number matching episode.seasonNumber (part of
  /// composite PK).
  /// Use 0 for ungrouped/extras playlists like "bangai-hen".
  IntColumn get playlistNumber => integer().named('season_number')();

  /// Display name (e.g., "Lincoln arc", "bangai-hen").
  TextColumn get displayName => text()();

  /// Sort key for ordering smart playlists (typically max
  /// episodeNumber in playlist).
  IntColumn get sortKey => integer()();

  /// Resolver type that generated this smart playlist (e.g., "rss").
  TextColumn get resolverType => text()();

  /// Thumbnail URL from the latest episode in this smart playlist.
  TextColumn get thumbnailUrl => text().nullable()();

  /// Whether this smart playlist groups episodes by year.
  BoolColumn get yearGrouped => boolean().withDefault(const Constant(false))();

  /// Playlist structure ('split' or 'grouped').
  TextColumn get playlistStructure =>
      text().withDefault(const Constant('split'))();

  /// Year binding mode ('none', 'pinToYear', 'splitByYear').
  TextColumn get yearHeaderMode => text().withDefault(const Constant('none'))();

  @override
  Set<Column> get primaryKey => {podcastId, playlistNumber};

  @override
  String get tableName => 'seasons';
}
