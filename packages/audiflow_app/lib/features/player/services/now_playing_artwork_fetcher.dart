import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart' show getCachedImageFile;

/// Looks up the file the UI image cache holds for [url], if any.
typedef CachedImageFileLookup = Future<File?> Function(String url);

/// Fetches the encoded bytes of a podcast artwork image.
///
/// The player screen and lists already render the same artwork through
/// `extended_image`, so its disk cache is consulted first and the network
/// is only used on a miss.
class NowPlayingArtworkFetcher {
  NowPlayingArtworkFetcher({
    required this._dio,
    this._cachedImageFile = getCachedImageFile,
  });

  final Dio _dio;
  final CachedImageFileLookup _cachedImageFile;

  /// Returns the encoded image bytes, or null when the server sent no body.
  /// Network failures surface as [DioException].
  Future<Uint8List?> fetch(String url) async {
    final cached = await _readCached(url);
    if (cached != null) return cached;
    final response = await _dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    final data = response.data;
    return data == null ? null : Uint8List.fromList(data);
  }

  Future<Uint8List?> _readCached(String url) async {
    try {
      final file = await _cachedImageFile(url);
      return await file?.readAsBytes();
    } on Exception {
      // A broken cache entry is not worth failing over: download instead.
      return null;
    }
  }
}
