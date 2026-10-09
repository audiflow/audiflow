import 'dart:async';

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
import '../../../download/presentation/widgets/keep_download_menu_tile.dart';
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
    final downloadAction = _DownloadSwipeAction.of(
      downloadTask,
      l10n,
      colors,
      error: Theme.of(context).colorScheme.error,
      onError: Theme.of(context).colorScheme.onError,
    );
    // Acts on the task as it is now, not as it was when the row (or its
    // menu) was built: the download may have moved on since.
    Future<void> download() async {
      final current = ref.read(episodeDownloadProvider(episodeId)).value;
      if (current != null) {
        await handleDownloadTap(
          context: context,
          ref: ref,
          episodeId: episodeId,
          task: current,
        );
        return;
      }
      final messenger = ScaffoldMessenger.of(context);
      final created = await ref
          .read(downloadServiceProvider)
          .downloadEpisode(episodeId);
      // The swipe springs back, so confirm a download that really started;
      // none is created when one already exists.
      if (created != null) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.downloadStarted)));
      }
    }

    return Dismissible(
      key: ValueKey(item.queueItem.id),
      onDismissed: (_) => onRemove(),
      // A download swipe acts and springs back; only remove dismisses.
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) return true;
        unawaited(download());
        return false;
      },
      // Shows what this swipe will do now, which follows the download
      // state (the same step as tapping a download button).
      background: _SwipeBackground(
        color: downloadAction.color,
        foreground: downloadAction.foreground,
        icon: downloadAction.icon,
        label: downloadAction.label,
        alignment: AlignmentDirectional.centerStart,
      ),
      secondaryBackground: _SwipeBackground(
        color: Theme.of(context).colorScheme.error,
        foreground: Theme.of(context).colorScheme.onError,
        icon: Symbols.playlist_remove,
        label: l10n.queueRemove,
        alignment: AlignmentDirectional.centerEnd,
      ),
      child: Semantics(
        customSemanticsActions: {
          CustomSemanticsAction(label: l10n.queueRemove): onRemove,
          CustomSemanticsAction(label: downloadAction.menuLabel): () =>
              unawaited(download()),
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: AlignmentDirectional.centerEnd,
              children: [
                InkWell(
                  onTap: onTap,
                  onLongPress: () => _showContextMenu(
                    context,
                    ref,
                    downloadAction,
                    download,
                    downloadTask,
                  ),
                  child: _row(context, colors, downloadTask),
                ),
                // Stacked above the row's InkWell rather than inside it, so
                // holding the handle before dragging never fires the row's
                // long press and opens its menu instead of reordering.
                _dragHandle(colors),
              ],
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
    AppColors colors,
    DownloadTask? downloadTask,
  ) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: Spacing.screenHorizontal,
        top: Spacing.rowVertical,
        bottom: Spacing.rowVertical,
        // Room for the drag handle stacked over the row's end.
        end: Spacing.xs + Spacing.minTouchTarget,
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
                    Expanded(
                      child: Text(
                        _metaText(l10n),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: colors.inkTertiary,
                        ),
                      ),
                    ),
                    if (downloadTask != null)
                      QueueDownloadMark(task: downloadTask),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dragHandle(AppColors colors) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: Spacing.xs),
      child: ReorderableDragStartListener(
        index: index,
        // Opaque, so the whole target catches touches, not just the glyph;
        // a near miss would otherwise land on the row's long press.
        child: ColoredBox(
          color: Colors.transparent,
          child: SizedBox.square(
            dimension: Spacing.minTouchTarget,
            child: Icon(Symbols.drag_handle, color: colors.inkTertiary),
          ),
        ),
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

  /// Long-press sheet: go to the episode, keep an auto download, the same
  /// next download step as the right swipe, and share.
  void _showContextMenu(
    BuildContext context,
    WidgetRef ref,
    _DownloadSwipeAction downloadAction,
    Future<void> Function() download,
    DownloadTask? downloadTask,
  ) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.4,
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
                    if (downloadTask case final task?
                        when task.isRemovableByRetention)
                      KeepDownloadMenuTile(
                        onTap: () {
                          Navigator.pop(sheetContext);
                          unawaited(
                            keepDownload(
                              context: context,
                              ref: ref,
                              task: task,
                            ),
                          );
                        },
                      ),
                    ListTile(
                      leading: Icon(downloadAction.icon),
                      title: Text(downloadAction.menuLabel),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        unawaited(download());
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

/// The step a right swipe takes for the current download state, matching
/// what `handleDownloadTap` does for it.
class _DownloadSwipeAction {
  const _DownloadSwipeAction(
    this.icon,
    this.label,
    this.menuLabel,
    this.color,
    this.foreground,
  );

  factory _DownloadSwipeAction.of(
    DownloadTask? task,
    AppLocalizations l10n,
    AppColors colors, {
    required Color error,
    required Color onError,
  }) {
    final status = task?.downloadStatus;
    final neutral = colors.inkSecondary;
    final onNeutral = colors.surface;
    return switch (status) {
      null || DownloadStatusCancelled() => _DownloadSwipeAction(
        Symbols.download,
        l10n.queueSwipeDownload,
        l10n.queueMenuDownload,
        colors.accent,
        colors.onAccent,
      ),
      DownloadStatusPending() => _DownloadSwipeAction(
        Symbols.close,
        l10n.queueSwipeCancel,
        l10n.queueMenuCancelDownload,
        neutral,
        onNeutral,
      ),
      DownloadStatusDownloading() => _DownloadSwipeAction(
        Symbols.pause,
        l10n.queueSwipePause,
        l10n.queueMenuPauseDownload,
        neutral,
        onNeutral,
      ),
      DownloadStatusPaused() => _DownloadSwipeAction(
        Symbols.play_arrow,
        l10n.queueSwipeResume,
        l10n.queueMenuResumeDownload,
        colors.accent,
        colors.onAccent,
      ),
      DownloadStatusFailed() => _DownloadSwipeAction(
        Symbols.refresh,
        l10n.queueSwipeRetry,
        l10n.queueMenuRetryDownload,
        colors.accent,
        colors.onAccent,
      ),
      DownloadStatusCompleted() => _DownloadSwipeAction(
        Symbols.delete,
        l10n.queueSwipeDelete,
        l10n.queueMenuDeleteDownload,
        error,
        onError,
      ),
    };
  }

  final IconData icon;

  /// Short label under the swipe icon.
  final String label;

  /// Self-explanatory label for menus and assistive technologies, where
  /// "Pause" alone could read as pausing playback.
  final String menuLabel;
  final Color color;
  final Color foreground;
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.color,
    required this.foreground,
    required this.icon,
    required this.label,
    required this.alignment,
  });

  final Color color;
  final Color foreground;
  final IconData icon;
  final String label;
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: foreground),
              const SizedBox(height: Spacing.xxs),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Download state after the row's meta text: a check once downloaded, a
/// progress ring with the percentage while downloading, and a labeled
/// icon while waiting, paused, or failed. Nothing before a download or
/// after a cancel.
class QueueDownloadMark extends StatelessWidget {
  const QueueDownloadMark({super.key, required this.task});

  final DownloadTask task;

  static const double _iconSize = 14;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final error = Theme.of(context).colorScheme.error;
    return switch (task.downloadStatus) {
      DownloadStatusCompleted() => _mark(
        Icon(Symbols.download_done, size: _iconSize, color: colors.inkTertiary),
        null,
        colors.inkTertiary,
        semantics: l10n.queueDownloadedLabel,
      ),
      DownloadStatusDownloading() => _mark(
        SizedBox.square(
          dimension: _iconSize - 2,
          child: CircularProgressIndicator(
            value: task.progress,
            strokeWidth: 2,
            color: colors.accent,
            backgroundColor: colors.progressTrack,
          ),
        ),
        _percent(task.progress) ?? l10n.downloadStatusDownloading,
        colors.accent,
        semantics: l10n.downloadStatusDownloading,
      ),
      DownloadStatusPending() => _mark(
        Icon(Symbols.schedule, size: _iconSize, color: colors.inkTertiary),
        l10n.downloadStatusPending,
        colors.inkTertiary,
      ),
      DownloadStatusPaused() => _mark(
        Icon(Symbols.pause_circle, size: _iconSize, color: colors.inkTertiary),
        l10n.downloadStatusPaused,
        colors.inkTertiary,
      ),
      DownloadStatusFailed() => _mark(
        Icon(Symbols.error, size: _iconSize, color: error),
        l10n.downloadStatusFailed,
        error,
      ),
      DownloadStatusCancelled() => const SizedBox.shrink(),
    };
  }

  static String? _percent(double? progress) =>
      progress == null ? null : '${(progress * 100).round()}%';

  Widget _mark(Widget icon, String? label, Color color, {String? semantics}) {
    return Semantics(
      label: semantics ?? label,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: Spacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            if (label != null) ...[
              const SizedBox(width: Spacing.xxs),
              Text(label, style: AppTextStyles.caption.copyWith(color: color)),
            ],
          ],
        ),
      ),
    );
  }
}
