import 'dart:convert';
import 'dart:io';

import '../../models/preset_meta.dart';
import '../../models/root_meta.dart';
import '../../models/smart_playlist_definition.dart';

/// Manages disk-based caching of split preset config files.
///
/// Cache structure mirrors the remote file layout:
/// ```
/// {cacheDir}/preset/
///   versions.json
///   meta.json
///   {presetId}/
///     meta.json
///     playlists/
///       {playlistId}.json
/// ```
class PresetCacheDatasource {
  PresetCacheDatasource({required String cacheDir})
    : _baseDir = '$cacheDir/preset';

  final String _baseDir;

  // -- versions.json --

  /// Reads cached version map ({presetId: version}).
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

  // -- preset meta --

  /// Reads cached preset meta, or null if not cached.
  Future<PresetMeta?> readPresetMeta(String presetId) async {
    final file = File('$_baseDir/$presetId/meta.json');
    if (!file.existsSync()) return null;
    final raw = await file.readAsString();
    return PresetMeta.parseJson(raw);
  }

  /// Writes preset meta to disk.
  Future<void> writePresetMeta(String presetId, PresetMeta meta) async {
    final file = File('$_baseDir/$presetId/meta.json');
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(meta.toJson()));
  }

  // -- playlist definitions --

  /// Reads a cached playlist definition, or null if not
  /// cached.
  Future<SmartPlaylistDefinition?> readPlaylist(
    String presetId,
    String playlistId,
  ) async {
    final file = File('$_baseDir/$presetId/playlists/$playlistId.json');
    if (!file.existsSync()) return null;
    final raw = await file.readAsString();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return SmartPlaylistDefinition.fromJson(json);
  }

  /// Writes a playlist definition to disk.
  Future<void> writePlaylist(
    String presetId,
    String playlistId,
    SmartPlaylistDefinition definition,
  ) async {
    final file = File('$_baseDir/$presetId/playlists/$playlistId.json');
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(definition.toJson()));
  }

  /// Deletes the entire preset cache directory.
  Future<void> clearAll() async {
    final dir = Directory(_baseDir);
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }

  // -- eviction --

  /// Removes a preset's entire cache directory and its
  /// version entry.
  Future<void> evictPreset(String presetId) async {
    final dir = Directory('$_baseDir/$presetId');
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }

    final versions = await readVersions();
    versions.remove(presetId);
    await writeVersions(versions);
  }
}
