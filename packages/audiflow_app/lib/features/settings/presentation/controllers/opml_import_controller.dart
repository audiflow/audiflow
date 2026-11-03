import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../parental_control/domain/gate_guard.dart';
import '../../../parental_control/providers/gate_guard_provider.dart';
import '../../services/opml_file_picker.dart';
import '../utils/opml_read_failure.dart';

part 'opml_import_controller.g.dart';

/// Sealed result type for import file pick + parse.
sealed class OpmlPickResult {}

/// Initial idle state before any pick operation.
class OpmlPickIdle extends OpmlPickResult {}

/// A file was chosen and is being read and parsed.
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
  OpmlPickError(this.failure, {this.error});

  /// Why the file could not be used; the UI maps it to localized text.
  final OpmlReadFailure failure;

  /// The underlying failure, if any; kept for diagnostics only.
  final Object? error;
}

/// User cancelled the file picker.
class OpmlPickCancelled extends OpmlPickResult {
  OpmlPickCancelled({required this.filter});

  /// The filter the cancelled picker used. Cancelling a filtered picker may
  /// mean the wanted file was hidden, so the UI offers to show all files.
  final OpmlPickFilter filter;
}

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
  ///
  /// The state stays as it was while the system picker is open and turns to
  /// [OpmlPickLoading] only once a file is chosen, so progress is not shown
  /// behind the picker.
  Future<bool> pickAndParse(
    BuildContext context, {
    OpmlPickFilter filter = OpmlPickFilter.opml,
  }) async {
    final allowed = await ref
        .read(gateGuardProvider)
        .requireUnlock(context, reason: GateReason.opmlImport);
    if (!allowed) return false;

    // Each step is logged so that a slow import on a device can be attributed
    // to the system picker or to this app's own work.
    final stopwatch = Stopwatch()..start();
    try {
      final file = await ref.read(opmlFilePickerProvider).pick(filter);
      if (!ref.mounted) return true;
      _logStep('System picker', stopwatch);

      if (file == null) {
        state = OpmlPickCancelled(filter: filter);
        return true;
      }

      state = OpmlPickLoading();

      final content = await file.read();
      // The user can leave the screen while a slow provider delivers the file.
      if (!ref.mounted) return true;
      _logStep('Read', stopwatch);

      final parser = OpmlParserService();
      final entries = parser.parse(content);
      _logStep('Parse', stopwatch);

      if (entries.isEmpty) {
        state = OpmlPickError(OpmlReadFailure.noFeeds);
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

      if (!ref.mounted) return true;
      _logStep('Subscription check', stopwatch);

      state = OpmlPickSuccess(
        entries: entries,
        subscribedFeedUrls: subscribedUrls,
      );
    } on FormatException catch (e, stack) {
      if (!ref.mounted) return true;
      _logger.w('OPML file is not valid', error: e, stackTrace: stack);
      state = OpmlPickError(OpmlReadFailure.unreadableFile, error: e);
    } catch (e, stack) {
      // Not only Exception: an Error such as a stack overflow on a deeply
      // nested file must not leave the progress barrier up for good.
      if (!ref.mounted) return true;
      _logger.e('OPML import failed', error: e, stackTrace: stack);
      state = OpmlPickError(OpmlReadFailure.unexpected, error: e);
    }
    return true;
  }

  void _logStep(String step, Stopwatch stopwatch) {
    _logger.d('$step took ${stopwatch.elapsedMilliseconds} ms');
    stopwatch.reset();
  }

  Logger get _logger => ref.read(namedLoggerProvider('OpmlImport'));
}
