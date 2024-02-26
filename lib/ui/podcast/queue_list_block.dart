import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/services/queue/queue_list_provider.dart';
import 'package:seasoning/services/queue/queue_manager.dart';
import 'package:seasoning/ui/podcast/episode_brief_tile.dart';
import 'package:sliver_tools/sliver_tools.dart';

class QueueListBlock extends ConsumerWidget {
  const QueueListBlock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueState = ref.watch(queueListProvider);
    if (queueState.primary.isEmpty && queueState.adhoc.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return Section(
      title: 'Queue',
      episodes: queueState.primary,
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
              itemBuilder: (context, index) => ReorderableDragStartListener(
                index: index,
                key: ValueKey(episodes[index].guid),
                child: EpisodeBriefTile(
                  episode: episodes[index],
                ),
              ),
              itemCount: episodes.length,
              onReorder: onReorder,
            ),
          ],
        );
}
