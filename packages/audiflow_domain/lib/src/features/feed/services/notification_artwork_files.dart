import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';

/// Downloads podcast artwork and writes notification-sized thumbnails.
///
/// Use [fileFor] as a `BackgroundNotificationService` artwork provider.
class NotificationArtworkFiles {
  /// [directory] is resolved lazily so a platform failure only costs the
  /// artwork, not the refresh run that constructs this object.
  NotificationArtworkFiles({
    required this._dio,
    required this._directory,
    this._maxBytes = defaultMaxBytes,
    this._downloadTimeout = defaultDownloadTimeout,
  });

  /// Podcast artwork is often 3000x3000 (~36 MB decoded); Android decodes
  /// large icons without sampling, so shrink before handing the file over.
  static const thumbnailWidth = 256;

  /// Artwork URLs come from feeds; cap what a single response may buffer.
  static const defaultMaxBytes = 5 * 1024 * 1024;

  /// Stops the download itself, not just the caller's wait, so an abandoned
  /// request does not keep running in the background task.
  static const defaultDownloadTimeout = Duration(seconds: 4);

  final Dio _dio;
  final Future<Directory> Function() _directory;
  final int _maxBytes;
  final Duration _downloadTimeout;

  // Several new episodes of one podcast share artwork; fetch it once.
  final Map<String, Future<Uint8List>> _thumbnails = {};
  Future<Directory>? _preparedDirectory;

  /// Writes the thumbnail for [artworkUrl] to a file owned by
  /// [notificationId] and returns its path.
  Future<String> fileFor(String artworkUrl, int notificationId) async {
    final bytes = await _thumbnails.putIfAbsent(
      artworkUrl,
      () => _downloadThumbnail(artworkUrl),
    );
    final directory = await (_preparedDirectory ??= _prepareDirectory());
    final file = File('${directory.path}/$notificationId.png');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  // Files are consumed when a notification is posted (Android decodes the
  // bitmap, iOS moves the file), so anything left from earlier runs is stale.
  Future<Directory> _prepareDirectory() async {
    final directory = await _directory();
    if (directory.existsSync()) await directory.delete(recursive: true);
    return directory.create(recursive: true);
  }

  Future<Uint8List> _downloadThumbnail(String url) async {
    final cancelToken = CancelToken();
    final timer = Timer(_downloadTimeout, cancelToken.cancel);
    try {
      final bytes = await _download(url, cancelToken);
      return await downscaleToPng(bytes, thumbnailWidth);
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

/// Decodes [bytes] at [width] (aspect ratio kept) and re-encodes as PNG.
Future<Uint8List> downscaleToPng(Uint8List bytes, int width) async {
  final codec = await ui.instantiateImageCodec(bytes, targetWidth: width);
  final frame = await codec.getNextFrame();
  codec.dispose();
  final image = frame.image;
  try {
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    if (png == null) throw StateError('PNG encoding failed');
    return png.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}
