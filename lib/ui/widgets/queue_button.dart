// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/services/audio/audio_player_service.dart';
import 'package:seasoning/services/queue/queue_manager.dart';

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

class QueueButton extends ConsumerWidget {
  const QueueButton(
    this.episode, {
    super.key,
  });

  final Episode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(queueManagerProvider).queue;
    final playingEpisode =
        ref.watch(audioPlayerServiceProvider.select((state) => state?.episode));
    final queueIndex = queue.indexWhere((e) => e.guid == episode.guid);

    final theme = Theme.of(context);
    return PopupMenuButton<_Action>(
      onSelected: (_Action value) {
        final queueManager = ref.read(queueManagerProvider.notifier);

        switch (value) {
          case _Action.prepend:
            queueManager.prepend(episode);
          case _Action.append:
            queueManager.append(episode);
          case _Action.remove:
            queueManager.remove(queueIndex);
        }
      },
      child: Row(
        children: [
          Icon(
            0 <= queueIndex
                ? Icons.playlist_play_outlined
                : Icons.playlist_add_circle_outlined,
            size: 42,
          ),
          if (0 <= queueIndex)
            Text(
              episode.guid == playingEpisode?.guid ? '★' : '${queueIndex + 1}',
              style: theme.textTheme.bodyMedium,
            ),
        ],
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
