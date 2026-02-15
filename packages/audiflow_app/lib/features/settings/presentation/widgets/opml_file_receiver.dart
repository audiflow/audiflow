import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../routing/app_router.dart';
import '../controllers/opml_file_receiver_controller.dart';
import '../screens/opml_import_preview_screen.dart';

/// Transparent widget that listens for incoming OPML files
/// from external apps and navigates to the import preview.
///
/// Uses [rootNavigatorKey] to push routes since this widget
/// sits above the Navigator in the widget tree.
class OpmlFileReceiver extends ConsumerStatefulWidget {
  const OpmlFileReceiver({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<OpmlFileReceiver> createState() => _OpmlFileReceiverState();
}

class _OpmlFileReceiverState extends ConsumerState<OpmlFileReceiver> {
  @override
  Widget build(BuildContext context) {
    ref.listen(opmlFileReceiverControllerProvider, (_, next) {
      switch (next) {
        case OpmlFileReceiverSuccess(:final entries, :final subscribedFeedUrls):
          _navigateToPreview(
            entries: entries,
            subscribedFeedUrls: subscribedFeedUrls,
          );
        case OpmlFileReceiverError(:final message):
          _showError(message);
          ref.read(opmlFileReceiverControllerProvider.notifier).reset();
        case OpmlFileReceiverIdle():
        case OpmlFileReceiverLoading():
          break;
      }
    });

    return widget.child;
  }

  void _showError(String message) {
    final navigator = rootNavigatorKey.currentState;
    if (navigator == null) return;

    final overlay = navigator.overlay;
    if (overlay == null) return;

    ScaffoldMessenger.of(
      overlay.context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _navigateToPreview({
    required List<OpmlEntry> entries,
    required Set<String> subscribedFeedUrls,
  }) async {
    ref.read(opmlFileReceiverControllerProvider.notifier).reset();

    final navigator = rootNavigatorKey.currentState;
    if (navigator == null) return;

    final result = await navigator.push<OpmlImportResult>(
      MaterialPageRoute<OpmlImportResult>(
        builder: (_) => OpmlImportPreviewScreen(
          entries: entries,
          subscribedFeedUrls: subscribedFeedUrls,
        ),
      ),
    );

    if (result == null || !mounted) return;

    _showImportSummary(navigator, result);
  }

  void _showImportSummary(NavigatorState navigator, OpmlImportResult result) {
    final lines = <String>['Imported ${result.succeeded.length} podcasts'];
    if (result.alreadySubscribed.isNotEmpty) {
      lines.add('${result.alreadySubscribed.length} already subscribed');
    }
    if (result.failed.isNotEmpty) {
      lines.add('${result.failed.length} failed');
    }

    showDialog<void>(
      context: navigator.context,
      builder: (_) => AlertDialog(
        title: const Text('Import Complete'),
        content: Text(lines.join('\n')),
        actions: [
          TextButton(onPressed: () => navigator.pop(), child: const Text('OK')),
        ],
      ),
    );
  }
}
