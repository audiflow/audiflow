import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import 'sleep_timer_label_format.dart';

/// Inline status text rendered next to the sleep-timer icon on the
/// full player screen. Shows nothing when no timer is running.
///
/// Refreshes once per second while a duration timer is active so the
/// countdown stays current.
class SleepTimerStatusLabel extends ConsumerStatefulWidget {
  const SleepTimerStatusLabel({super.key});

  @override
  ConsumerState<SleepTimerStatusLabel> createState() =>
      _SleepTimerStatusLabelState();
}

class _SleepTimerStatusLabelState extends ConsumerState<SleepTimerStatusLabel> {
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

    final theme = Theme.of(context);
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.primary,
      ),
    );
  }
}
