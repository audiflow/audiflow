import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../queue/presentation/controllers/queue_controller.dart';
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
  });

  final PodcastItem episode;
  final String podcastTitle;
  final String? artworkUrl;
  final EpisodeWithProgress? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
              if (episode.link != null)
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => SharePlus.instance.share(
                    ShareParams(uri: Uri.parse(episode.link!)),
                  ),
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
                              const SnackBar(
                                content: Text('Added to queue'),
                                duration: Duration(seconds: 1),
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
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replace queue?'),
        content: const Text(
          'Starting playback will replace your current '
          'queue with episodes from this list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Replace'),
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

    if (task == null) {
      await downloadService.downloadEpisode(episodeId);
      return;
    }

    task.downloadStatus.when(
      pending: () async {
        await downloadService.cancel(task.id);
        messenger.showSnackBar(
          const SnackBar(content: Text('Download cancelled')),
        );
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
        messenger.showSnackBar(
          const SnackBar(content: Text('Retrying download')),
        );
      },
      cancelled: () async {
        final result = await downloadService.downloadEpisode(episodeId);
        if (result != null) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Download started')),
          );
        }
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    DownloadTask task,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete download?'),
        content: const Text('The downloaded file will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(downloadServiceProvider).delete(task.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download deleted')),
                );
              }
            },
            child: const Text('Delete'),
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
            tooltip: 'Add to queue',
          ),

        // Mark played/unplayed
        if (onTogglePlayed != null)
          IconButton(
            icon: Icon(isCompleted ? Icons.replay : Icons.check_circle_outline),
            onPressed: onTogglePlayed,
            tooltip: isCompleted ? 'Mark as unplayed' : 'Mark as played',
          ),
      ],
    );
  }
}

/// Shows episode description or content as HTML.
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

    return Html(data: content);
  }
}
