import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import 'sleep_timer_label_format.dart';

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

    final label = formatSleepTimerLabel(state.config, l10n);
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
}
