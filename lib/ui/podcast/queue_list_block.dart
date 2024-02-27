import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/services/queue/queue_list_provider.dart';
import 'package:seasoning/services/queue/queue_manager.dart';
import 'package:seasoning/ui/podcast/episode_brief_tile.dart';
import 'package:sliver_tools/sliver_tools.dart';

class QueueListBlock extends ConsumerWidget {
  const QueueListBlock({required this.queueType, super.key});

  final QueueType queueType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueState = ref.watch(queueListProvider);
    final queue =
        queueType == QueueType.primary ? queueState.primary : queueState.adhoc;
    if (queue.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return Section(
      title: queueType == QueueType.primary ? 'Queue' : 'Adhoc Queue',
      episodes: queue,
      onReorder: (oldIndex, newIndex) =>
          ref.read(queueManagerProvider.notifier).reorder(oldIndex, newIndex),
    );
  }
}

class Section extends MultiSliver {
  Section({
    super.key,
    required String title,
    Color titleColor = Colors.black,
    required List<Episode> episodes,
    required ReorderCallback onReorder,
  }) : super(
          pushPinnedChildren: true,
          children: [
            SliverPinnedHeader(
              child: ListTile(
                textColor: titleColor,
                title: Text(title),
              ),
            ),
            SliverReorderableList(
              itemBuilder: (context, index) => EpisodeBriefTile(
                key: ValueKey(episodes[index].guid),
                episode: episodes[index],
                sortableIndex: index,
              ),
              itemCount: episodes.length,
              onReorder: onReorder,
            ),
          ],
        );
}
