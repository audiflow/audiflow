import 'dart:convert';
import 'dart:io';

import '../../models/pattern_meta.dart';
import '../../models/root_meta.dart';
import '../../models/smart_playlist_definition.dart';

/// Manages disk-based caching of split SmartPlaylist config
/// files.
///
/// Cache structure mirrors the remote file layout:
/// ```
/// {cacheDir}/smartplaylist/
///   versions.json
///   meta.json
///   {patternId}/
///     meta.json
///     playlists/
///       {playlistId}.json
/// ```
class SmartPlaylistCacheDatasource {
  SmartPlaylistCacheDatasource({required String cacheDir})
    : _baseDir = '$cacheDir/smartplaylist';

  final String _baseDir;

  // -- versions.json --

  /// Reads cached version map ({patternId: version}).
  Future<Map<String, int>> readVersions() async {
    final file = File('$_baseDir/versions.json');
    if (!file.existsSync()) return {};
    final raw = await file.readAsString();
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return data.map((k, v) => MapEntry(k, v as int));
  }

  /// Writes version map to disk.
  Future<void> writeVersions(Map<String, int> versions) async {
    final file = File('$_baseDir/versions.json');
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(versions));
  }

  // -- root meta.json --

  /// Reads cached root meta, or null if not cached.
  Future<RootMeta?> readRootMeta() async {
    final file = File('$_baseDir/meta.json');
    if (!file.existsSync()) return null;
    final raw = await file.readAsString();
    return RootMeta.parseJson(raw);
  }

  /// Writes root meta to disk.
  Future<void> writeRootMeta(RootMeta meta) async {
    final file = File('$_baseDir/meta.json');
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(meta.toJson()));
  }

  // -- pattern meta --

  /// Reads cached pattern meta, or null if not cached.
  Future<PatternMeta?> readPatternMeta(String patternId) async {
    final file = File('$_baseDir/$patternId/meta.json');
    if (!file.existsSync()) return null;
    final raw = await file.readAsString();
    return PatternMeta.parseJson(raw);
  }

  /// Writes pattern meta to disk.
  Future<void> writePatternMeta(String patternId, PatternMeta meta) async {
    final file = File('$_baseDir/$patternId/meta.json');
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(meta.toJson()));
  }

  // -- playlist definitions --

  /// Reads a cached playlist definition, or null if not
  /// cached.
  Future<SmartPlaylistDefinition?> readPlaylist(
    String patternId,
    String playlistId,
  ) async {
    final file = File('$_baseDir/$patternId/playlists/$playlistId.json');
    if (!file.existsSync()) return null;
    final raw = await file.readAsString();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return SmartPlaylistDefinition.fromJson(json);
  }

  /// Writes a playlist definition to disk.
  Future<void> writePlaylist(
    String patternId,
    String playlistId,
    SmartPlaylistDefinition definition,
  ) async {
    final file = File('$_baseDir/$patternId/playlists/$playlistId.json');
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(definition.toJson()));
  }

  // -- eviction --

  /// Removes a pattern's entire cache directory and its
  /// version entry.
  Future<void> evictPattern(String patternId) async {
    final dir = Directory('$_baseDir/$patternId');
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }

    final versions = await readVersions();
    versions.remove(patternId);
    await writeVersions(versions);
  }
}
