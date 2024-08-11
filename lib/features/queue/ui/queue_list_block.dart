import 'package:audiflow/events/play_button_notification.dart';
import 'package:audiflow/features/browser/episode/data/episode_provider.dart';
import 'package:audiflow/features/browser/episode/ui/episode_brief_tile.dart';
import 'package:audiflow/features/queue/model/queue_item.dart';
import 'package:audiflow/features/queue/service/manual_queue_controller.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

class QueueListBlock extends ConsumerWidget {
  const QueueListBlock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manualQueueItems = ref.watch(manualQueueControllerProvider);
    if (manualQueueItems.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final queueController = ref.read(manualQueueControllerProvider.notifier);

    final l10n = L10n.of(context);
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
      child: Section(
        title: l10n.queue,
        queueItems: manualQueueItems,
        trailing: TextButton(
          onPressed: queueController.clear,
          child: Text(l10n.clear),
        ),
        onReorder: (oldIndex, newIndex) {
          queueController.move(
            manualQueueItems[oldIndex],
            before: newIndex < oldIndex ? manualQueueItems[newIndex] : null,
            after: oldIndex < newIndex ? manualQueueItems[newIndex] : null,
          );
        },
        onRemove: (index) {
          queueController.remove(manualQueueItems[index]);
        },
      ),
    );
  }
}

class Section extends MultiSliver {
  Section({
    super.key,
    required String title,
    required List<QueueItem> queueItems,
    required ReorderCallback onReorder,
    required ValueChanged<int> onRemove,
    Widget? trailing,
  }) : super(
          pushPinnedChildren: true,
          children: [
            SliverPinnedHeader(
              child: Builder(
                builder: (context) {
                  return ColoredBox(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: ListTile(
                      title: Text(title),
                      trailing: trailing,
                      contentPadding: const EdgeInsets.only(left: 20, right: 8),
                    ),
                  );
                },
              ),
            ),
            SliverReorderableList(
              itemBuilder: (context, index) => Dismissible(
                key: ValueKey(queueItems[index].id),
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
                    final episode = ref
                        .watch(episodeProvider(eid: queueItems[index].eid))
                        .maybeMap(
                          data: (data) => data.value,
                          orElse: () => null,
                        );
                    return episode == null
                        ? const SizedBox.shrink()
                        : EpisodeBriefTile(
                            key: ValueKey(queueItems[index].id),
                            episode: episode,
                            sortableIndex: index,
                            backgroundColor: Colors.transparent,
                            // queuedEpisodes[index].item.type ==
                            // QueueType.primary
                            //     ? Colors.transparent
                            //     : Colors.grey[200],
                          );
                  },
                ),
              ),
              itemCount: queueItems.length,
              onReorder: onReorder,
            ),
          ],
        );
}
