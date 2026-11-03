import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../services/opml_file_picker.dart';
import '../controllers/opml_import_controller.dart';
import '../screens/opml_import_preview_screen.dart';
import '../utils/opml_read_failure.dart';

/// Starts the OPML import: opens the parental-control gate, then the picker.
///
/// Null while an import is already in flight, so a button wired straight to
/// it disables itself for the duration.
typedef OpmlImportStarter = VoidCallback?;

/// Hosts the OPML import flow for a screen and hands its [builder] the
/// callback that starts it.
///
/// Owns the controller listener, the preview navigation, and the result
/// dialog so every entry point into import behaves identically. The
/// controller is one shared provider, so a screen must listen to it exactly
/// once - two listeners would push the preview screen twice for a single
/// picked file. A screen offering more than one import button therefore
/// wraps its whole subtree here and wires every button to the same starter.
class OpmlImportFlow extends ConsumerStatefulWidget {
  const OpmlImportFlow({super.key, required this.builder});

  final Widget Function(BuildContext context, OpmlImportStarter start) builder;

  @override
  ConsumerState<OpmlImportFlow> createState() => _OpmlImportFlowState();
}

class _OpmlImportFlowState extends ConsumerState<OpmlImportFlow> {
  /// Guards the gap between the tap and the controller reaching its loading
  /// state, which spans the parental-control gate and the native picker.
  bool _starting = false;

  final _progress = OverlayPortalController();

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _allFilesOffer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // The snackbar lives above this screen, so it survives a tab switch or a
    // covering route. Tapping it then would land the picker's result on a
    // navigator the user cannot see. TickerMode is what both of those turn off.
    if (TickerMode.valuesOf(context).enabled) return;

    // Closing animates the messenger, which cannot rebuild during this build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _allFilesOffer?.close();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(opmlImportControllerProvider, (_, next) {
      if (next is OpmlPickLoading) {
        _progress.show();
      } else {
        _progress.hide();
      }

      switch (next) {
        case OpmlPickSuccess(:final entries, :final subscribedFeedUrls):
          _navigateToPreview(
            context,
            entries: entries,
            subscribedFeedUrls: subscribedFeedUrls,
          );
        case OpmlPickError(:final failure, :final error):
          final message = failure.message(AppLocalizations.of(context), error);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        case OpmlPickCancelled(filter: OpmlPickFilter.opml):
          _offerAllFiles(context);
        case OpmlPickCancelled(filter: OpmlPickFilter.allFiles):
        case OpmlPickIdle():
        case OpmlPickLoading():
          break;
      }
    });

    // Disabling the action stops a second tap from pushing the preview screen
    // twice; the overlay tells the user the wait after the picker closes is
    // this app working, since a remote file can take a while to arrive.
    final busy =
        _starting || ref.watch(opmlImportControllerProvider) is OpmlPickLoading;

    // The root overlay, so the barrier also covers the tab bar: switching tab
    // mid-read would land the preview on a navigator that is out of sight.
    return OverlayPortal(
      controller: _progress,
      overlayLocation: OverlayChildLocation.rootOverlay,
      overlayChildBuilder: (_) => const _ImportProgress(),
      child: widget.builder(context, busy ? null : _start),
    );
  }

  /// The system pickers have no room for an in-app button, so cancelling is
  /// the moment to offer the way out of a filter that hid the wanted file.
  void _offerAllFiles(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final offer = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.opmlPickerFileNotListed),
        // Cancelling is usually deliberate, so this must not linger until
        // dismissed, which is the default for a snackbar with an action. It
        // still needs longer than usual to be read and acted on.
        persist: false,
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: l10n.opmlPickerShowAllFiles,
          onPressed: () => _start(filter: OpmlPickFilter.allFiles),
        ),
      ),
    );
    _allFilesOffer = offer;
    // Closing a finished offer would hide whichever snackbar came after it.
    offer.closed.whenComplete(() {
      if (identical(_allFilesOffer, offer)) _allFilesOffer = null;
    });
  }

  Future<void> _start({OpmlPickFilter filter = OpmlPickFilter.opml}) async {
    // The all-files snackbar lives above this screen and can outlast it.
    if (!mounted) return;

    // Disabling the buttons only takes effect on the next frame, so two
    // callbacks dispatched in the same frame would both get this far.
    if (_starting) return;

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() => _starting = true);
    try {
      final allowed = await ref
          .read(opmlImportControllerProvider.notifier)
          .pickAndParse(context, filter: filter);

      if (!allowed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.parentalControlAccessDenied)),
        );
      }
    } finally {
      if (mounted) setState(() => _starting = false);
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

/// Blocks the screen while a chosen file is read, parsed, and checked.
class _ImportProgress extends StatelessWidget {
  const _ImportProgress();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        const ModalBarrier(dismissible: false, color: Colors.black54),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 24),
                Flexible(child: Text(l10n.opmlImportReadingFile)),
              ],
            ),
          ),
        ),
      ],
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
