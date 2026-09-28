import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';

/// Downloads podcast artwork and writes notification-sized thumbnails.
///
/// Use [fileFor] as a `BackgroundNotificationService` artwork provider.
class NotificationArtworkFiles {
  NotificationArtworkFiles({required this._dio, required this._directory});

  /// Podcast artwork is often 3000x3000 (~36 MB decoded); Android decodes
  /// large icons without sampling, so shrink before handing the file over.
  static const thumbnailWidth = 256;

  final Dio _dio;
  final Directory _directory;

  // Several new episodes of one podcast share artwork; fetch it once.
  final Map<String, Future<Uint8List>> _thumbnails = {};

  /// Writes the thumbnail for [artworkUrl] to a file owned by
  /// [notificationId] and returns its path.
  Future<String> fileFor(String artworkUrl, int notificationId) async {
    final bytes = await _thumbnails.putIfAbsent(
      artworkUrl,
      () => _downloadThumbnail(artworkUrl),
    );
    await _directory.create(recursive: true);
    final file = File('${_directory.path}/$notificationId.png');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<Uint8List> _downloadThumbnail(String url) async {
    final response = await _dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    final data = response.data;
    if (data == null || data.isEmpty) {
      throw StateError('Empty artwork response: $url');
    }
    return downscaleToPng(Uint8List.fromList(data), thumbnailWidth);
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
