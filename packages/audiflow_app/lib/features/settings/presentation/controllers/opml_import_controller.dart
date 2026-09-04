import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../parental_control/domain/gate_guard.dart';
import '../../../parental_control/providers/gate_guard_provider.dart';

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
  ///
  /// [context] is required to present the PIN entry sheet when
  /// Restricted Mode is active and the gate is locked.
  Future<bool> pickAndParse(BuildContext context) async {
    final allowed = await ref
        .read(gateGuardProvider)
        .requireUnlock(context, reason: GateReason.opmlImport);
    if (!allowed) return false;

    state = OpmlPickLoading();

    try {
      final file = await FilePicker.pickFile(type: FileType.any);

      if (file == null) {
        state = OpmlPickCancelled();
        return true;
      }

      final path = file.path;
      if (path == null) {
        state = OpmlPickError('Could not read file');
        return true;
      }

      final content = await File(path).readAsString();
      final parser = OpmlParserService();
      final entries = parser.parse(content);

      if (entries.isEmpty) {
        state = OpmlPickError('No podcast feeds found in the file');
        return true;
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
    return true;
  }
}
