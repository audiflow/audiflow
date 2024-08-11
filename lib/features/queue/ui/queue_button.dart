import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/features/queue/model/queue.dart';
import 'package:audiflow/features/queue/service/queue_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

enum _Action {
  prepend,
  append,
  remove;

  String get label {
    switch (this) {
      case _Action.prepend:
        return 'Prepend';
      case _Action.append:
        return 'Append';
      case _Action.remove:
        return 'Remove';
    }
  }
}

class QueueButton extends HookConsumerWidget {
  const QueueButton(
    this.episode, {
    super.key,
  });

  final Episode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(queueControllerProvider).queue;
    final queueIndex = queue.indexWhere((e) => e.eid == episode.id);

    final theme = Theme.of(context);
    final style = OutlinedButton.styleFrom(
      shape: const StadiumBorder(),
      foregroundColor: theme.hintColor,
      minimumSize: const Size(40, 26),
      padding: const EdgeInsets.only(left: 10, right: 10),
      side: BorderSide(color: theme.hintColor),
    );

    final key = useState(GlobalKey<PopupMenuButtonState<_Action>>()).value;
    return PopupMenuButton<_Action>(
      key: key,
      enabled: false,
      tooltip: '',
      onSelected: (_Action value) {
        final queueManager = ref.read(queueControllerProvider.notifier);

        switch (value) {
          case _Action.prepend:
            queueManager.prepend(
              QueueItem.primary(pid: episode.pid, eid: episode.id),
            );
          case _Action.append:
            queueManager.append(
              QueueItem.primary(pid: episode.pid, eid: episode.id),
            );
          case _Action.remove:
            queueManager.removeByIndex(queueIndex);
        }
      },
      child: OutlinedButton(
        onPressed: () {
          if (queueIndex < 0) {
            ref.read(queueControllerProvider.notifier).append(
                  QueueItem.primary(pid: episode.pid, eid: episode.id),
                );
          } else {
            ref
                .read(queueControllerProvider.notifier)
                .removeByIndex(queueIndex);
          }
        },
        onLongPress: () {
          key.currentState!.showButtonMenu();
        },
        style: style,
        child: Row(
          children: [
            Icon(
              0 <= queueIndex
                  ? Symbols.playlist_add_check_rounded
                  : Symbols.playlist_add_rounded,
              size: 18,
            ),
            if (0 <= queueIndex)
              Padding(
                padding: const EdgeInsets.only(left: 3),
                child: Text(
                  '${queueIndex + 1}',
                  style: theme.textTheme.bodySmall!
                      .copyWith(color: theme.hintColor),
                ),
              ),
          ],
        ),
      ),
      itemBuilder: (context) {
        return _Action.values
            .map(
              (mode) => PopupMenuItem(
                value: mode,
                child: Text(mode.label),
              ),
            )
            .toList();
      },
    );
  }
}
