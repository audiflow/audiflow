import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../services/content_uri_reader.dart';
import '../../services/shared_file_inbox.dart';
import '../utils/opml_read_failure.dart';

part 'opml_file_receiver_controller.g.dart';

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
  OpmlFileReceiverError(this.failure, {this.error});

  /// Why the file could not be used; the UI maps it to localized text.
  final OpmlReadFailure failure;

  /// The underlying failure, if any; kept for diagnostics only.
  final Object? error;
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
    const supportedSchemes = {'file', 'content'};
    if (!supportedSchemes.contains(uri.scheme)) return;

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
        state = OpmlFileReceiverError(OpmlReadFailure.noFeeds);
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
    } on FormatException catch (e, stack) {
      _logger.w(
        'Received OPML file is not readable',
        error: e,
        stackTrace: stack,
      );
      state = OpmlFileReceiverError(OpmlReadFailure.unreadableFile, error: e);
    } on FileSystemException catch (e, stack) {
      // The OS denied access (e.g. a file the sender still owns) or the file
      // vanished before we read it. The user can act on that, so tell them the
      // file is unreadable instead of reporting an app error.
      _logger.w(
        'Received OPML file could not be opened',
        error: e,
        stackTrace: stack,
      );
      state = OpmlFileReceiverError(OpmlReadFailure.unreadableFile, error: e);
    } on Exception catch (e, stack) {
      _logger.e('Received OPML file failed', error: e, stackTrace: stack);
      state = OpmlFileReceiverError(OpmlReadFailure.unexpected, error: e);
    }
  }

  /// Reads file content from either a file:// or content:// URI.
  Future<String> _readContent(Uri uri) async {
    if (uri.scheme == 'content') return readContentUri(uri.toString());
    final path = uri.toFilePath();
    try {
      return await File(path).readAsString();
    } finally {
      // The content is in memory (or unreadable) by now, and iOS never
      // removes the copy it made, so drop it whether or not the import works.
      await _discardInboxCopy(path);
    }
  }

  Future<void> _discardInboxCopy(String path) async {
    try {
      await ref.read(sharedFileInboxProvider).discard(path);
    } on FileSystemException catch (e, stack) {
      // A leftover copy only wastes space; it must not fail the import.
      _logger.w(
        'Could not delete the shared OPML copy',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Exposes [_handleUri] for unit testing.
  @visibleForTesting
  Future<void> handleUriForTest(Uri uri) => _handleUri(uri);

  Logger get _logger => ref.read(namedLoggerProvider('OpmlFileReceiver'));

  /// Resets state to idle after navigation has been handled.
  void reset() {
    state = OpmlFileReceiverIdle();
  }
}
