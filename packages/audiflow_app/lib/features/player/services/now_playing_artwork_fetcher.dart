import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart' show getCachedImageFile;

/// Largest encoded artwork accepted before it is decoded.
///
/// Podcast artwork runs to a few hundred KB even at 3000 px. A response
/// past this bound is a broken feed or a hostile server, and buffering it
/// would cost the memory this feature exists to save (#451, #453).
const nowPlayingArtworkMaxEncodedBytes = 8 * 1024 * 1024;

/// Looks up the file the UI image cache holds for [url], if any.
typedef CachedImageFileLookup = Future<File?> Function(String url);

/// Fetches the encoded bytes of a podcast artwork image.
///
/// The player screen and lists already render the same artwork through
/// `extended_image`, so its disk cache is consulted first and the network
/// is only used on a miss. Input past [nowPlayingArtworkMaxEncodedBytes]
/// is refused rather than buffered.
class NowPlayingArtworkFetcher {
  NowPlayingArtworkFetcher({
    required this._dio,
    this._cachedImageFile = getCachedImageFile,
    this._maxEncodedBytes = nowPlayingArtworkMaxEncodedBytes,
  });

  final Dio _dio;
  final CachedImageFileLookup _cachedImageFile;
  final int _maxEncodedBytes;

  /// Returns the encoded image bytes, or null when there is no usable body
  /// or it exceeds the size bound. Network failures surface as
  /// [DioException].
  Future<Uint8List?> fetch(String url) async {
    final cached = await _readCached(url);
    if (cached != null) return cached;
    // Streamed so an oversized body is abandoned mid-transfer instead of
    // being collected in full and only then measured.
    final response = await _dio.get<ResponseBody>(
      url,
      options: Options(responseType: ResponseType.stream),
    );
    return _readBounded(response);
  }

  Future<Uint8List?> _readBounded(Response<ResponseBody> response) async {
    final body = response.data;
    if (body == null || _declaredSizeIsTooLarge(response.headers)) return null;
    final builder = BytesBuilder(copy: false);
    await for (final chunk in body.stream) {
      builder.add(chunk);
      if (_maxEncodedBytes < builder.length) return null;
    }
    return builder.isEmpty ? null : builder.takeBytes();
  }

  bool _declaredSizeIsTooLarge(Headers headers) {
    final declared = int.tryParse(
      headers.value(Headers.contentLengthHeader) ?? '',
    );
    return declared != null && _maxEncodedBytes < declared;
  }

  Future<Uint8List?> _readCached(String url) async {
    try {
      final file = await _cachedImageFile(url);
      if (file == null) return null;
      // The UI cache imposes no per-file bound, so an oversized entry is
      // treated as a miss and the bounded download path runs instead.
      if (_maxEncodedBytes < await file.length()) return null;
      return await file.readAsBytes();
    } on Exception {
      // A broken cache entry is not worth failing over: download instead.
      return null;
    }
  }
}
