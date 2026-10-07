import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show CustomSemanticsAction;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/duration_label.dart';
import '../../../download/presentation/helpers/download_action_helper.dart';
import '../../../podcast_detail/presentation/screens/episode_detail_screen.dart';
import '../../../share/presentation/helpers/share_helper.dart';

/// Up-next row (redesign 4.6): artwork, two-line title, "duration · date"
/// with a downloaded mark, and a drag handle as the only trailing control.
/// Remove (swipe left) and download (swipe right) are swipe actions, also
/// offered to assistive technologies as custom actions.
class QueueListTile extends ConsumerWidget {
  const QueueListTile({
    super.key,
    required this.item,
    required this.index,
    required this.onRemove,
    required this.onTap,
  });

  static const double artworkSize = 48;

  /// Hairline inset so separators start at the text.
  static const double separatorIndent =
      Spacing.screenHorizontal + artworkSize + Spacing.sm + Spacing.xs;

  final QueueItemWithEpisode item;
  final int index;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final episodeId = item.episode.id;
    final downloadTask = ref.watch(episodeDownloadProvider(episodeId)).value;
    final downloaded = downloadTask?.downloadStatus is DownloadStatusCompleted;
    void download() => handleDownloadTap(
      context: context,
      ref: ref,
      episodeId: episodeId,
      task: downloadTask,
    );

    return Dismissible(
      key: ValueKey(item.queueItem.id),
      onDismissed: (_) => onRemove(),
      // A download swipe acts and springs back; only remove dismisses.
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) return true;
        download();
        return false;
      },
      background: _SwipeBackground(
        color: colors.accent,
        foreground: colors.onAccent,
        icon: downloaded ? Symbols.delete : Symbols.download,
        alignment: AlignmentDirectional.centerStart,
      ),
      secondaryBackground: _SwipeBackground(
        color: Theme.of(context).colorScheme.error,
        foreground: Theme.of(context).colorScheme.onError,
        icon: Symbols.playlist_remove,
        alignment: AlignmentDirectional.centerEnd,
      ),
      child: Semantics(
        customSemanticsActions: {
          CustomSemanticsAction(label: l10n.queueRemove): onRemove,
          CustomSemanticsAction(label: l10n.downloadEpisode): download,
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: onTap,
              onLongPress: () => _showContextMenu(context, ref),
              child: _row(context, colors, downloaded: downloaded),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: colors.hairline,
              indent: separatorIndent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    AppColors colors, {
    required bool downloaded,
  }) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: Spacing.screenHorizontal,
        top: Spacing.rowVertical,
        bottom: Spacing.rowVertical,
        end: Spacing.xs,
      ),
      child: Row(
        children: [
          MiniPlayerArtwork(
            imageUrl: item.artworkUrl,
            size: artworkSize,
            borderRadius: 12,
          ),
          const SizedBox(width: Spacing.sm + Spacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.episode.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.rowTitle.copyWith(color: colors.ink),
                ),
                const SizedBox(height: Spacing.xxs),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _metaText(l10n),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: colors.inkTertiary,
                        ),
                      ),
                    ),
                    if (downloaded) ...[
                      const SizedBox(width: Spacing.xs),
                      Icon(
                        Symbols.download_done,
                        size: 14,
                        color: colors.inkTertiary,
                        semanticLabel: l10n.queueDownloadedLabel,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          ReorderableDragStartListener(
            index: index,
            child: SizedBox.square(
              dimension: Spacing.minTouchTarget,
              child: Icon(Symbols.drag_handle, color: colors.inkTertiary),
            ),
          ),
        ],
      ),
    );
  }

  String _metaText(AppLocalizations l10n) {
    final durationMs = item.episode.durationMs;
    final publishedAt = item.episode.publishedAt;
    return [
      if (durationMs != null)
        l10n.durationLabel(Duration(milliseconds: durationMs)),
      if (publishedAt != null)
        publishedAt.formatEpisodeDate(
          todayLabel: l10n.dateToday,
          yesterdayLabel: l10n.dateYesterday,
        ),
    ].join(' · ');
  }

  void _showContextMenu(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.3,
        minChildSize: 0.2,
        maxChildSize: 0.5,
        builder: (sheetContext, scrollController) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: Spacing.sm),
                decoration: BoxDecoration(
                  color: Theme.of(
                    sheetContext,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.xs,
                ),
                child: Text(
                  item.episode.title,
                  style: Theme.of(sheetContext).textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text(l10n.goToEpisode),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _navigateToEpisodeDetail(context, ref);
                      },
                    ),
                    if (item.itunesId != null && item.episode.guid.isNotEmpty)
                      ListTile(
                        leading: const Icon(Icons.ios_share),
                        title: Text(l10n.shareEpisode),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          shareEpisode(
                            context: context,
                            ref: ref,
                            itunesId: item.itunesId,
                            episodeGuid: item.episode.guid,
                            fallbackLink: null,
                          );
                        },
                      ),
                    const SizedBox(height: Spacing.sm),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToEpisodeDetail(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final subscription = await ref
        .read(subscriptionRepositoryProvider)
        .getById(item.episode.podcastId);

    if (!context.mounted) return;

    final podcastTitle = subscription?.title ?? '';
    final feedUrl = subscription?.feedUrl ?? '';
    final resolvedArtwork =
        item.artworkUrl ?? subscription?.artworkUrl ?? item.episode.imageUrl;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EpisodeDetailScreen(
          episode: item.episode.toPodcastItem(feedUrl: feedUrl),
          podcastTitle: podcastTitle,
          artworkUrl: resolvedArtwork,
          itunesId: item.itunesId,
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.color,
    required this.foreground,
    required this.icon,
    required this.alignment,
  });

  final Color color;
  final Color foreground;
  final IconData icon;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.screenHorizontal,
          ),
          child: Icon(icon, color: foreground),
        ),
      ),
    );
  }
}
