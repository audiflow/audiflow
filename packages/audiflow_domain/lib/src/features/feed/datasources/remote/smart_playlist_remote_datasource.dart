import 'dart:convert';

import '../../models/pattern_meta.dart';
import '../../models/root_meta.dart';
import '../../models/smart_playlist_definition.dart';

/// Signature for an HTTP GET function returning the response
/// body.
typedef HttpGetFn = Future<String> Function(Uri url);

/// Fetches split SmartPlaylist config files from a remote
/// URL.
class SmartPlaylistRemoteDatasource {
  SmartPlaylistRemoteDatasource({
    required String baseUrl,
    required HttpGetFn httpGet,
  }) : _baseUrl = baseUrl.endsWith('/')
           ? baseUrl.substring(0, baseUrl.length - 1)
           : baseUrl,
       _httpGet = httpGet;

  final String _baseUrl;
  final HttpGetFn _httpGet;

  /// Fetches and parses root meta.json.
  Future<RootMeta> fetchRootMeta() async {
    final body = await _httpGet(Uri.parse('$_baseUrl/meta.json'));
    return RootMeta.parseJson(body);
  }

  /// Fetches and parses pattern meta.json.
  Future<PatternMeta> fetchPatternMeta(String patternId) async {
    final body = await _httpGet(Uri.parse('$_baseUrl/$patternId/meta.json'));
    return PatternMeta.parseJson(body);
  }

  /// Fetches and parses a single playlist definition.
  Future<SmartPlaylistDefinition> fetchPlaylist(
    String patternId,
    String playlistId,
  ) async {
    final body = await _httpGet(
      Uri.parse('$_baseUrl/$patternId/playlists/$playlistId.json'),
    );
    final json = jsonDecode(body) as Map<String, dynamic>;
    return SmartPlaylistDefinition.fromJson(json);
  }
}
