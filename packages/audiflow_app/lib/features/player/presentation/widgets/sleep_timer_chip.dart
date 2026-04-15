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
  void dispose() {
    _uiTimer?.cancel();
    super.dispose();
  }

  /// Starts a 1Hz repaint timer only while a duration timer is active.
  /// Other config kinds don't need a continuous countdown, so we avoid
  /// the per-second rebuilds entirely.
  void _ensureTimer(SleepTimerConfig config) {
    final isDuration = config is SleepTimerConfigDuration;
    if (isDuration && _uiTimer == null) {
      _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else if (!isDuration && _uiTimer != null) {
      _uiTimer!.cancel();
      _uiTimer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // React to subsequent config changes (e.g. duration -> off).
    ref.listen<SleepTimerState>(sleepTimerControllerProvider, (prev, next) {
      _ensureTimer(next.config);
    });

    final state = ref.watch(sleepTimerControllerProvider);
    // Initial-state handling on first build. _ensureTimer never calls
    // setState, so it's safe to invoke synchronously inside build().
    _ensureTimer(state.config);

    final l10n = AppLocalizations.of(context);

    final label = formatSleepTimerShortLabel(state.config, l10n);
    if (label == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Align(
        alignment: Alignment.centerRight,
        child: Chip(
          avatar: const Icon(Icons.nights_stay, size: 16),
          label: Text(label),
          labelStyle: Theme.of(context).textTheme.labelSmall,
          labelPadding: const EdgeInsets.symmetric(horizontal: 6),
          visualDensity: VisualDensity.compact,
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
