// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:seasoning/core/l10n.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/providers/podcast/episode_info_provider.dart';
import 'package:seasoning/services/audio/audio_player_service.dart';

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
      backgroundColor: theme.colorScheme.tertiaryContainer,
      foregroundColor: theme.colorScheme.onTertiaryContainer,
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
    final duration = episode.duration ?? stats?.duration ?? Duration.zero;
    final position = playerPosition ?? stats?.position ?? Duration.zero;
    final remains = duration - position;
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
                      : Symbols.play_arrow_rounded,
                ),
                if (0 < percentage && percentage < 1)
                  Padding(
                    padding: const EdgeInsets.only(left:4, right: 2),
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

  String _duration(BuildContext context, Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}${L10n.of(context)!.sec}';
    }
    final minutes =
        duration.inMinutes + (0 < duration.inSeconds.remainder(60) ? 1 : 0);
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
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
