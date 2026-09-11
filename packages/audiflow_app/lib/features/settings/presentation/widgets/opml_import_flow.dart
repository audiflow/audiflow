import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/opml_import_controller.dart';
import '../screens/opml_import_preview_screen.dart';

/// Starts the OPML import: opens the parental-control gate, then the picker.
typedef OpmlImportStarter = Future<void> Function();

/// Hosts the OPML import flow for a screen and hands its [builder] the
/// callback that starts it.
///
/// Owns the controller listener, the preview navigation, and the result
/// dialog so every entry point into import behaves identically. The
/// controller is one shared provider, so a screen must listen to it exactly
/// once — two listeners would push the preview screen twice for a single
/// picked file. A screen offering more than one import button therefore
/// wraps its whole subtree here and wires every button to the same starter.
class OpmlImportFlow extends ConsumerWidget {
  const OpmlImportFlow({super.key, required this.builder});

  final Widget Function(BuildContext context, OpmlImportStarter start) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(opmlImportControllerProvider, (_, next) {
      switch (next) {
        case OpmlPickSuccess(:final entries, :final subscribedFeedUrls):
          _navigateToPreview(
            context,
            entries: entries,
            subscribedFeedUrls: subscribedFeedUrls,
          );
        case OpmlPickError(:final message):
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        case OpmlPickCancelled():
        case OpmlPickIdle():
        case OpmlPickLoading():
          break;
      }
    });

    return builder(context, () => _start(context, ref));
  }

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final allowed = await ref
        .read(opmlImportControllerProvider.notifier)
        .pickAndParse(context);

    if (!allowed && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.parentalControlAccessDenied)));
    }
  }

  Future<void> _navigateToPreview(
    BuildContext context, {
    required List<OpmlEntry> entries,
    required Set<String> subscribedFeedUrls,
  }) async {
    final result = await Navigator.push<OpmlImportResult>(
      context,
      MaterialPageRoute<OpmlImportResult>(
        builder: (_) => OpmlImportPreviewScreen(
          entries: entries,
          subscribedFeedUrls: subscribedFeedUrls,
        ),
      ),
    );

    if (result == null || !context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (_) => _ImportSummaryDialog(result: result),
    );
  }
}

class _ImportSummaryDialog extends StatelessWidget {
  const _ImportSummaryDialog({required this.result});

  final OpmlImportResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lines = <String>[l10n.storageImportedCount(result.succeeded.length)];
    if (result.alreadySubscribed.isNotEmpty) {
      lines.add(
        l10n.storageAlreadySubscribedCount(result.alreadySubscribed.length),
      );
    }
    if (result.failed.isNotEmpty) {
      lines.add(l10n.storageFailedCount(result.failed.length));
    }

    return AlertDialog(
      title: Text(l10n.storageImportComplete),
      content: Text(lines.join('\n')),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonOk),
        ),
      ],
    );
  }
}
