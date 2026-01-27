import 'package:drift/drift.dart';

import '../../../features/subscription/models/subscriptions.dart';

/// Drift table for per-podcast view preferences.
///
/// Stores view mode, episode filter, and sort order for each podcast.
/// Rows are created lazily on first user interaction.
class PodcastViewPreferences extends Table {
  /// Foreign key to Subscriptions table.
  IntColumn get podcastId => integer().references(Subscriptions, #id)();

  /// View mode: 'episodes' or 'seasons'.
  TextColumn get viewMode => text().withDefault(const Constant('episodes'))();

  /// Episode filter: 'all', 'unplayed', or 'inProgress'.
  TextColumn get episodeFilter => text().withDefault(const Constant('all'))();

  /// Episode sort order: 'asc' or 'desc'.
  TextColumn get episodeSortOrder =>
      text().withDefault(const Constant('desc'))();

  /// Season sort field: 'seasonNumber', 'newestEpisodeDate', 'progress', 'alphabetical'.
  TextColumn get seasonSortField =>
      text().withDefault(const Constant('seasonNumber'))();

  /// Season sort order: 'asc' or 'desc'.
  TextColumn get seasonSortOrder => text().withDefault(const Constant('asc'))();

  @override
  Set<Column> get primaryKey => {podcastId};
}
