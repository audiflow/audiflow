import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import 'sleep_timer_sheet.dart';

/// Sleep-timer icon button for the full player's action row.
///
/// The icon switches between outlined (inactive) and filled (active)
/// variants. Tapping opens the sleep-timer sheet.
class SleepTimerIconButton extends ConsumerWidget {
  const SleepTimerIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(sleepTimerControllerProvider);
    final isActive = state.config is! SleepTimerConfigOff;
    final theme = Theme.of(context);

    return IconButton(
      tooltip: l10n.sleepTimerIconLabel,
      icon: Icon(
        isActive ? Icons.nights_stay : Icons.nights_stay_outlined,
        color: isActive ? theme.colorScheme.primary : null,
      ),
      onPressed: () => _open(context, ref),
    );
  }

  void _open(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return Consumer(
          builder: (ctx, ref, _) {
            final state = ref.watch(sleepTimerControllerProvider);
            final hasChaptersAsync = ref.watch(
              currentEpisodeHasChaptersProvider,
            );
            final hasChapters = hasChaptersAsync.value ?? false;
            final notifier = ref.read(sleepTimerControllerProvider.notifier);
            return SleepTimerSheet(
              state: state,
              hasChapters: hasChapters,
              onOff: () {
                notifier.setOff();
                Navigator.of(ctx).pop();
              },
              onEndOfEpisode: () {
                notifier.setEndOfEpisode();
                Navigator.of(ctx).pop();
              },
              onEndOfChapter: () {
                notifier.setEndOfChapter();
                Navigator.of(ctx).pop();
              },
              onDurationStart: (d) async {
                await notifier.setDuration(d);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              onEpisodesStart: (n) async {
                await notifier.setEpisodes(n);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
            );
          },
        );
      },
    );
  }
}
