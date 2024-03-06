import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seasoning/services/audio/audio_player_service.dart';

class SeekBar extends HookConsumerWidget {
  const SeekBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (position, duration, audioState) = ref.watch(
      audioPlayerServiceProvider.select(
        (state) =>
            (state?.position, state?.episode.duration, state?.audioState),
      ),
    );

    // print('position: $position, audioState: $audioState');

    final seekPosState = useState<Duration?>(null);
    final pos = seekPosState.value ?? position;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: _Bar(
            position: pos,
            duration: duration,
            onChangeStart: (value) {
              seekPosState.value = value;
            },
            onChanged: (value) {
              seekPosState.value = value;
            },
            onChangeEnd: (value) {
              ref
                  .read(audioPlayerServiceProvider.notifier)
                  .seek(position: value);
              seekPosState.value = null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TimeLabel(time: pos),
              _TimeLabel(
                time: pos == null || duration == null ? null : (pos - duration),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Bar extends HookWidget {
  const _Bar({
    required this.position,
    required this.duration,
    required this.onChangeStart,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final Duration? position;
  final Duration? duration;
  final ValueChanged<Duration> onChangeStart;
  final ValueChanged<Duration> onChanged;
  final ValueChanged<Duration> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final state = useState<double?>(null);

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
        overlayColor: Colors.transparent,
      ),
      child: (position == null || duration == null)
          ? const Slider(value: 0, onChanged: null)
          : Slider(
              value: position!.inMilliseconds.toDouble(),
              max: duration!.inMilliseconds.toDouble(),
              onChanged: (value) {
                if (state.value == null) {
                  state.value = value - position!.inMilliseconds.toDouble();
                  onChangeStart(position!);
                } else {
                  onChanged(
                    _normalizedPosition(milliseconds: value - state.value!),
                  );
                }
              },
              onChangeEnd: (value) {
                if (state.value != null) {
                  onChangeEnd(
                    _normalizedPosition(milliseconds: value - state.value!),
                  );
                  state.value = null;
                }
              },
            ),
    );
  }

  Duration _normalizedPosition({
    required double milliseconds,
  }) {
    final total = duration!.inMilliseconds.toDouble();
    return Duration(
      milliseconds: math.max(0, math.min(total, milliseconds).toInt()),
    );
  }
}

class _TimeLabel extends StatelessWidget {
  const _TimeLabel({
    required this.time,
  });

  final Duration? time;

  @override
  Widget build(BuildContext context) {
    return Text(
      time?.format() ?? '',
      style: Theme.of(context)
          .textTheme
          .labelMedium!
          .copyWith(color: Colors.grey[600]),
    );
  }
}

extension _DurationExt on Duration {
  String format() {
    final minutes = inMinutes;
    final seconds = inSeconds.remainder(60).abs().toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
