import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/database/app_database.dart';
import '../../../common/providers/database_provider.dart';
import '../datasources/local/podcast_view_preference_local_datasource.dart';
import '../models/episode_filter.dart';
import '../models/podcast_view_mode.dart';
import '../models/smart_playlist_sort.dart';

part 'podcast_view_preference_repository.g.dart';

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

  /// Updates smart playlist sort field and order for a podcast.
  Future<void> updateSmartPlaylistSort(
    int podcastId,
    SmartPlaylistSortField field,
    SortOrder order,
  );

  /// Updates the selected smart playlist ID for inline display.
  Future<void> updateSelectedPlaylistId(int podcastId, String? playlistId);
}

/// Data class for podcast view preferences with typed values.
class PodcastViewPreferenceData {
  const PodcastViewPreferenceData({
    required this.podcastId,
    required this.viewMode,
    required this.episodeFilter,
    required this.episodeSortOrder,
    required this.smartPlaylistSortField,
    required this.smartPlaylistSortOrder,
    this.selectedPlaylistId,
  });

  final int podcastId;
  final PodcastViewMode viewMode;
  final EpisodeFilter episodeFilter;
  final SortOrder episodeSortOrder;
  final SmartPlaylistSortField smartPlaylistSortField;
  final SortOrder smartPlaylistSortOrder;

  /// Selected smart playlist ID for inline display.
  final String? selectedPlaylistId;

  /// Default preferences for a podcast.
  factory PodcastViewPreferenceData.defaults(int podcastId) {
    return PodcastViewPreferenceData(
      podcastId: podcastId,
      viewMode: PodcastViewMode.episodes,
      episodeFilter: EpisodeFilter.all,
      episodeSortOrder: SortOrder.descending,
      smartPlaylistSortField: SmartPlaylistSortField.playlistNumber,
      smartPlaylistSortOrder: SortOrder.descending,
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

  @override
  Future<void> updateSmartPlaylistSort(
    int podcastId,
    SmartPlaylistSortField field,
    SortOrder order,
  ) {
    return _datasource.upsertPreference(
      PodcastViewPreferencesCompanion(
        podcastId: Value(podcastId),
        seasonSortField: Value(_smartPlaylistFieldToString(field)),
        seasonSortOrder: Value(_orderToString(order)),
      ),
    );
  }

  @override
  Future<void> updateSelectedPlaylistId(int podcastId, String? playlistId) {
    return _datasource.upsertPreference(
      PodcastViewPreferencesCompanion(
        podcastId: Value(podcastId),
        viewMode: const Value('seasons'),
        selectedPlaylistId: Value(playlistId),
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
      smartPlaylistSortField: _parseSmartPlaylistField(pref.seasonSortField),
      smartPlaylistSortOrder: _parseOrder(pref.seasonSortOrder),
      selectedPlaylistId: pref.selectedPlaylistId,
    );
  }

  PodcastViewMode _parseViewMode(String value) {
    return switch (value) {
      'seasons' => PodcastViewMode.smartPlaylists,
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
      'desc' => SortOrder.descending,
      _ => SortOrder.descending,
    };
  }

  String _viewModeToString(PodcastViewMode mode) {
    return switch (mode) {
      PodcastViewMode.episodes => 'episodes',
      PodcastViewMode.smartPlaylists => 'seasons',
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

  SmartPlaylistSortField _parseSmartPlaylistField(String value) {
    return switch (value) {
      'newestEpisodeDate' => SmartPlaylistSortField.newestEpisodeDate,
      'alphabetical' => SmartPlaylistSortField.alphabetical,
      _ => SmartPlaylistSortField.playlistNumber,
    };
  }

  String _smartPlaylistFieldToString(SmartPlaylistSortField field) {
    return switch (field) {
      SmartPlaylistSortField.playlistNumber => 'seasonNumber',
      SmartPlaylistSortField.newestEpisodeDate => 'newestEpisodeDate',
      SmartPlaylistSortField.alphabetical => 'alphabetical',
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
