import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';

/// Persistent status chip rendered above the mini player while a sleep
/// timer is active.
///
/// Renders nothing when the config is `off`. For duration timers it
/// refreshes once per second.
class SleepTimerChip extends ConsumerStatefulWidget {
  const SleepTimerChip({super.key});

  @override
  ConsumerState<SleepTimerChip> createState() => _SleepTimerChipState();
}

class _SleepTimerChipState extends ConsumerState<SleepTimerChip> {
  Timer? _uiTimer;

  @override
  void initState() {
    super.initState();
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sleepTimerControllerProvider);
    final l10n = AppLocalizations.of(context);

    final label = _labelFor(state.config, l10n);
    if (label == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Chip(
          avatar: const Icon(Icons.nights_stay, size: 16),
          label: Text(label),
          onDeleted: () {
            ref.read(sleepTimerControllerProvider.notifier).setOff();
          },
          deleteIcon: const Icon(Icons.close, size: 16),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  String? _labelFor(SleepTimerConfig config, AppLocalizations l10n) {
    return switch (config) {
      SleepTimerConfigOff() => null,
      SleepTimerConfigEndOfEpisode() => l10n.sleepTimerChipEpisodeEnd,
      SleepTimerConfigEndOfChapter() => l10n.sleepTimerChipChapterEnd,
      SleepTimerConfigEpisodes(:final remaining) =>
        l10n.sleepTimerChipEpisodesLeft(remaining),
      SleepTimerConfigDuration(:final deadline) =>
        '${l10n.sleepTimerChipDurationPrefix}${_formatRemaining(deadline)}',
    };
  }

  String _formatRemaining(DateTime deadline) {
    final remaining = deadline.difference(DateTime.now());
    final clamped = remaining.isNegative ? Duration.zero : remaining;
    final totalSeconds = clamped.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    String pad2(int v) => v.toString().padLeft(2, '0');
    if (0 < hours) return '${pad2(hours)}:${pad2(minutes)}:${pad2(seconds)}';
    return '${pad2(minutes)}:${pad2(seconds)}';
  }
}
