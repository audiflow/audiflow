import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'notification_artwork_encoder.dart';

/// Downloads podcast artwork and writes per-notification image files in the
/// form chosen by the injected [NotificationArtworkEncoder].
///
/// Use [fileFor] as a `BackgroundNotificationService` artwork provider.
class NotificationArtworkFiles {
  /// [directory] is resolved lazily so a platform failure only costs the
  /// artwork, not the refresh run that constructs this object.
  NotificationArtworkFiles({
    required this._dio,
    required this._directory,
    required this._encoder,
    this._maxBytes = defaultMaxBytes,
    this._downloadTimeout = defaultDownloadTimeout,
  });

  /// Artwork URLs come from feeds; cap what a single response may buffer.
  /// Also keeps passthrough files well under iOS's 10 MB image attachment
  /// limit.
  static const defaultMaxBytes = 5 * 1024 * 1024;

  /// Stops the download itself, not just the caller's wait, so an abandoned
  /// request does not keep running in the background task.
  static const defaultDownloadTimeout = Duration(seconds: 4);

  final Dio _dio;
  final Future<Directory> Function() _directory;
  final NotificationArtworkEncoder _encoder;
  final int _maxBytes;
  final Duration _downloadTimeout;

  // Several new episodes of one podcast share artwork; fetch it once.
  final Map<String, Future<EncodedArtwork>> _artworks = {};
  Future<Directory>? _preparedDirectory;

  /// Writes the artwork for [artworkUrl] to a file owned by
  /// [notificationId] and returns its path.
  Future<String> fileFor(String artworkUrl, int notificationId) async {
    final artwork = await _artworks.putIfAbsent(
      artworkUrl,
      () => _downloadAndEncode(artworkUrl),
    );
    final directory = await (_preparedDirectory ??= _prepareDirectory());
    final file = File('${directory.path}/$notificationId.${artwork.extension}');
    await file.writeAsBytes(artwork.bytes, flush: true);
    return file.path;
  }

  // Files are consumed when a notification is posted (Android decodes the
  // bitmap, iOS moves the file), so anything left from earlier runs is stale.
  Future<Directory> _prepareDirectory() async {
    final directory = await _directory();
    if (directory.existsSync()) await directory.delete(recursive: true);
    return directory.create(recursive: true);
  }

  Future<EncodedArtwork> _downloadAndEncode(String url) async {
    final cancelToken = CancelToken();
    final timer = Timer(_downloadTimeout, cancelToken.cancel);
    try {
      final bytes = await _download(url, cancelToken);
      return await _encoder.encode(bytes);
    } finally {
      timer.cancel();
    }
  }

  Future<Uint8List> _download(String url, CancelToken cancelToken) async {
    final response = await _dio.get<ResponseBody>(
      url,
      options: Options(responseType: ResponseType.stream),
      cancelToken: cancelToken,
    );
    final body = response.data;
    if (body == null) throw StateError('Empty artwork response: $url');
    final builder = BytesBuilder(copy: false);
    await for (final chunk in body.stream) {
      builder.add(chunk);
      if (_maxBytes < builder.length) {
        cancelToken.cancel();
        throw StateError('Artwork exceeds $_maxBytes bytes: $url');
      }
    }
    if (builder.isEmpty) throw StateError('Empty artwork response: $url');
    return builder.takeBytes();
  }
}
