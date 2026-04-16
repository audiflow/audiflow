import 'package:audiflow_core/audiflow_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
import '../../settings/providers/settings_providers.dart';
import '../../settings/repositories/app_settings_repository.dart';
import '../datasources/local/play_order_preference_local_datasource.dart';

part 'play_order_preference_repository.g.dart';

/// Repository for per-scope play order preferences with cascade
/// resolution.
abstract interface class PlayOrderPreferenceRepository {
  Future<AutoPlayOrder?> getPodcastPlayOrder(int podcastId);
  Future<void> setPodcastPlayOrder(int podcastId, AutoPlayOrder? order);

  Future<AutoPlayOrder?> getPlaylistPlayOrder(int podcastId, String playlistId);
  Future<void> setPlaylistPlayOrder(
    int podcastId,
    String playlistId,
    AutoPlayOrder? order,
  );

  Future<AutoPlayOrder?> getGroupPlayOrder(
    int podcastId,
    String playlistId,
    String groupId,
  );
  Future<void> setGroupPlayOrder(
    int podcastId,
    String playlistId,
    String groupId,
    AutoPlayOrder? order,
  );

  /// Resolves effective order: podcast override -> global.
  Future<AutoPlayOrder> resolveForPodcast(int podcastId);

  /// Resolves effective order: playlist override -> global.
  Future<AutoPlayOrder> resolveForPlaylist(int podcastId, String playlistId);

  /// Resolves effective order: group -> playlist -> global.
  Future<AutoPlayOrder> resolveForGroup(
    int podcastId,
    String playlistId,
    String groupId,
  );
}

/// Implementation of [PlayOrderPreferenceRepository].
class PlayOrderPreferenceRepositoryImpl
    implements PlayOrderPreferenceRepository {
  PlayOrderPreferenceRepositoryImpl(this._datasource, this._settings);

  final PlayOrderPreferenceLocalDatasource _datasource;
  final AppSettingsRepository _settings;

  // -- Get/Set with enum conversion --

  @override
  Future<AutoPlayOrder?> getPodcastPlayOrder(int podcastId) async {
    final raw = await _datasource.getPodcastPlayOrder(podcastId);
    return _fromString(raw);
  }

  @override
  Future<void> setPodcastPlayOrder(int podcastId, AutoPlayOrder? order) {
    return _datasource.setPodcastPlayOrder(podcastId, _toStorage(order));
  }

  @override
  Future<AutoPlayOrder?> getPlaylistPlayOrder(
    int podcastId,
    String playlistId,
  ) async {
    final raw = await _datasource.getPlaylistPlayOrder(podcastId, playlistId);
    return _fromString(raw);
  }

  @override
  Future<void> setPlaylistPlayOrder(
    int podcastId,
    String playlistId,
    AutoPlayOrder? order,
  ) {
    return _datasource.setPlaylistPlayOrder(
      podcastId,
      playlistId,
      _toStorage(order),
    );
  }

  @override
  Future<AutoPlayOrder?> getGroupPlayOrder(
    int podcastId,
    String playlistId,
    String groupId,
  ) async {
    final raw = await _datasource.getGroupPlayOrder(
      podcastId,
      playlistId,
      groupId,
    );
    return _fromString(raw);
  }

  @override
  Future<void> setGroupPlayOrder(
    int podcastId,
    String playlistId,
    String groupId,
    AutoPlayOrder? order,
  ) {
    return _datasource.setGroupPlayOrder(
      podcastId,
      playlistId,
      groupId,
      _toStorage(order),
    );
  }

  // -- Cascade resolution --

  @override
  Future<AutoPlayOrder> resolveForPodcast(int podcastId) async {
    final podcast = await getPodcastPlayOrder(podcastId);
    if (_isEffective(podcast)) return podcast!;
    return _settings.getAutoPlayOrder();
  }

  @override
  Future<AutoPlayOrder> resolveForPlaylist(
    int podcastId,
    String playlistId,
  ) async {
    final playlist = await getPlaylistPlayOrder(podcastId, playlistId);
    if (_isEffective(playlist)) return playlist!;
    return _settings.getAutoPlayOrder();
  }

  @override
  Future<AutoPlayOrder> resolveForGroup(
    int podcastId,
    String playlistId,
    String groupId,
  ) async {
    final group = await getGroupPlayOrder(podcastId, playlistId, groupId);
    if (_isEffective(group)) return group!;

    final playlist = await getPlaylistPlayOrder(podcastId, playlistId);
    if (_isEffective(playlist)) return playlist!;

    return _settings.getAutoPlayOrder();
  }

  // -- Helpers --

  /// Returns true when the value is a concrete override (not null,
  /// not defaultOrder).
  bool _isEffective(AutoPlayOrder? order) =>
      order != null && order != AutoPlayOrder.defaultOrder;

  /// Converts enum to storage string. Both null and defaultOrder
  /// map to null.
  String? _toStorage(AutoPlayOrder? order) {
    if (order == null || order == AutoPlayOrder.defaultOrder) {
      return null;
    }
    return order.name;
  }

  /// Converts storage string back to enum. Returns null for
  /// unrecognised or null input.
  AutoPlayOrder? _fromString(String? raw) {
    if (raw == null) return null;
    return AutoPlayOrder.values.asNameMap()[raw];
  }
}

/// Provider for [PlayOrderPreferenceLocalDatasource].
@riverpod
PlayOrderPreferenceLocalDatasource playOrderPreferenceLocalDatasource(Ref ref) {
  final isar = ref.watch(isarProvider);
  return PlayOrderPreferenceLocalDatasource(isar);
}

/// Provider for [PlayOrderPreferenceRepository].
@riverpod
PlayOrderPreferenceRepository playOrderPreferenceRepository(Ref ref) {
  final datasource = ref.watch(playOrderPreferenceLocalDatasourceProvider);
  final settings = ref.watch(appSettingsRepositoryProvider);
  return PlayOrderPreferenceRepositoryImpl(datasource, settings);
}
