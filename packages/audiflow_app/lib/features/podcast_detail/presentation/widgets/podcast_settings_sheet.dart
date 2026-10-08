import 'package:audiflow_core/audiflow_core.dart'
    show AutoPlayOrder, SettingsDefaults;
import 'package:audiflow_domain/audiflow_domain.dart'
    show
        Subscription,
        appSettingsRepositoryProvider,
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
import 'play_order_bottom_sheet.dart';

/// Opens the podcast settings sheet (redesign 4.4): play order,
/// auto-download, and display options in one place. Audio settings stay
/// in the player's Audio sheet.
///
/// [onPlayOrderChanged] runs once a new play order has been saved, which
/// may be after the sheet has closed.
Future<void> showPodcastSettingsSheet({
  required BuildContext context,
  required Podcast podcast,
  VoidCallback? onPlayOrderChanged,
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
    builder: (sheetContext) => PodcastSettingsSheet(
      podcast: podcast,
      onPlayOrderChanged: onPlayOrderChanged,
    ),
  );
}

@visibleForTesting
class PodcastSettingsSheet extends ConsumerWidget {
  const PodcastSettingsSheet({
    super.key,
    required this.podcast,
    this.onPlayOrderChanged,
  });

  final Podcast podcast;
  final VoidCallback? onPlayOrderChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final feedUrl = podcast.feedUrl;
    final subscription = feedUrl == null
        ? null
        : ref.watch(subscriptionByFeedUrlProvider(feedUrl)).value;
    final owned = subscription != null && !subscription.isCached;

    // A Scaffold of its own, so snackbars (e.g. a failed save) show above
    // this full-height sheet instead of behind it.
    return FractionallySizedBox(
      heightFactor: 1,
      child: Scaffold(
        backgroundColor: colors.bg,
        body: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(title: podcast.name),
              Expanded(
                child: owned
                    ? _Sections(
                        subscription: subscription,
                        feedUrl: feedUrl!,
                        onPlayOrderChanged: onPlayOrderChanged,
                      )
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
  const _Sections({
    required this.subscription,
    required this.feedUrl,
    this.onPlayOrderChanged,
  });

  final Subscription subscription;
  final String feedUrl;
  final VoidCallback? onPlayOrderChanged;

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
          children: [
            _PlayOrderRow(
              subscriptionId: subscription.id,
              onChanged: onPlayOrderChanged,
            ),
          ],
        ),
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
  const _PlayOrderRow({required this.subscriptionId, this.onChanged});

  final int subscriptionId;

  /// Runs after the new order is saved, even if the sheet closed first.
  final VoidCallback? onChanged;

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
      ? playOrderInheritLabel(l10n, _globalOrder, parentIsGlobal: true)
      : playOrderLabel(l10n, order);

  void _pick() {
    final current = _order;
    if (current == null) return;
    showPlayOrderBottomSheet(
      context: context,
      currentOrder: current,
      resolvedParentOrder: _globalOrder,
      parentIsGlobal: true,
      onOrderSelected: (order) async {
        // Read before awaiting: the sheet may close meanwhile.
        final repository = ref.read(playOrderPreferenceRepositoryProvider);
        final logger = ref.read(namedLoggerProvider('PodcastSettings'));
        final messenger = ScaffoldMessenger.of(context);
        final failed = AppLocalizations.of(context).podcastSettingsSaveFailed;
        try {
          await repository.setPodcastPlayOrder(widget.subscriptionId, order);
        } catch (error, stackTrace) {
          logger.w(
            'Failed to save play order',
            error: error,
            stackTrace: stackTrace,
          );
          if (mounted) messenger.showSnackBar(SnackBar(content: Text(failed)));
          return;
        }
        widget.onChanged?.call();
        if (mounted) setState(() => _order = order);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final order = _order;
    // The value goes under the title: "Default (oldest first)" is too
    // long for the trailing slot and would be cut off.
    return SettingsRow(
      title: l10n.playOrderMenuTitle,
      subtitle: order == null ? null : _label(l10n, order),
      trailing: const SettingsTrailing.chevron(),
      onTap: _pick,
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
            subtitle: keepCount == null
                ? l10n.downloadsKeepCountFollowGlobal(globalKeepCount)
                : l10n.downloadsKeepCountOption(keepCount),
            trailing: const SettingsTrailing.chevron(),
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
    // Scrollable and allowed to grow: a short phone or landscape cannot
    // fit the heading and every choice.
    final chosen = await showModalBottomSheet<_KeepCountChoice>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: RadioGroup<int?>(
          groupValue: subscription.autoDownloadKeepCount,
          onChanged: (value) =>
              Navigator.of(sheetContext).pop(_KeepCountChoice(value)),
          child: ListView(
            shrinkWrap: true,
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
