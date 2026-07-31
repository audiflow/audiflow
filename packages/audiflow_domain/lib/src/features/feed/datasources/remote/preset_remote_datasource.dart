import 'dart:convert';

import '../../models/preset_meta.dart';
import '../../models/root_meta.dart';
import '../../models/smart_playlist_definition.dart';

/// Signature for an HTTP GET function returning the response
/// body.
typedef HttpGetFn = Future<String> Function(Uri url);

/// Fetches split preset config files from a remote URL.
class PresetRemoteDatasource {
  PresetRemoteDatasource({required String baseUrl, required this._httpGet})
    : _baseUrl = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl;

  final String _baseUrl;
  final HttpGetFn _httpGet;

  /// Fetches and parses root meta.json.
  Future<RootMeta> fetchRootMeta() async {
    final body = await _httpGet(Uri.parse('$_baseUrl/meta.json'));
    return RootMeta.parseJson(body);
  }

  /// Fetches and parses preset meta.json.
  Future<PresetMeta> fetchPresetMeta(String presetId) async {
    final body = await _httpGet(Uri.parse('$_baseUrl/$presetId/meta.json'));
    return PresetMeta.parseJson(body);
  }

  /// Fetches and parses a single playlist definition.
  Future<SmartPlaylistDefinition> fetchPlaylist(
    String presetId,
    String playlistId,
  ) async {
    final body = await _httpGet(
      Uri.parse('$_baseUrl/$presetId/playlists/$playlistId.json'),
    );
    final json = jsonDecode(body) as Map<String, dynamic>;
    return SmartPlaylistDefinition.fromJson(json);
  }
}
