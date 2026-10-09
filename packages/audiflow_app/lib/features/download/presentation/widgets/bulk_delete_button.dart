import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Groups of download statuses the bulk delete menu clears at once.
enum BulkDeleteScope {
  completed,
  queued,
  failed,
  all;

  Set<DownloadStatus> get statuses => switch (this) {
    BulkDeleteScope.completed => {const DownloadStatus.completed()},
    BulkDeleteScope.queued => {
      const DownloadStatus.pending(),
      const DownloadStatus.paused(),
    },
    BulkDeleteScope.failed => {
      const DownloadStatus.failed(),
      const DownloadStatus.cancelled(),
    },
    BulkDeleteScope.all => {
      const DownloadStatus.pending(),
      const DownloadStatus.downloading(),
      const DownloadStatus.paused(),
      const DownloadStatus.completed(),
      const DownloadStatus.failed(),
      const DownloadStatus.cancelled(),
    },
  };

  String label(AppLocalizations l10n) => switch (this) {
    BulkDeleteScope.completed => l10n.downloadBulkDeleteCompleted,
    BulkDeleteScope.queued => l10n.downloadBulkDeleteQueued,
    BulkDeleteScope.failed => l10n.downloadBulkDeleteFailed,
    BulkDeleteScope.all => l10n.downloadBulkDeleteAll,
  };

  /// IDs of the [tasks] this scope covers.
  List<int> taskIdsIn(List<DownloadTask> tasks) => [
    for (final task in tasks)
      if (statuses.contains(task.downloadStatus)) task.id,
  ];
}

/// App bar menu that deletes every download in a chosen status group,
/// after the listener confirms the number of downloads affected.
class BulkDeleteButton extends StatelessWidget {
  const BulkDeleteButton({
    super.key,
    required this.tasks,
    required this.onDelete,
  });

  final List<DownloadTask> tasks;

  /// Deletes the confirmed [taskIds] that are still in [statuses] and
  /// returns how many were deleted.
  final Future<int> Function(List<int> taskIds, Set<DownloadStatus> statuses)
  onDelete;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    return ActionMenuTrigger(
      onOpen: (anchor, drag) => _showMenu(anchor, drag, l10n),
      builder: (context, open) => IconButton(
        icon: const Icon(Icons.delete_sweep),
        tooltip: l10n.downloadBulkDeleteTooltip,
        onPressed: open,
      ),
    );
  }

  void _showMenu(
    BuildContext anchor,
    ActionMenuDrag? drag,
    AppLocalizations l10n,
  ) {
    showActionMenu(
      context: anchor,
      placement: ActionMenuPlacement.below(anchor),
      sections: [
        [
          for (final scope in BulkDeleteScope.values)
            ActionMenuEntry(
              label: l10n.downloadSectionCount(
                scope.label(l10n),
                scope.taskIdsIn(tasks).length,
              ),
              enabled: scope.taskIdsIn(tasks).isNotEmpty,
              onSelected: () => _confirmAndDelete(anchor, scope),
            ),
        ],
      ],
      drag: drag,
    );
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    BulkDeleteScope scope,
  ) async {
    final l10n = AppLocalizations.of(context);
    // Fix the set now so what gets deleted is what the dialog counted.
    final taskIds = scope.taskIdsIn(tasks);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(scope.label(l10n)),
        content: Text(l10n.downloadBulkDeleteConfirm(taskIds.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final deleted = await onDelete(taskIds, scope.statuses);
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.downloadBulkDeleted(deleted))),
    );
  }
}
