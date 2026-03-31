import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'opml_file_receiver_controller.g.dart';

const _channel = MethodChannel('com.reedom.audiflow_app/content_resolver');

/// Sealed result type for externally received OPML file.
sealed class OpmlFileReceiverState {}

/// No file has been received yet.
class OpmlFileReceiverIdle extends OpmlFileReceiverState {}

/// File is being read and parsed.
class OpmlFileReceiverLoading extends OpmlFileReceiverState {}

/// Successfully parsed the received OPML file.
class OpmlFileReceiverSuccess extends OpmlFileReceiverState {
  OpmlFileReceiverSuccess({
    required this.entries,
    required this.subscribedFeedUrls,
  });

  final List<OpmlEntry> entries;
  final Set<String> subscribedFeedUrls;
}

/// Error during file processing.
class OpmlFileReceiverError extends OpmlFileReceiverState {
  OpmlFileReceiverError(this.message);

  final String message;
}

/// Listens for incoming .opml file URIs from external apps
/// via the system share sheet or "Open With" handler.
@Riverpod(keepAlive: true)
class OpmlFileReceiverController extends _$OpmlFileReceiverController {
  @override
  OpmlFileReceiverState build() {
    final appLinks = AppLinks();

    final subscription = appLinks.uriLinkStream.listen(_handleUri);
    ref.onDispose(subscription.cancel);

    // Check if app was launched via a file link
    appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleUri(uri);
      }
    });

    return OpmlFileReceiverIdle();
  }

  Future<void> _handleUri(Uri uri) async {
    final uriString = uri.toString();
    final isOpml = uriString.endsWith('.opml') || uriString.endsWith('.xml');
    // content:// URIs may lack a file extension; accept them unconditionally
    // and let the parser reject non-OPML content below.
    if (uri.scheme == 'file' && !isOpml) return;

    state = OpmlFileReceiverLoading();

    try {
      final content = await _readContent(uri);
      final parser = OpmlParserService();
      final entries = parser.parse(content);

      if (entries.isEmpty) {
        state = OpmlFileReceiverError('No podcast feeds found in the file');
        return;
      }

      final repo = ref.read(subscriptionRepositoryProvider);
      final subscribedUrls = <String>{};
      for (final entry in entries) {
        final exists = await repo.isSubscribedByFeedUrl(entry.feedUrl);
        if (exists) {
          subscribedUrls.add(entry.feedUrl);
        }
      }

      state = OpmlFileReceiverSuccess(
        entries: entries,
        subscribedFeedUrls: subscribedUrls,
      );
    } on FormatException catch (e) {
      state = OpmlFileReceiverError(e.message);
    } on Exception catch (e) {
      state = OpmlFileReceiverError(e.toString());
    }
  }

  /// Reads file content from either a file:// or content:// URI.
  Future<String> _readContent(Uri uri) async {
    if (uri.scheme == 'content') {
      // Android content:// URIs require ContentResolver via platform channel
      final result = await _channel.invokeMethod<String>(
        'readContentUri',
        uri.toString(),
      );
      if (result == null) {
        throw const FormatException('Failed to read content from URI');
      }
      return result;
    }
    return File(uri.toFilePath()).readAsString();
  }

  /// Resets state to idle after navigation has been handled.
  void reset() {
    state = OpmlFileReceiverIdle();
  }
}
