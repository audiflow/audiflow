import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import 'sleep_timer_countdown_format.dart';
import 'sleep_timer_sheet.dart';

/// Sleep-timer icon button for the full player's action row and the
/// tablet mini player.
///
/// The icon switches between outlined (inactive) and filled (active)
/// variants and shows nothing else; the time left appears in the seek bar.
/// Screen readers hear the full status, e.g. "Sleep timer, stops at end of
/// episode, 12 minutes left". Tapping opens the sleep-timer sheet via
/// [showSleepTimerSheet].
class SleepTimerIconButton extends ConsumerWidget {
  const SleepTimerIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final config = ref.watch(
      sleepTimerControllerProvider.select((state) => state.config),
    );
    final isActive = config is! SleepTimerConfigOff;
    final theme = Theme.of(context);
    final semanticsLabel = isActive
        ? sleepTimerSemanticsLabel(
            config,
            ref.watch(sleepTimerTimeLeftProvider),
            l10n,
            includeMode: true,
          )
        : null;

    final button = IconButton(
      tooltip: l10n.sleepTimerIconLabel,
      icon: Icon(
        isActive ? Icons.nights_stay : Icons.nights_stay_outlined,
        color: isActive ? theme.colorScheme.primary : null,
      ),
      onPressed: () => showSleepTimerSheet(context),
    );
    if (semanticsLabel == null) return button;
    // The tooltip names the button; while a timer runs the label carries
    // the status too, so it replaces the tooltip for screen readers.
    return Semantics(
      container: true,
      button: true,
      label: semanticsLabel,
      onTap: () => showSleepTimerSheet(context),
      child: ExcludeSemantics(child: button),
    );
  }
}

/// Opens the sleep-timer sheet wired to [sleepTimerControllerProvider].
Future<void> showSleepTimerSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    // Match the full player's column so the sheet doesn't span a tablet.
    constraints: const BoxConstraints(
      maxWidth: LayoutConstants.contentMaxWidth,
    ),
    builder: (ctx) {
      return Consumer(
        builder: (ctx, ref, _) {
          final state = ref.watch(sleepTimerControllerProvider);
          final hasChaptersAsync = ref.watch(currentEpisodeHasChaptersProvider);
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
            onCloseSheet: () => Navigator.of(ctx).pop(),
          );
        },
      );
    },
  );
}
