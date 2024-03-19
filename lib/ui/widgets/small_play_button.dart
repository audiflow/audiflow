// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:audiflow/core/l10n.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/services/audio/audio_player_service.dart';
import 'package:audiflow/ui/providers/episode_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class SmallPlayButton extends ConsumerWidget {
  const SmallPlayButton({
    required this.episode,
    required this.onPressed,
    super.key,
  });

  final Episode episode;
  final VoidCallback? onPressed;
  static const size = Size(60, 26);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final style = ElevatedButton.styleFrom(
      shape: const StadiumBorder(),
      backgroundColor: theme.colorScheme.surfaceVariant,
      foregroundColor: theme.colorScheme.onSurfaceVariant,
      minimumSize: size,
      padding: const EdgeInsets.only(left: 8, right: 12),
    );

    final (isPlaying, playerPosition) = ref.watch(
      audioPlayerServiceProvider.select(
        (state) {
          return state?.episode.guid == episode.guid
              ? (state?.phase == PlayerPhase.play, state?.position)
              : (false, null);
        },
      ),
    );
    final stats = ref.watch(episodeInfoProvider(episode)).value?.stats;
    final duration = episode.duration ?? Duration.zero;
    final position = playerPosition ?? stats?.position ?? Duration.zero;
    final finished = duration - position < Duration.zero;
    final remains = finished ? duration : duration - position;
    final percentage =
        position.inMilliseconds / math.max(duration.inMilliseconds, 1);
    return Column(
      children: [
        FilledButton(
          onPressed: onPressed,
          style: style,
          child: DefaultTextStyle(
            style: theme.textTheme.labelSmall!
                .copyWith(color: theme.colorScheme.onTertiaryContainer),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPlaying
                      ? Symbols.pause_rounded
                      : finished
                          ? Symbols.replay_rounded
                          : Symbols.play_arrow_rounded,
                  size: 16,
                ),
                if (0 < percentage && percentage < 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, right: 2),
                    child: _SmallProgressBar(percentage: percentage),
                  ),
                Text(_duration(context, remains)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _duration(BuildContext context, Duration remaining) {
    if (remaining.inSeconds < 60) {
      final seconds = math.max(0, remaining.inSeconds);
      return '$seconds${L10n.of(context)!.sec}';
    }
    final minutes = math.max(
      0,
      remaining.inMinutes + (0 < remaining.inSeconds.remainder(60) ? 1 : 0),
    );
    return '$minutes${L10n.of(context)!.min}';
  }
}

class _SmallProgressBar extends StatelessWidget {
  const _SmallProgressBar({
    required this.percentage,
  });

  final double percentage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      child: LinearProgressIndicator(
        minHeight: 3,
        value: percentage,
        backgroundColor: Theme.of(context).colorScheme.surface,
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
