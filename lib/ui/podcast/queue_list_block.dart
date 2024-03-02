import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seasoning/core/types.dart';
import 'package:seasoning/services/podcast/podcast_service_provider.dart';
import 'package:seasoning/services/queue/queue_list_provider.dart';
import 'package:seasoning/services/queue/queue_manager.dart';
import 'package:seasoning/ui/podcast/episode_brief_tile.dart';
import 'package:sliver_tools/sliver_tools.dart';

class QueueListBlock extends ConsumerWidget {
  const QueueListBlock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(queueListProvider).queue;
    if (queue.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return NotificationListener<PlayButtonTappedNotification>(
      onNotification: (notification) {
        final episode = notification.episode;
        final index = notification.index;
        if (index == null || queue.length <= index) {
          ref.read(podcastServiceProvider).handlePlay(episode);
        } else {
          ref
              .read(podcastServiceProvider)
              .handlePlayFromQueue(queue[index].item, queue[index].episode);
        }
        return false;
      },
      child: Section(
        title: 'Queue',
        queuedEpisodes: queue,
        onReorder: (oldIndex, newIndex) =>
            ref.read(queueManagerProvider.notifier).reorder(oldIndex, newIndex),
      ),
    );
  }
}

class Section extends MultiSliver {
  Section({
    super.key,
    required String title,
    Color titleColor = Colors.black,
    required List<QueuedEpisode> queuedEpisodes,
    required ReorderCallback onReorder,
  }) : super(
          pushPinnedChildren: true,
          children: [
            SliverPinnedHeader(
              child: Builder(
                builder: (context) {
                  return ColoredBox(
                    color: Theme.of(context).colorScheme.background,
                    child: ListTile(
                      textColor: titleColor,
                      title: Text(title),
                    ),
                  );
                },
              ),
            ),
            SliverReorderableList(
              itemBuilder: (context, index) => EpisodeBriefTile(
                key: ValueKey(queuedEpisodes[index].item.id),
                episode: queuedEpisodes[index].episode,
                sortableIndex: index,
              ),
              itemCount: queuedEpisodes.length,
              onReorder: onReorder,
            ),
          ],
        );
}
