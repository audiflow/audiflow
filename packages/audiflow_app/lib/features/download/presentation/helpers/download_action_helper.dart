import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';

/// Handles download status-based tap actions consistently across all widgets.
///
/// Centralizes the download lifecycle (start, cancel, pause, resume, retry,
/// delete) so that queue tiles, episode tiles, and detail screens share
/// identical behavior.
Future<void> handleDownloadTap({
  required BuildContext context,
  required WidgetRef ref,
  required int episodeId,
  required DownloadTask? task,
}) async {
  final downloadService = ref.read(downloadServiceProvider);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);

  if (task == null) {
    await downloadService.downloadEpisode(episodeId);
    return;
  }

  task.downloadStatus.when(
    pending: () async {
      await downloadService.cancel(task.id);
      messenger.showSnackBar(SnackBar(content: Text(l10n.downloadCancelled)));
    },
    downloading: () async {
      await downloadService.pause(task.id);
    },
    paused: () async {
      await downloadService.resume(task.id);
    },
    completed: () {
      showDownloadDeleteConfirmation(context: context, ref: ref, task: task);
    },
    failed: () async {
      await downloadService.retry(task.id);
      messenger.showSnackBar(SnackBar(content: Text(l10n.downloadRetrying)));
    },
    cancelled: () async {
      final result = await downloadService.downloadEpisode(episodeId);
      if (result != null) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.downloadStarted)));
      }
    },
  );
}

/// Shows a confirmation dialog before deleting a completed download.
///
/// Captures [ScaffoldMessenger] before opening the dialog to avoid
/// using an unmounted dialog context after [Navigator.pop].
void showDownloadDeleteConfirmation({
  required BuildContext context,
  required WidgetRef ref,
  required DownloadTask task,
}) {
  final l10n = AppLocalizations.of(context);
  // Capture the outer messenger before the dialog creates a new context.
  // After Navigator.pop the dialog context is unmounted, so
  // ScaffoldMessenger.of(dialogContext) would throw.
  final messenger = ScaffoldMessenger.of(context);

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.downloadDeleteTitle),
      content: Text(l10n.downloadDeleteContent),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(dialogContext);
            await ref.read(downloadServiceProvider).delete(task.id);
            messenger.showSnackBar(
              SnackBar(content: Text(l10n.downloadDeleted)),
            );
          },
          child: Text(l10n.commonDelete),
        ),
      ],
    ),
  );
}
