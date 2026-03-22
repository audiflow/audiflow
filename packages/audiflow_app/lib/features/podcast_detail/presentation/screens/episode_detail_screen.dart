import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../queue/presentation/controllers/queue_controller.dart';
import '../../../share/presentation/helpers/share_helper.dart';
import '../controllers/podcast_detail_controller.dart';

/// Displays full episode details with playback, download,
/// and queue actions.
class EpisodeDetailScreen extends ConsumerWidget {
  const EpisodeDetailScreen({
    super.key,
    required this.episode,
    required this.podcastTitle,
    this.artworkUrl,
    this.progress,
    this.itunesId,
  });

  final PodcastItem episode;
  final String podcastTitle;
  final String? artworkUrl;
  final EpisodeWithProgress? progress;

  /// iTunes ID for building universal share links.
  final String? itunesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final enclosureUrl = episode.enclosureUrl;

    final isPlaying = enclosureUrl != null
        ? ref.watch(isEpisodePlayingProvider(enclosureUrl))
        : false;
    final isLoading = enclosureUrl != null
        ? ref.watch(isEpisodeLoadingProvider(enclosureUrl))
        : false;

    final episodeId = progress?.episode.id;
    final downloadTask = episodeId != null
        ? ref.watch(episodeDownloadProvider(episodeId)).value
        : null;

    final isCompleted = progress?.isCompleted ?? false;

    final imageUrl = episode.primaryImage?.url ?? artworkUrl;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: imageUrl != null ? 250 : 0,
            pinned: true,
            flexibleSpace: imageUrl != null
                ? FlexibleSpaceBar(
                    background: ExtendedImage.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      cache: true,
                    ),
                  )
                : null,
            actions: [
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  final canShare =
                      (itunesId != null && episode.guid != null) ||
                      episode.link != null;
                  return IconButton(
                    icon: const Icon(Icons.share),
                    tooltip: l10n.shareEpisode,
                    onPressed: canShare
                        ? () => shareEpisode(
                            ref: ref,
                            itunesId: itunesId,
                            episodeGuid: episode.guid,
                            fallbackLink: episode.link,
                          )
                        : null,
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    episode.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),

                  // Podcast title
                  Text(
                    podcastTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),

                  // Metadata row
                  _MetadataRow(episode: episode),
                  const SizedBox(height: Spacing.md),

                  // Progress indicator
                  if (progress != null &&
                      (progress!.isCompleted || progress!.isInProgress))
                    Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.md),
                      child: EpisodeProgressIndicator(
                        isCompleted: progress!.isCompleted,
                        isInProgress: progress!.isInProgress,
                        remainingTimeFormatted:
                            progress!.remainingTimeFormatted,
                      ),
                    ),

                  // Action bar
                  _ActionBar(
                    enclosureUrl: enclosureUrl,
                    isPlaying: isPlaying,
                    isLoading: isLoading,
                    isCompleted: isCompleted,
                    episodeId: episodeId,
                    downloadTask: downloadTask,
                    onPlayPause: enclosureUrl != null
                        ? () => _onPlayPausePressed(
                            context,
                            ref,
                            enclosureUrl,
                            isPlaying,
                          )
                        : null,
                    onDownloadTap: episodeId != null
                        ? () => _onDownloadTap(
                            context,
                            ref,
                            episodeId,
                            downloadTask,
                          )
                        : null,
                    onQueuePlayLater: episodeId != null
                        ? () {
                            ref
                                .read(queueControllerProvider.notifier)
                                .playLater(episodeId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.queueAddedToQueue),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        : null,
                    onTogglePlayed: enclosureUrl != null
                        ? () => _togglePlayedStatus(
                            ref,
                            enclosureUrl,
                            isCompleted,
                          )
                        : null,
                  ),

                  const Divider(height: Spacing.xl),

                  // Description / show notes
                  _DescriptionSection(episode: episode),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onPlayPausePressed(
    BuildContext context,
    WidgetRef ref,
    String url,
    bool isPlaying,
  ) async {
    final controller = ref.read(audioPlayerControllerProvider.notifier);

    if (isPlaying) {
      controller.pause();
      return;
    }

    if (controller.isLoaded(url)) {
      controller.resume();
      return;
    }

    final episodeId = progress?.episode.id;
    if (episodeId != null) {
      final queueService = ref.read(queueServiceProvider);
      final shouldConfirm = await queueService.shouldConfirmAdhocReplace();

      if (shouldConfirm) {
        if (!context.mounted) return;
        final confirmed = await _showReplaceQueueDialog(context);
        if (!confirmed) return;
      }

      await queueService.createAdhocQueue(
        startingEpisodeId: episodeId,
        sourceContext: podcastTitle,
      );
    }

    controller.play(
      url,
      metadata: NowPlayingInfo(
        episodeUrl: url,
        episodeTitle: episode.title,
        podcastTitle: podcastTitle,
        artworkUrl: artworkUrl ?? episode.primaryImage?.url,
        totalDuration: episode.duration,
      ),
    );
  }

  Future<bool> _showReplaceQueueDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.episodeReplaceQueueTitle),
        content: Text(l10n.episodeReplaceQueueContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.episodeReplace),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _onDownloadTap(
    BuildContext context,
    WidgetRef ref,
    int episodeId,
    DownloadTask? task,
  ) async {
    final downloadService = ref.read(downloadServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);

    if (task == null) {
      await downloadService.downloadEpisode(episodeId);
      return;
    }

    task.downloadStatus.when(
      pending: () async {
        await downloadService.cancel(task.id);
        messenger.showSnackBar(SnackBar(content: Text(l10n.downloadCancelled)));
      },
      downloading: () async {
        await downloadService.pause(task.id);
      },
      paused: () async {
        await downloadService.resume(task.id);
      },
      completed: () {
        _showDeleteConfirmation(context, ref, task);
      },
      failed: () async {
        await downloadService.retry(task.id);
        messenger.showSnackBar(SnackBar(content: Text(l10n.downloadRetrying)));
      },
      cancelled: () async {
        final result = await downloadService.downloadEpisode(episodeId);
        if (result != null) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.downloadStarted)));
        }
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    DownloadTask task,
  ) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.downloadDeleteTitle),
        content: Text(l10n.downloadDeleteContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(downloadServiceProvider).delete(task.id);
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.downloadDeleted)));
              }
            },
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
  }

  Future<void> _togglePlayedStatus(
    WidgetRef ref,
    String audioUrl,
    bool isCurrentlyCompleted,
  ) async {
    final episodeRepo = ref.read(episodeRepositoryProvider);
    final ep = await episodeRepo.getByAudioUrl(audioUrl);
    if (ep == null) return;

    final historyService = ref.read(playbackHistoryServiceProvider);
    if (isCurrentlyCompleted) {
      await historyService.markIncomplete(ep.id);
    } else {
      await historyService.markCompleted(ep.id);
    }

    ref.invalidate(episodeProgressProvider(audioUrl));
  }
}

/// Displays episode metadata in a compact row.
class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.episode});

  final PodcastItem episode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parts = <String>[];

    if (episode.formattedDuration != null) {
      parts.add(episode.formattedDuration!);
    }
    if (episode.publishDate != null) {
      parts.add(DateFormat.yMMMd().format(episode.publishDate!));
    }
    if (episode.episodeNumber != null) {
      final seasonPart = episode.seasonNumber != null
          ? 'S${episode.seasonNumber}:'
          : '';
      parts.add('${seasonPart}E${episode.episodeNumber}');
    }
    if (episode.formattedFileSize != null) {
      parts.add(episode.formattedFileSize!);
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: Spacing.sm,
      children:
          parts
              .map(
                (part) => Text(
                  part,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
              .expand(
                (widget) => [
                  widget,
                  Text(
                    ' \u00B7 ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              )
              .toList()
            ..removeLast(),
    );
  }
}

/// Action bar with play, download, queue, and mark
/// played buttons.
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.enclosureUrl,
    required this.isPlaying,
    required this.isLoading,
    required this.isCompleted,
    required this.episodeId,
    required this.downloadTask,
    required this.onPlayPause,
    required this.onDownloadTap,
    required this.onQueuePlayLater,
    required this.onTogglePlayed,
  });

  final String? enclosureUrl;
  final bool isPlaying;
  final bool isLoading;
  final bool isCompleted;
  final int? episodeId;
  final DownloadTask? downloadTask;
  final VoidCallback? onPlayPause;
  final VoidCallback? onDownloadTap;
  final VoidCallback? onQueuePlayLater;
  final VoidCallback? onTogglePlayed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        // Play/Pause button (large, primary)
        if (isLoading)
          const SizedBox(
            width: 56,
            height: 56,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          IconButton.filled(
            iconSize: 32,
            style: IconButton.styleFrom(
              backgroundColor: enclosureUrl != null
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
              foregroundColor: enclosureUrl != null
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
              minimumSize: const Size(56, 56),
            ),
            icon: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            ),
            onPressed: onPlayPause,
          ),
        const SizedBox(width: Spacing.md),

        // Download
        if (episodeId != null)
          DownloadStatusIcon(
            task: downloadTask,
            size: 28,
            onTap: onDownloadTap,
          ),

        // Queue
        if (episodeId != null && onQueuePlayLater != null)
          IconButton(
            icon: const Icon(Icons.playlist_add),
            onPressed: onQueuePlayLater,
            tooltip: l10n.addToQueue,
          ),

        // Mark played/unplayed
        if (onTogglePlayed != null)
          IconButton(
            icon: Icon(isCompleted ? Icons.replay : Icons.check_circle_outline),
            onPressed: onTogglePlayed,
            tooltip: isCompleted ? l10n.markAsUnplayed : l10n.markAsPlayed,
          ),
      ],
    );
  }
}

/// Shows episode description or content as HTML with
/// clickable links that open in an in-app browser.
class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.episode});

  final PodcastItem episode;

  @override
  Widget build(BuildContext context) {
    final content =
        episode.contentEncoded ?? episode.summary ?? episode.description;

    if (content.isEmpty) {
      return const SizedBox.shrink();
    }

    return Html(
      data: content.plainTextToHtml.linkifyUrls,
      onLinkTap: (url, attributes, element) async {
        if (url == null || url.isEmpty) return;
        final uri = Uri.tryParse(url);
        if (uri == null) return;

        // Prefer in-app browser; fall back to external if unavailable
        // (e.g. iOS simulator doesn't support SFSafariViewController).
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.inAppBrowserView,
        );
        if (!launched) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
    );
  }
}
