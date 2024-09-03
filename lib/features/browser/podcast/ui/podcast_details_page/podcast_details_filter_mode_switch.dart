import 'dart:async';

import 'package:audiflow/constants/app_sizes.dart';
import 'package:audiflow/features/browser/common/model/episode_filter_mode.dart';
import 'package:audiflow/features/browser/common/model/season_filter_mode.dart';
import 'package:audiflow/features/browser/season/ui/season_list_controller.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class PodcastDetailsEpisodesFilterModeSwitch extends StatelessWidget {
  const PodcastDetailsEpisodesFilterModeSwitch({
    required this.filterMode,
    required this.onFilterModeChanged,
    required this.onToggleAscending,
    required this.count,
    super.key,
  });

  final EpisodeFilterMode filterMode;
  final FutureOr<void> Function(EpisodeFilterMode) onFilterModeChanged;
  final VoidCallback onToggleAscending;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () async {
            final mode = await _showFilterModeSelector(context, filterMode);
            if (mode != null) {
              onFilterModeChanged(mode);
            }
          },
          child: RichText(
            textAlign: TextAlign.end,
            text: TextSpan(
              children: [
                TextSpan(
                  text: filterMode.labelOf(l10n),
                  style: theme.textTheme.titleSmall
                      ?.copyWith(color: theme.colorScheme.primary),
                ),
                TextSpan(
                  text: count == null ? '\n' : '\n($count)',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: onToggleAscending,
          icon: const Icon(Symbols.swap_vert),
        ),
        gapW4,
      ],
    );
  }

  Future<EpisodeFilterMode?> _showFilterModeSelector(
    BuildContext context,
    EpisodeFilterMode current,
  ) async {
    final l10n = L10n.of(context);
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.episodeFilterMode,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              gapH12,
              ...EpisodeFilterMode.values.map((mode) {
                return ListTile(
                  selected: mode == current,
                  title: Text(mode.labelOf(l10n)),
                  trailing: mode == current ? const Icon(Symbols.check) : null,
                  onTap: () => Navigator.of(context).pop(mode),
                );
              }),
              gapH24,
            ],
          ),
        );
      },
    );
  }
}

class PodcastDetailsSeasonsFilterModeSwitch extends ConsumerWidget {
  const PodcastDetailsSeasonsFilterModeSwitch({
    required this.pid,
    required this.filterMode,
    required this.onFilterModeChanged,
    required this.onToggleAscending,
    super.key,
  });

  final int pid;
  final SeasonFilterMode filterMode;
  final FutureOr<void> Function(SeasonFilterMode) onFilterModeChanged;
  final VoidCallback onToggleAscending;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final pairs = ref.watch(seasonListControllerProvider(pid)).pairs;
    final count = pairs.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () async {
            final mode = await _showFilterModeSelector(context, filterMode);
            if (mode != null) {
              onFilterModeChanged(mode);
            }
          },
          child: RichText(
            textAlign: TextAlign.end,
            text: TextSpan(
              children: [
                TextSpan(
                  text: filterMode.labelOf(l10n),
                  style: theme.textTheme.titleSmall
                      ?.copyWith(color: theme.colorScheme.primary),
                ),
                TextSpan(
                  text: '\n($count)',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: onToggleAscending,
          icon: const Icon(Symbols.swap_vert),
        ),
        gapW4,
      ],
    );
  }

  Future<SeasonFilterMode?> _showFilterModeSelector(
    BuildContext context,
    SeasonFilterMode current,
  ) async {
    final l10n = L10n.of(context);
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.seasonFilterMode,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              gapH12,
              ...SeasonFilterMode.values.map((mode) {
                return ListTile(
                  selected: mode == current,
                  title: Text(mode.labelOf(l10n)),
                  trailing: mode == current ? const Icon(Symbols.check) : null,
                  onTap: () => Navigator.of(context).pop(mode),
                );
              }),
              gapH24,
            ],
          ),
        );
      },
    );
  }
}
