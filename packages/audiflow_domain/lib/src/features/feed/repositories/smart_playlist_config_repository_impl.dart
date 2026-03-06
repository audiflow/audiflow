import '../datasources/local/smart_playlist_cache_datasource.dart';
import '../datasources/remote/smart_playlist_remote_datasource.dart';
import '../models/pattern_summary.dart';
import '../models/root_meta.dart';
import '../models/smart_playlist_definition.dart';
import '../models/smart_playlist_pattern_config.dart';
import '../services/config_assembler.dart';
import 'smart_playlist_config_repository.dart';

/// Implementation of [SmartPlaylistConfigRepository] with
/// disk caching, version-based invalidation, and concurrent
/// request deduplication.
class SmartPlaylistConfigRepositoryImpl
    implements SmartPlaylistConfigRepository {
  SmartPlaylistConfigRepositoryImpl({
    required SmartPlaylistRemoteDatasource remote,
    required SmartPlaylistCacheDatasource cache,
  }) : _remote = remote,
       _cache = cache;

  final SmartPlaylistRemoteDatasource _remote;
  final SmartPlaylistCacheDatasource _cache;
  final Map<String, Future<SmartPlaylistPatternConfig>> _inFlight = {};
  List<PatternSummary> _summaries = [];

  @override
  Future<RootMeta> fetchRootMeta() async {
    try {
      final meta = await _remote.fetchRootMeta();
      await _cache.writeRootMeta(meta);
      return meta;
    } on Object {
      final cached = await _cache.readRootMeta();
      if (cached != null) return cached;
      return const RootMeta(dataVersion: 1, schemaVersion: 1, patterns: []);
    }
  }

  @override
  Future<SmartPlaylistPatternConfig> getConfig(PatternSummary summary) async {
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

  Future<SmartPlaylistPatternConfig> _getConfigInternal(
    PatternSummary summary,
  ) async {
    final versions = await _cache.readVersions();
    final cachedVersion = versions[summary.id];

    if (cachedVersion == summary.dataVersion) {
      final config = await _tryLoadFromCache(summary.id);
      if (config != null) return config;
    }

    return _fetchAndCache(summary, versions);
  }

  Future<SmartPlaylistPatternConfig?> _tryLoadFromCache(
    String patternId,
  ) async {
    try {
      final meta = await _cache.readPatternMeta(patternId);
      if (meta == null) return null;

      final playlists = <SmartPlaylistDefinition>[];
      for (final playlistId in meta.playlists) {
        final playlist = await _cache.readPlaylist(patternId, playlistId);
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
      await _cache.evictPattern(patternId);
      return null;
    }
  }

  Future<SmartPlaylistPatternConfig> _fetchAndCache(
    PatternSummary summary,
    Map<String, int> versions,
  ) async {
    final meta = await _remote.fetchPatternMeta(summary.id);
    await _cache.writePatternMeta(summary.id, meta);

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
  PatternSummary? findMatchingPattern(String? podcastGuid, String feedUrl) {
    for (final summary in _summaries) {
      if (feedUrl.contains(summary.feedUrlHint)) {
        return summary;
      }
    }
    return null;
  }

  @override
  Future<void> reconcileCache(List<PatternSummary> latest) async {
    final versions = await _cache.readVersions();
    final latestMap = {for (final s in latest) s.id: s.dataVersion};

    for (final cachedId in versions.keys.toList()) {
      if (!latestMap.containsKey(cachedId)) {
        await _cache.evictPattern(cachedId);
      }
    }

    for (final summary in latest) {
      final cachedVersion = versions[summary.id];
      if (cachedVersion != null && cachedVersion != summary.dataVersion) {
        await _cache.evictPattern(summary.id);
      }
    }
  }

  @override
  void setPatternSummaries(List<PatternSummary> summaries) {
    _summaries = summaries;
  }
}
