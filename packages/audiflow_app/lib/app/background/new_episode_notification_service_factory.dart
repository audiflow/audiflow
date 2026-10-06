import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import 'localized_notification_text_formatter.dart';

/// Builds the new-episode notification service.
///
/// Shared by the background refresh and the developer test notifications so
/// both post through the same artwork and text handling.
Future<BackgroundNotificationService> createNewEpisodeNotificationService({
  required Dio dio,
  required String? storedLocale,
  Logger? logger,
  ArtworkFailureSink? onArtworkFailure,
}) async {
  final artworkFiles = NotificationArtworkFiles(
    dio: dio,
    directory: () async => Directory(
      '${(await getTemporaryDirectory()).path}/notification_artwork',
    ),
    // iOS disables the GPU for a backgrounded engine and Impeller then
    // stalls dart:ui image decoding, so iOS attaches the original file
    // (it scales attachments itself). Android needs a small large icon.
    encoder: Platform.isIOS
        ? const PassthroughArtworkEncoder()
        : const DownscalingArtworkEncoder(),
  );
  return BackgroundNotificationService(
    textFormatter: await LocalizedNotificationTextFormatter.create(
      storedLocale: storedLocale,
      platformLocale: Platform.localeName,
    ),
    logger: logger,
    artworkFileProvider: artworkFiles.fileFor,
    onArtworkFailure: onArtworkFailure,
  );
}
