import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/download_management_controller.dart';
import '../widgets/download_task_tile.dart';

/// Screen for managing all download tasks grouped by status.
class DownloadManagementScreen extends ConsumerWidget {
  const DownloadManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allDownloads = ref.watch(allDownloadsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
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
            'Failed to load downloads',
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
    final completed = ref.watch(completedDownloadsProvider);
    final hasCompleted = completed.value?.isNotEmpty ?? false;

    if (!hasCompleted) return const SizedBox.shrink();

    return IconButton(
      icon: const Icon(Icons.delete_sweep),
      tooltip: 'Delete all completed',
      onPressed: () async {
        final controller = ref.read(
          downloadManagementControllerProvider.notifier,
        );
        await controller.deleteAllCompleted();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Completed downloads deleted')),
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

    return ListView(
      children: [
        if (grouped.downloading.isNotEmpty)
          _Section(
            title: 'Downloading',
            tasks: grouped.downloading,
            theme: theme,
            ref: ref,
          ),
        if (grouped.pending.isNotEmpty)
          _Section(
            title: 'Pending',
            tasks: grouped.pending,
            theme: theme,
            ref: ref,
          ),
        if (grouped.paused.isNotEmpty)
          _Section(
            title: 'Paused',
            tasks: grouped.paused,
            theme: theme,
            ref: ref,
          ),
        if (grouped.completed.isNotEmpty)
          _Section(
            title: 'Completed',
            tasks: grouped.completed,
            theme: theme,
            ref: ref,
          ),
        if (grouped.failed.isNotEmpty)
          _Section(
            title: 'Failed',
            tasks: grouped.failed,
            theme: theme,
            ref: ref,
          ),
        if (grouped.cancelled.isNotEmpty)
          _Section(
            title: 'Cancelled',
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
            '$title (${tasks.length})',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ...tasks.map((task) => _buildTile(task)),
      ],
    );
  }

  Widget _buildTile(DownloadTask task) {
    final controller = ref.read(downloadManagementControllerProvider.notifier);

    return DownloadTaskTile(
      task: task,
      episodeTitle: 'Episode ${task.episodeId}',
      onPause: () => controller.pause(task.id),
      onResume: () => controller.resume(task.id),
      onCancel: () => controller.cancel(task.id),
      onRetry: () => controller.retry(task.id),
      onDelete: () => controller.delete(task.id),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
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
            'No downloads',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
