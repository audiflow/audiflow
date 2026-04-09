import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/download_management_controller.dart';
import '../widgets/download_task_tile.dart';

/// Screen for managing all download tasks grouped by status.
class DownloadManagementScreen extends ConsumerWidget {
  const DownloadManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allDownloads = ref.watch(allDownloadsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.downloadScreenTitle),
        actions: [_DeleteAllCompletedButton()],
      ),
      body: allDownloads.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return _EmptyState(theme: theme);
          }
          return _DownloadList(tasks: tasks);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            l10n.downloadLoadError,
            style: theme.textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}

class _DeleteAllCompletedButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final completed = ref.watch(completedDownloadsProvider);
    final hasCompleted = completed.value?.isNotEmpty ?? false;

    if (!hasCompleted) return const SizedBox.shrink();

    return IconButton(
      icon: const Icon(Icons.delete_sweep),
      tooltip: l10n.downloadDeleteAllCompleted,
      onPressed: () async {
        final controller = ref.read(
          downloadManagementControllerProvider.notifier,
        );
        await controller.deleteAllCompleted();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.downloadCompletedDeleted)),
          );
        }
      },
    );
  }
}

class _DownloadList extends ConsumerWidget {
  const _DownloadList({required this.tasks});

  final List<DownloadTask> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = _groupByStatus(tasks);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return ListView(
      children: [
        if (grouped.downloading.isNotEmpty)
          _Section(
            title: l10n.downloadStatusDownloading,
            tasks: grouped.downloading,
            theme: theme,
            ref: ref,
          ),
        if (grouped.pending.isNotEmpty)
          _Section(
            title: l10n.downloadStatusPending,
            tasks: grouped.pending,
            theme: theme,
            ref: ref,
          ),
        if (grouped.paused.isNotEmpty)
          _Section(
            title: l10n.downloadStatusPaused,
            tasks: grouped.paused,
            theme: theme,
            ref: ref,
          ),
        if (grouped.completed.isNotEmpty)
          _Section(
            title: l10n.downloadStatusCompleted,
            tasks: grouped.completed,
            theme: theme,
            ref: ref,
          ),
        if (grouped.failed.isNotEmpty)
          _Section(
            title: l10n.downloadStatusFailed,
            tasks: grouped.failed,
            theme: theme,
            ref: ref,
          ),
        if (grouped.cancelled.isNotEmpty)
          _Section(
            title: l10n.downloadStatusCancelled,
            tasks: grouped.cancelled,
            theme: theme,
            ref: ref,
          ),
      ],
    );
  }

  _GroupedTasks _groupByStatus(List<DownloadTask> tasks) {
    final downloading = <DownloadTask>[];
    final pending = <DownloadTask>[];
    final paused = <DownloadTask>[];
    final completed = <DownloadTask>[];
    final failed = <DownloadTask>[];
    final cancelled = <DownloadTask>[];

    for (final task in tasks) {
      final status = DownloadStatus.fromDbValue(task.status);
      switch (status) {
        case DownloadStatusDownloading():
          downloading.add(task);
        case DownloadStatusPending():
          pending.add(task);
        case DownloadStatusPaused():
          paused.add(task);
        case DownloadStatusCompleted():
          completed.add(task);
        case DownloadStatusFailed():
          failed.add(task);
        case DownloadStatusCancelled():
          cancelled.add(task);
      }
    }

    return (
      downloading: downloading,
      pending: pending,
      paused: paused,
      completed: completed,
      failed: failed,
      cancelled: cancelled,
    );
  }
}

typedef _GroupedTasks = ({
  List<DownloadTask> downloading,
  List<DownloadTask> pending,
  List<DownloadTask> paused,
  List<DownloadTask> completed,
  List<DownloadTask> failed,
  List<DownloadTask> cancelled,
});

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.tasks,
    required this.theme,
    required this.ref,
  });

  final String title;
  final List<DownloadTask> tasks;
  final ThemeData theme;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.md,
            Spacing.md,
            Spacing.md,
            Spacing.xs,
          ),
          child: Text(
            l10n.downloadSectionCount(title, tasks.length),
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ...tasks.map((task) => _DownloadTaskTileWithTitle(task: task)),
      ],
    );
  }
}

/// Resolves episode title from DB before rendering the tile.
class _DownloadTaskTileWithTitle extends ConsumerWidget {
  const _DownloadTaskTileWithTitle({required this.task});

  final DownloadTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodeAsync = ref.watch(
      episodeByIdForDownloadProvider(task.episodeId),
    );
    final episode = episodeAsync.value;

    // Read controller fresh in each callback to avoid capturing a stale
    // reference from an auto-dispose provider (fixes AUDIFLOW-3Q/3R).
    return DownloadTaskTile(
      task: task,
      episodeTitle: episode?.title ?? '',
      onPause: () async => ref
          .read(downloadManagementControllerProvider.notifier)
          .pause(task.id),
      onResume: () async => ref
          .read(downloadManagementControllerProvider.notifier)
          .resume(task.id),
      onCancel: () async => ref
          .read(downloadManagementControllerProvider.notifier)
          .cancel(task.id),
      onRetry: () async => ref
          .read(downloadManagementControllerProvider.notifier)
          .retry(task.id),
      onDelete: () async => ref
          .read(downloadManagementControllerProvider.notifier)
          .delete(task.id),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download_done,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: Spacing.md),
          Text(
            l10n.downloadEmptyTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
