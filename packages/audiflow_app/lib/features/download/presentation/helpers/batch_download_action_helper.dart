import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';

/// Shows confirmation dialog and triggers batch download for the given
/// episode IDs.
Future<void> handleBatchDownload({
  required BuildContext context,
  required WidgetRef ref,
  required List<int> episodeIds,
}) async {
  if (episodeIds.isEmpty) return;

  final l10n = AppLocalizations.of(context);
  final limit = ref.read(batchDownloadLimitProvider);
  final downloadCount = episodeIds.length <= limit ? episodeIds.length : limit;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.downloadAllConfirmTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.downloadAllConfirmContent(downloadCount)),
          if (limit < episodeIds.length)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.downloadAllLimitNote(limit),
                style: Theme.of(dialogContext).textTheme.bodySmall,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n.downloadAllEpisodes),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  final downloadService = ref.read(downloadServiceProvider);
  final queued = await downloadService.downloadEpisodes(episodeIds);

  if (!context.mounted) return;
  messenger.showSnackBar(
    SnackBar(content: Text(l10n.downloadAllQueued(queued))),
  );
}
