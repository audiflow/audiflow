import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'opml_import_controller.g.dart';

/// Sealed result type for import file pick + parse.
sealed class OpmlPickResult {}

/// Initial idle state before any pick operation.
class OpmlPickIdle extends OpmlPickResult {}

/// File is being read and parsed.
class OpmlPickLoading extends OpmlPickResult {}

/// Successfully parsed OPML entries.
class OpmlPickSuccess extends OpmlPickResult {
  OpmlPickSuccess({required this.entries, required this.subscribedFeedUrls});

  /// Parsed podcast entries from the OPML file.
  final List<OpmlEntry> entries;

  /// Feed URLs that are already subscribed.
  final Set<String> subscribedFeedUrls;
}

/// An error occurred during pick or parse.
class OpmlPickError extends OpmlPickResult {
  OpmlPickError(this.message);

  /// Human-readable error description.
  final String message;
}

/// User cancelled the file picker.
class OpmlPickCancelled extends OpmlPickResult {}

/// Controls OPML import: pick file, parse, and check
/// existing subscriptions.
@riverpod
class OpmlImportController extends _$OpmlImportController {
  @override
  OpmlPickResult build() => OpmlPickIdle();

  /// Opens file picker, reads the OPML file, and parses
  /// entries. On success, sets state to [OpmlPickSuccess].
  Future<void> pickAndParse() async {
    state = OpmlPickLoading();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result == null || result.files.isEmpty) {
        state = OpmlPickCancelled();
        return;
      }

      final file = result.files.first;
      final path = file.path;
      if (path == null) {
        state = OpmlPickError('Could not read file');
        return;
      }

      final content = await File(path).readAsString();
      final parser = OpmlParserService();
      final entries = parser.parse(content);

      if (entries.isEmpty) {
        state = OpmlPickError('No podcast feeds found in the file');
        return;
      }

      // Check which feeds are already subscribed
      final repo = ref.read(subscriptionRepositoryProvider);
      final subscribedUrls = <String>{};
      for (final entry in entries) {
        final exists = await repo.isSubscribedByFeedUrl(entry.feedUrl);
        if (exists) {
          subscribedUrls.add(entry.feedUrl);
        }
      }

      state = OpmlPickSuccess(
        entries: entries,
        subscribedFeedUrls: subscribedUrls,
      );
    } on FormatException catch (e) {
      state = OpmlPickError(e.message);
    } on Exception catch (e) {
      state = OpmlPickError(e.toString());
    }
  }
}
