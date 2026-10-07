import 'package:audiflow_core/audiflow_core.dart'
    show AutoPlayOrder, SettingsDefaults;
import 'package:audiflow_domain/audiflow_domain.dart'
    show
        AudioSettingsScope,
        PlaybackEffect,
        PodcastAudioSettingsScope,
        Subscription,
        appSettingsRepositoryProvider,
        audioEffectsSupportedProvider,
        effectiveAudioSettingsProvider,
        hideExplicitForPodcastProvider,
        isRestrictedModeOnProvider,
        isUnlockedProvider,
        namedLoggerProvider,
        parentalControlRepositoryProvider,
        playOrderPreferenceRepositoryProvider,
        subscriptionByFeedUrlProvider,
        subscriptionRepositoryProvider;
import 'package:audiflow_search/audiflow_search.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../download/presentation/controllers/auto_download_keep_count_controller.dart';
import '../../../player/presentation/widgets/audio_sheet.dart'
    show setAudioEffect, setPodcastAudioOverride;
import 'play_order_bottom_sheet.dart';

/// Opens the podcast settings sheet (redesign 4.4): play order, the
/// podcast's own audio settings, auto-download, and display options in
/// one place.
Future<void> showPodcastSettingsSheet({
  required BuildContext context,
  required Podcast podcast,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (sheetContext) => PodcastSettingsSheet(podcast: podcast),
  );
}

@visibleForTesting
class PodcastSettingsSheet extends ConsumerWidget {
  const PodcastSettingsSheet({super.key, required this.podcast});

  final Podcast podcast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final feedUrl = podcast.feedUrl;
    final subscription = feedUrl == null
        ? null
        : ref.watch(subscriptionByFeedUrlProvider(feedUrl)).value;
    final owned = subscription != null && !subscription.isCached;

    return FractionallySizedBox(
      heightFactor: 1,
      child: ColoredBox(
        color: colors.bg,
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(title: podcast.name),
              Expanded(
                child: owned
                    ? _Sections(subscription: subscription, feedUrl: feedUrl!)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.xs,
        Spacing.sm,
        Spacing.screenHorizontal,
        Spacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            icon: Icon(Icons.close_rounded, color: colors.ink),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: Spacing.xs),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.sectionTitle.copyWith(color: colors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sections extends ConsumerWidget {
  const _Sections({required this.subscription, required this.feedUrl});

  final Subscription subscription;
  final String feedUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final restricted = ref.watch(isRestrictedModeOnProvider);
    final unlocked = ref.watch(isUnlockedProvider);
    // The explicit filter is only operable while unlocked.
    final showDisplay = !restricted || unlocked;

    return ListView(
      padding: const EdgeInsets.only(bottom: Spacing.xl),
      children: [
        GroupedSection(
          header: l10n.settingsPlaybackTitle,
          children: [_PlayOrderRow(subscriptionId: subscription.id)],
        ),
        const SizedBox(height: Spacing.lg),
        _AudioSection(podcastId: subscription.id),
        const SizedBox(height: Spacing.lg),
        _DownloadSection(subscription: subscription, feedUrl: feedUrl),
        if (showDisplay) ...[
          const SizedBox(height: Spacing.lg),
          GroupedSection(
            header: l10n.podcastSettingsDisplaySection,
            children: [_HideExplicitRow(subscriptionId: subscription.id)],
          ),
        ],
      ],
    );
  }
}

/// Play order picker; opens the play order sheet.
class _PlayOrderRow extends ConsumerStatefulWidget {
  const _PlayOrderRow({required this.subscriptionId});

  final int subscriptionId;

  @override
  ConsumerState<_PlayOrderRow> createState() => _PlayOrderRowState();
}

class _PlayOrderRowState extends ConsumerState<_PlayOrderRow> {
  AutoPlayOrder? _order;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final order = await ref
        .read(playOrderPreferenceRepositoryProvider)
        .getPodcastPlayOrder(widget.subscriptionId);
    if (mounted) setState(() => _order = order ?? AutoPlayOrder.defaultOrder);
  }

  AutoPlayOrder get _globalOrder =>
      ref.read(appSettingsRepositoryProvider).getAutoPlayOrder();

  String _label(AppLocalizations l10n, AutoPlayOrder order) =>
      order == AutoPlayOrder.defaultOrder
      ? l10n.playOrderDefault(playOrderLabel(l10n, _globalOrder))
      : playOrderLabel(l10n, order);

  void _pick() {
    final current = _order;
    if (current == null) return;
    showPlayOrderBottomSheet(
      context: context,
      currentOrder: current,
      resolvedParentOrder: _globalOrder,
      onOrderSelected: (order) async {
        await ref
            .read(playOrderPreferenceRepositoryProvider)
            .setPodcastPlayOrder(widget.subscriptionId, order);
        if (mounted) setState(() => _order = order);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final order = _order;
    return SettingsRow(
      title: l10n.playOrderMenuTitle,
      trailing: order == null
          ? null
          : SettingsTrailing.picker(value: _label(l10n, order)),
      onTap: _pick,
    );
  }
}

/// The podcast's own audio settings: a switch for the override, and the
/// effects while it is on. Speed is edited from the player only.
class _AudioSection extends ConsumerWidget {
  const _AudioSection({required this.podcastId});

  final int podcastId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final effective = ref.watch(effectiveAudioSettingsProvider(podcastId));
    final supported = ref.watch(audioEffectsSupportedProvider);
    if (effective == null) return const SizedBox.shrink();
    final AudioSettingsScope scope = effective.scope;
    final overridden = scope is PodcastAudioSettingsScope;

    SettingsRow effectRow(PlaybackEffect effect, String title) => SettingsRow(
      title: title,
      trailing: SettingsTrailing.toggle(
        value: effective.settings.effects.isEnabled(effect),
        onChanged: (enabled) =>
            setAudioEffect(ref, effect, enabled: enabled, scope: scope),
      ),
    );

    return GroupedSection(
      header: l10n.audioSheetTitle,
      children: [
        SettingsRow(
          title: l10n.audioSheetPodcastOverride,
          subtitle: overridden
              ? l10n.audioSheetScopePodcast
              : l10n.audioSheetScopeGlobal,
          trailing: SettingsTrailing.toggle(
            value: overridden,
            onChanged: (enabled) =>
                setPodcastAudioOverride(ref, podcastId, enabled: enabled),
          ),
        ),
        if (overridden && supported) ...[
          effectRow(PlaybackEffect.skipSilence, l10n.audioSheetSkipSilence),
          effectRow(PlaybackEffect.voiceBoost, l10n.audioSheetVoiceBoost),
        ],
      ],
    );
  }
}

class _DownloadSection extends ConsumerWidget {
  const _DownloadSection({required this.subscription, required this.feedUrl});

  final Subscription subscription;
  final String feedUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final paused =
        subscription.autoDownload && subscription.autoDownloadPausedAt != null;
    final globalKeepCount = ref
        .watch(appSettingsRepositoryProvider)
        .getAutoDownloadKeepCount();
    final keepCount = subscription.autoDownloadKeepCount;

    return GroupedSection(
      header: l10n.settingsDownloadsTitle,
      children: [
        SettingsRow(
          title: l10n.podcastAutoDownloadTitle,
          subtitle: l10n.podcastAutoDownloadSubtitle,
          trailing: SettingsTrailing.toggle(
            value: subscription.autoDownload,
            onChanged: (value) async {
              await ref
                  .read(subscriptionRepositoryProvider)
                  .updateAutoDownload(subscription.id, autoDownload: value);
              ref.invalidate(subscriptionByFeedUrlProvider(feedUrl));
            },
          ),
        ),
        if (paused)
          _PausedNotice(
            onResume: () async {
              await ref
                  .read(subscriptionRepositoryProvider)
                  .resetAutoDownloadActivity(subscription.id);
              ref.invalidate(subscriptionByFeedUrlProvider(feedUrl));
            },
          ),
        if (subscription.autoDownload)
          SettingsRow(
            title: l10n.downloadsKeepCountTitle,
            trailing: SettingsTrailing.picker(
              value: keepCount == null
                  ? l10n.downloadsKeepCountFollowGlobal(globalKeepCount)
                  : l10n.downloadsKeepCountOption(keepCount),
            ),
            onTap: () => _pickKeepCount(context, ref, globalKeepCount),
          ),
      ],
    );
  }

  Future<void> _pickKeepCount(
    BuildContext context,
    WidgetRef ref,
    int globalKeepCount,
  ) async {
    final l10n = AppLocalizations.of(context);
    final chosen = await showModalBottomSheet<_KeepCountChoice>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: RadioGroup<int?>(
          groupValue: subscription.autoDownloadKeepCount,
          onChanged: (value) =>
              Navigator.of(sheetContext).pop(_KeepCountChoice(value)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(Spacing.md),
                child: Text(
                  l10n.downloadsKeepCountTitle,
                  style: AppTextStyles.sectionTitle,
                ),
              ),
              RadioListTile<int?>(
                value: null,
                title: Text(
                  l10n.downloadsKeepCountFollowGlobal(globalKeepCount),
                ),
              ),
              for (final count in SettingsDefaults.autoDownloadKeepCountOptions)
                RadioListTile<int?>(
                  value: count,
                  title: Text(l10n.downloadsKeepCountOption(count)),
                ),
            ],
          ),
        ),
      ),
    );
    if (chosen == null) return;
    await ref
        .read(autoDownloadKeepCountControllerProvider.notifier)
        .setForPodcast(subscription.id, chosen.count);
    // The sheet may have closed while the trim ran.
    if (!context.mounted) return;
    ref.invalidate(subscriptionByFeedUrlProvider(feedUrl));
  }
}

/// Distinguishes "use default" (null count) from a dismissed picker.
class _KeepCountChoice {
  const _KeepCountChoice(this.count);

  final int? count;
}

/// Inline note shown while auto-download is paused, with a resume button.
class _PausedNotice extends StatelessWidget {
  const _PausedNotice({required this.onResume});

  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.all(Spacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.accentTint,
          borderRadius: AppBorders.card,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.md - Spacing.xxs,
            Spacing.sm,
            Spacing.xs,
            Spacing.sm,
          ),
          child: Row(
            children: [
              Icon(Icons.pause_circle_outline, color: colors.accent),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.podcastAutoDownloadPausedTitle,
                      style: AppTextStyles.label.copyWith(color: colors.ink),
                    ),
                    Text(
                      l10n.podcastAutoDownloadPausedSubtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: colors.inkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onResume,
                child: Text(l10n.podcastAutoDownloadResume),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HideExplicitRow extends ConsumerWidget {
  const _HideExplicitRow({required this.subscriptionId});

  final int subscriptionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final hideExplicit =
        ref.watch(hideExplicitForPodcastProvider(subscriptionId)).value ??
        false;
    return SettingsRow(
      title: l10n.parentalControlHideExplicitToggle,
      trailing: SettingsTrailing.toggle(
        value: hideExplicit,
        onChanged: (value) async {
          try {
            await ref
                .read(parentalControlRepositoryProvider)
                .setHideExplicit(subscriptionId, value);
          } catch (e, st) {
            ref
                .read(namedLoggerProvider('ParentalControl'))
                .e('setHideExplicit failed', error: e, stackTrace: st);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.parentalControlToggleFailed)),
              );
            }
          }
        },
      ),
    );
  }
}
