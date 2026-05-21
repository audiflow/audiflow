import 'package:logger/logger.dart';

import '../datasources/local/preset_cache_datasource.dart';
import '../datasources/remote/preset_remote_datasource.dart';
import '../models/preset_config.dart';
import '../models/preset_summary.dart';
import '../models/root_meta.dart';
import '../models/smart_playlist_definition.dart';
import '../services/config_assembler.dart';
import 'preset_config_repository.dart';

/// Implementation of [PresetConfigRepository] with disk caching,
/// version-based invalidation, and concurrent request deduplication.
class PresetConfigRepositoryImpl implements PresetConfigRepository {
  PresetConfigRepositoryImpl({
    required PresetRemoteDatasource remote,
    required PresetCacheDatasource cache,
    Logger? logger,
  }) : _remote = remote,
       _cache = cache,
       _logger = logger;

  final PresetRemoteDatasource _remote;
  final PresetCacheDatasource _cache;
  final Logger? _logger;
  final Map<String, Future<PresetConfig>> _inFlight = {};
  List<PresetSummary> _summaries = [];

  @override
  Future<RootMeta> fetchRootMeta() async {
    try {
      final meta = await _remote.fetchRootMeta();
      await _cache.writeRootMeta(meta);
      return meta;
    } on Object {
      final cached = await _cache.readRootMeta();
      if (cached != null) return cached;
      return const RootMeta(dataVersion: 1, schemaVersion: 1, presets: []);
    }
  }

  @override
  Future<PresetConfig> getConfig(PresetSummary summary) async {
    final existing = _inFlight[summary.id];
    if (existing != null) return existing;

    final future = _getConfigInternal(summary);
    _inFlight[summary.id] = future;
    try {
      return await future;
    } finally {
      _inFlight.remove(summary.id);
    }
  }

  Future<PresetConfig> _getConfigInternal(PresetSummary summary) async {
    final versions = await _cache.readVersions();
    final cachedVersion = versions[summary.id];

    if (cachedVersion == summary.dataVersion) {
      _logger?.d(
        'cache hit for preset="${summary.id}" '
        '(displayName="${summary.displayName}", '
        'dataVersion=${summary.dataVersion}); skipping remote fetch',
      );
      final config = await _tryLoadFromCache(summary.id);
      if (config != null) return config;
    } else {
      _logger?.d(
        'cache miss for preset="${summary.id}" '
        '(cached=$cachedVersion, latest=${summary.dataVersion}); '
        'will re-fetch',
      );
    }

    return _fetchAndCache(summary, versions);
  }

  Future<PresetConfig?> _tryLoadFromCache(String presetId) async {
    try {
      final meta = await _cache.readPresetMeta(presetId);
      if (meta == null) return null;

      final playlists = <SmartPlaylistDefinition>[];
      for (final playlistId in meta.playlists) {
        final playlist = await _cache.readPlaylist(presetId, playlistId);
        if (playlist == null) return null;
        playlists.add(playlist);
      }

      if (playlists.length != meta.playlists.length) {
        return null;
      }
      return ConfigAssembler.assemble(meta, playlists);
    } on Object {
      // Stale or corrupted cache; evict and fall through to
      // re-fetch from remote.
      await _cache.evictPreset(presetId);
      return null;
    }
  }

  Future<PresetConfig> _fetchAndCache(
    PresetSummary summary,
    Map<String, int> versions,
  ) async {
    final meta = await _remote.fetchPresetMeta(summary.id);
    await _cache.writePresetMeta(summary.id, meta);

    final playlists = <SmartPlaylistDefinition>[];
    for (final playlistId in meta.playlists) {
      final playlist = await _remote.fetchPlaylist(summary.id, playlistId);
      await _cache.writePlaylist(summary.id, playlistId, playlist);
      playlists.add(playlist);
    }

    versions[summary.id] = summary.dataVersion;
    await _cache.writeVersions(versions);

    return ConfigAssembler.assemble(meta, playlists);
  }

  @override
  PresetSummary? findMatchingPreset(String? podcastGuid, String feedUrl) {
    for (final summary in _summaries) {
      if (feedUrl.contains(summary.feedUrlHint)) {
        return summary;
      }
    }
    return null;
  }

  @override
  Future<void> reconcileCache(List<PresetSummary> latest) async {
    final versions = await _cache.readVersions();
    final latestMap = {for (final s in latest) s.id: s.dataVersion};

    for (final cachedId in versions.keys.toList()) {
      if (!latestMap.containsKey(cachedId)) {
        await _cache.evictPreset(cachedId);
      }
    }

    for (final summary in latest) {
      final cachedVersion = versions[summary.id];
      if (cachedVersion != null && cachedVersion != summary.dataVersion) {
        await _cache.evictPreset(summary.id);
      }
    }
  }

  @override
  void setPresetSummaries(List<PresetSummary> summaries) {
    _summaries = summaries;
  }

  @override
  Future<void> clearDiskCache() async {
    await _cache.clearAll();
    _inFlight.clear();
  }
}
