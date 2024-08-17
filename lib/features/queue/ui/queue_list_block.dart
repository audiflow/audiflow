import 'package:audiflow/events/play_button_notification.dart';
import 'package:audiflow/features/browser/episode/data/episode_provider.dart';
import 'package:audiflow/features/browser/episode/ui/episode_brief_tile.dart';
import 'package:audiflow/features/queue/model/queue.dart';
import 'package:audiflow/features/queue/service/queue_controller.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

class QueueListBlock extends ConsumerWidget {
  const QueueListBlock({
    required this.queueType,
    this.backgroundColor,
    super.key,
  });

  final QueueType queueType;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref
        .watch(queueControllerProvider)
        .queue
        .where((q) => q.type == queueType)
        .toList();
    if (queue.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    return NotificationListener<PlayButtonTappedNotification>(
      onNotification: (notification) {
        // final episode = notification.episode;
        // final index = notification.index;
        // if (index == null || queue.length <= index) {
        //   ref.read(podcastServiceProvider).handlePlay(episode);
        // } else {
        //   ref
        //       .read(podcastServiceProvider)
        //       .handlePlayFromQueue(queue[index].item, queue[index].episode);
        // }
        return false;
      },
      child: _Section(
        title: queueType.label(context),
        backgroundColor: backgroundColor ?? theme.colorScheme.surface,
        queue: queue,
        trailing: TextButton(
          child: Text(l10n.clear),
          onPressed: () {
            ref.read(queueControllerProvider.notifier).clear();
          },
        ),
        onReorder: (oldIndex, newIndex) {
          ref
              .read(queueControllerProvider.notifier)
              .reorder(oldIndex, newIndex);
        },
        onRemove: (index) {
          ref.read(queueControllerProvider.notifier).removeByIndex(index);
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.queue,
    required this.onReorder,
    required this.onRemove,
    required this.backgroundColor,
    this.trailing,
  });

  final String title;
  final List<QueueItem> queue;
  final ReorderCallback onReorder;
  final ValueChanged<int> onRemove;
  final Color backgroundColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        SliverPinnedHeader(
          child: Builder(
            builder: (context) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0, 0.90, 1],
                    colors: [
                      backgroundColor,
                      backgroundColor,
                      theme.colorScheme.surfaceContainerHighest.withOpacity(0),
                    ],
                  ),
                ),
                child: ListTile(
                  title: Text(title),
                  trailing: trailing,
                  contentPadding: const EdgeInsets.only(left: 20, right: 8),
                  tileColor: backgroundColor,
                ),
              );
            },
          ),
        ),
        SliverReorderableList(
          itemBuilder: (context, index) => Dismissible(
            key: ValueKey(queue[index].id),
            onDismissed: (_) {
              onRemove(index);
            },
            direction: DismissDirection.endToStart,
            background: Container(
              color: Theme.of(context).colorScheme.error,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.onError,
              ),
            ),
            child: Consumer(
              builder: (context, ref, child) {
                final episode =
                    ref.watch(episodeProvider(eid: queue[index].eid)).maybeMap(
                          data: (data) => data.value,
                          orElse: () => null,
                        );
                return episode == null
                    ? const SizedBox(height: EpisodeBriefTile.tileHeight)
                    : EpisodeBriefTile(
                        key: ValueKey(queue[index].id),
                        episode: episode,
                        sortableIndex: index,
                        backgroundColor: backgroundColor,
                      );
              },
            ),
          ),
          itemCount: queue.length,
          onReorder: onReorder,
        ),
      ],
    );
  }
}

extension QueueTypeExt on QueueType {
  String label(BuildContext context) {
    final l10n = L10n.of(context);
    switch (this) {
      case QueueType.primary:
        return l10n.primaryQueue;
      case QueueType.adhoc:
        return l10n.adhocQueue;
    }
  }
}
