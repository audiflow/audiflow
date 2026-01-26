import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/database/app_database.dart';
import '../../../common/providers/database_provider.dart';
import '../datasources/local/podcast_view_preference_local_datasource.dart';
import '../models/season_sort.dart';

part 'podcast_view_preference_repository.g.dart';

/// View modes for the podcast detail screen.
enum PodcastViewMode {
  /// Flat list of all episodes.
  episodes,

  /// Grouped by season.
  seasons,
}

/// Filter options for episode list.
enum EpisodeFilter {
  all('All'),
  unplayed('Unplayed'),
  inProgress('In Progress');

  const EpisodeFilter(this.label);
  final String label;
}

/// Repository for managing podcast view preferences.
abstract class PodcastViewPreferenceRepository {
  /// Gets preference for a podcast, returns defaults if not set.
  Future<PodcastViewPreferenceData> getPreference(int podcastId);

  /// Watches preference for a podcast, emits defaults if not set.
  Stream<PodcastViewPreferenceData> watchPreference(int podcastId);

  /// Updates view mode for a podcast.
  Future<void> updateViewMode(int podcastId, PodcastViewMode viewMode);

  /// Updates episode filter for a podcast.
  Future<void> updateEpisodeFilter(int podcastId, EpisodeFilter filter);

  /// Updates episode sort order for a podcast.
  Future<void> updateEpisodeSortOrder(int podcastId, SortOrder order);
}

/// Data class for podcast view preferences with typed values.
class PodcastViewPreferenceData {
  const PodcastViewPreferenceData({
    required this.podcastId,
    required this.viewMode,
    required this.episodeFilter,
    required this.episodeSortOrder,
  });

  final int podcastId;
  final PodcastViewMode viewMode;
  final EpisodeFilter episodeFilter;
  final SortOrder episodeSortOrder;

  /// Default preferences for a podcast.
  factory PodcastViewPreferenceData.defaults(int podcastId) {
    return PodcastViewPreferenceData(
      podcastId: podcastId,
      viewMode: PodcastViewMode.episodes,
      episodeFilter: EpisodeFilter.all,
      episodeSortOrder: SortOrder.descending,
    );
  }
}

/// Implementation of [PodcastViewPreferenceRepository].
class PodcastViewPreferenceRepositoryImpl
    implements PodcastViewPreferenceRepository {
  PodcastViewPreferenceRepositoryImpl(this._datasource);

  final PodcastViewPreferenceLocalDatasource _datasource;

  @override
  Future<PodcastViewPreferenceData> getPreference(int podcastId) async {
    final pref = await _datasource.getPreference(podcastId);
    return _toData(podcastId, pref);
  }

  @override
  Stream<PodcastViewPreferenceData> watchPreference(int podcastId) {
    return _datasource
        .watchPreference(podcastId)
        .map((pref) => _toData(podcastId, pref));
  }

  @override
  Future<void> updateViewMode(int podcastId, PodcastViewMode viewMode) {
    return _datasource.upsertPreference(
      PodcastViewPreferencesCompanion(
        podcastId: Value(podcastId),
        viewMode: Value(_viewModeToString(viewMode)),
      ),
    );
  }

  @override
  Future<void> updateEpisodeFilter(int podcastId, EpisodeFilter filter) {
    return _datasource.upsertPreference(
      PodcastViewPreferencesCompanion(
        podcastId: Value(podcastId),
        episodeFilter: Value(_filterToString(filter)),
      ),
    );
  }

  @override
  Future<void> updateEpisodeSortOrder(int podcastId, SortOrder order) {
    return _datasource.upsertPreference(
      PodcastViewPreferencesCompanion(
        podcastId: Value(podcastId),
        episodeSortOrder: Value(_orderToString(order)),
      ),
    );
  }

  PodcastViewPreferenceData _toData(
    int podcastId,
    PodcastViewPreference? pref,
  ) {
    if (pref == null) {
      return PodcastViewPreferenceData.defaults(podcastId);
    }
    return PodcastViewPreferenceData(
      podcastId: podcastId,
      viewMode: _parseViewMode(pref.viewMode),
      episodeFilter: _parseFilter(pref.episodeFilter),
      episodeSortOrder: _parseOrder(pref.episodeSortOrder),
    );
  }

  PodcastViewMode _parseViewMode(String value) {
    return switch (value) {
      'seasons' => PodcastViewMode.seasons,
      _ => PodcastViewMode.episodes,
    };
  }

  EpisodeFilter _parseFilter(String value) {
    return switch (value) {
      'unplayed' => EpisodeFilter.unplayed,
      'inProgress' => EpisodeFilter.inProgress,
      _ => EpisodeFilter.all,
    };
  }

  SortOrder _parseOrder(String value) {
    return switch (value) {
      'asc' => SortOrder.ascending,
      _ => SortOrder.descending,
    };
  }

  String _viewModeToString(PodcastViewMode mode) {
    return switch (mode) {
      PodcastViewMode.episodes => 'episodes',
      PodcastViewMode.seasons => 'seasons',
    };
  }

  String _filterToString(EpisodeFilter filter) {
    return switch (filter) {
      EpisodeFilter.all => 'all',
      EpisodeFilter.unplayed => 'unplayed',
      EpisodeFilter.inProgress => 'inProgress',
    };
  }

  String _orderToString(SortOrder order) {
    return switch (order) {
      SortOrder.ascending => 'asc',
      SortOrder.descending => 'desc',
    };
  }
}

/// Provider for [PodcastViewPreferenceLocalDatasource].
@riverpod
PodcastViewPreferenceLocalDatasource podcastViewPreferenceLocalDatasource(
  Ref ref,
) {
  final db = ref.watch(databaseProvider);
  return PodcastViewPreferenceLocalDatasource(db);
}

/// Provider for [PodcastViewPreferenceRepository].
@riverpod
PodcastViewPreferenceRepository podcastViewPreferenceRepository(Ref ref) {
  final datasource = ref.watch(podcastViewPreferenceLocalDatasourceProvider);
  return PodcastViewPreferenceRepositoryImpl(datasource);
}
