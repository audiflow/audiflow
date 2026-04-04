import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../../../download/presentation/helpers/download_action_helper.dart';
import '../../../player/helpers/podcast_lookup.dart';
import '../../../queue/presentation/controllers/queue_controller.dart';
import '../../../share/presentation/helpers/share_helper.dart';
import '../controllers/podcast_detail_controller.dart';

/// Displays full episode details with playback, download,
/// and queue actions.
class EpisodeDetailScreen extends ConsumerStatefulWidget {
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
  ConsumerState<EpisodeDetailScreen> createState() =>
      _EpisodeDetailScreenState();
}

class _EpisodeDetailScreenState extends ConsumerState<EpisodeDetailScreen> {
  Brightness _artworkBrightness = Brightness.dark;
  double _collapseRatio = 0.0;

  @override
  void initState() {
    super.initState();
    // Defer until after page transition completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveArtworkBrightness().ignore();
    });
  }

  Future<void> _resolveArtworkBrightness() async {
    final imageUrl = widget.episode.primaryImage?.url ?? widget.artworkUrl;
    if (imageUrl == null) return;

    final brightness = await ArtworkBrightnessResolver.resolve(
      ExtendedNetworkImageProvider(imageUrl, cache: true),
    );
    if (mounted) {
      setState(() => _artworkBrightness = brightness);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final enclosureUrl = widget.episode.enclosureUrl;

    final isPlaying = enclosureUrl != null
        ? ref.watch(isEpisodePlayingProvider(enclosureUrl))
        : false;
    final isLoading = enclosureUrl != null
        ? ref.watch(isEpisodeLoadingProvider(enclosureUrl))
        : false;

    // Watch reactive progress when enclosureUrl is available;
    // fall back to the constructor-provided snapshot otherwise.
    final reactiveProgress = enclosureUrl != null
        ? ref.watch(episodeProgressProvider(enclosureUrl)).value
        : null;
    final effectiveProgress = reactiveProgress ?? widget.progress;

    // Derive episodeId from effectiveProgress so that DB-backed actions
    // (download, queue) remain available even when the screen is opened
    // without an initial progress snapshot (e.g. from NowPlayingCard).
    final episodeId = effectiveProgress?.episode.id;
    final downloadTask = episodeId != null
        ? ref.watch(episodeDownloadProvider(episodeId)).value
        : null;
    // Check if this episode is currently loaded in the player (any state).
    final playbackState = ref.watch(audioPlayerControllerProvider);
    final isLoadedInPlayer =
        enclosureUrl != null &&
        playbackState.maybeWhen(
          playing: (url) => url == enclosureUrl,
          paused: (url) => url == enclosureUrl,
          loading: (url) => url == enclosureUrl,
          orElse: () => false,
        );

    final isCompleted = effectiveProgress?.isCompleted ?? false;
    final isInProgress =
        isLoadedInPlayer || (effectiveProgress?.isInProgress ?? false);

    final imageUrl = widget.episode.primaryImage?.url ?? widget.artworkUrl;
    final heroTag =
        'episode_artwork_${widget.episode.guid ?? widget.episode.title}';

    final expandedOverlayStyle = _artworkBrightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    // When collapsed, use the theme-appropriate style (dark icons on
    // light surface, light icons on dark surface).
    final themeBrightness = Theme.of(context).brightness;
    final collapsedOverlayStyle = themeBrightness == Brightness.light
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;

    final expandedHeight = imageUrl != null ? 250.0 : 0.0;

    // When there is no artwork the app bar never expands, so buttons
    // should render in collapsed (theme) style from the start.
    final effectiveCollapseRatio = imageUrl != null ? _collapseRatio : 1.0;

    // Switch overlay style at the halfway point of collapse.
    final overlayStyle = 0.5 < effectiveCollapseRatio
        ? collapsedOverlayStyle
        : expandedOverlayStyle;

    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (0.0 < expandedHeight) {
            final topPadding = MediaQuery.of(context).padding.top;
            final collapseRange = expandedHeight - kToolbarHeight - topPadding;
            final collapsed = 0.0 < collapseRange
                ? notification.metrics.pixels / collapseRange
                : 0.0;
            final clamped = collapsed.clamp(0.0, 1.0);
            if ((clamped - _collapseRatio).abs() > 0.01) {
              setState(() => _collapseRatio = clamped);
            }
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: expandedHeight,
              pinned: true,
              automaticallyImplyLeading: false,
              systemOverlayStyle: imageUrl != null ? overlayStyle : null,
              leading: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: Spacing.md),
                  child: OverlayActionButton(
                    icon: Icons.arrow_back,
                    collapseRatio: effectiveCollapseRatio,
                    artworkBrightness: _artworkBrightness,
                    onTap: () => Navigator.of(context).pop(),
                    semanticLabel: MaterialLocalizations.of(
                      context,
                    ).backButtonTooltip,
                  ),
                ),
              ),
              leadingWidth: 48 + Spacing.md + Spacing.sm,
              flexibleSpace: imageUrl != null
                  ? FlexibleSpaceBar(
                      background: Semantics(
                        label: 'View episode artwork',
                        button: true,
                        child: Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            onTap: () =>
                                _showArtworkOverlay(context, imageUrl, heroTag),
                            child: Hero(
                              tag: heroTag,
                              child: ExtendedImage.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                cache: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : null,
              actions: [
                OverlayActionButton(
                  icon: Icons.more_vert,
                  collapseRatio: effectiveCollapseRatio,
                  artworkBrightness: _artworkBrightness,
                  semanticLabel: l10n.episodeMoreActions,
                  onTap: () => _showContextMenu(
                    context,
                    enclosureUrl: enclosureUrl,
                    episodeId: episodeId,
                    isCompleted: isCompleted,
                    downloadTask: downloadTask,
                  ),
                ),
                const SizedBox(width: Spacing.md),
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
                      widget.episode.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),

                    // Podcast title (tappable -> navigates to podcast page)
                    InkWell(
                      onTap: () => _navigateToPodcast(context),
                      borderRadius: BorderRadius.circular(4),
                      child: Text(
                        widget.podcastTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),

                    // Metadata row
                    _MetadataRow(episode: widget.episode),
                    const SizedBox(height: Spacing.md),

                    // Progress indicator -- only render the wrapper Padding
                    // when the indicator will actually display content to
                    // avoid a blank gap while progress data loads.
                    if (isCompleted ||
                        (isInProgress &&
                            effectiveProgress?.remainingTimeFormatted != null))
                      Padding(
                        padding: const EdgeInsets.only(bottom: Spacing.md),
                        child: EpisodeProgressIndicator(
                          isCompleted: isCompleted,
                          isInProgress: isInProgress,
                          remainingTimeFormatted:
                              effectiveProgress?.remainingTimeFormatted,
                        ),
                      ),

                    // Action bar
                    _ActionBar(
                      enclosureUrl: enclosureUrl,
                      isPlaying: isPlaying,
                      isLoading: isLoading,
                      episodeId: episodeId,
                      downloadTask: downloadTask,
                      onPlayPause: enclosureUrl != null
                          ? () => _onPlayPausePressed(
                              context,
                              enclosureUrl,
                              isPlaying,
                            )
                          : null,
                      onDownloadTap: episodeId != null
                          ? () => handleDownloadTap(
                              context: context,
                              ref: ref,
                              episodeId: episodeId,
                              task: downloadTask,
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
                    ),

                    const Divider(height: Spacing.xl),

                    // Description / show notes
                    _DescriptionSection(episode: widget.episode),

                    const Divider(height: Spacing.xl),

                    // Episode info + statistics
                    _EpisodeStatsSection(
                      episode: widget.episode,
                      podcastTitle: widget.podcastTitle,
                      progress: effectiveProgress,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showArtworkOverlay(
    BuildContext context,
    String imageUrl,
    String heroTag,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black87,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) {
          return ArtworkOverlay(imageUrl: imageUrl, heroTag: heroTag);
        },
      ),
    );
  }

  void _showContextMenu(
    BuildContext context, {
    required String? enclosureUrl,
    required int? episodeId,
    required bool isCompleted,
    required DownloadTask? downloadTask,
  }) {
    final l10n = AppLocalizations.of(context);
    final canShare =
        (widget.itunesId != null && widget.episode.guid != null) ||
        widget.episode.link != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.45,
        minChildSize: 0.3,
        maxChildSize: 0.7,
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
                  widget.episode.title,
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
                    if (episodeId != null) ...[
                      ListTile(
                        leading: const Icon(Icons.playlist_play),
                        title: Text(l10n.playNext),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          ref
                              .read(queueControllerProvider.notifier)
                              .playNext(episodeId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.queuePlayingNext),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.playlist_add),
                        title: Text(l10n.addToQueue),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          ref
                              .read(queueControllerProvider.notifier)
                              .playLater(episodeId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.queueAddedToQueue),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                    if (enclosureUrl != null)
                      ListTile(
                        leading: Icon(
                          isCompleted
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                        ),
                        title: Text(
                          isCompleted ? l10n.markAsUnplayed : l10n.markAsPlayed,
                        ),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _togglePlayedStatus(enclosureUrl, isCompleted);
                        },
                      ),
                    if (episodeId != null)
                      _buildDownloadMenuTile(
                        context,
                        sheetContext,
                        episodeId,
                        downloadTask,
                        l10n,
                      ),
                    if (canShare)
                      ListTile(
                        leading: const Icon(Icons.share),
                        title: Text(l10n.shareEpisode),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          shareEpisode(
                            context: context,
                            ref: ref,
                            itunesId: widget.itunesId,
                            episodeGuid: widget.episode.guid,
                            fallbackLink: widget.episode.link,
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

  Widget _buildDownloadMenuTile(
    BuildContext outerContext,
    BuildContext sheetContext,
    int episodeId,
    DownloadTask? task,
    AppLocalizations l10n,
  ) {
    if (task case final DownloadTask nonNullTask
        when nonNullTask.downloadStatus is DownloadStatusCompleted) {
      return ListTile(
        leading: const Icon(Icons.delete_outline),
        title: Text(l10n.removeDownload),
        onTap: () {
          Navigator.pop(sheetContext);
          showDownloadDeleteConfirmation(
            context: outerContext,
            ref: ref,
            task: nonNullTask,
          );
        },
      );
    }

    return ListTile(
      leading: const Icon(Icons.download),
      title: Text(l10n.downloadEpisode),
      onTap: () {
        Navigator.pop(sheetContext);
        handleDownloadTap(
          context: outerContext,
          ref: ref,
          episodeId: episodeId,
          task: task,
        );
      },
    );
  }

  Future<void> _navigateToPodcast(BuildContext context) async {
    final podcastId = widget.progress?.episode.podcastId;
    if (podcastId == null) {
      // Episode not yet in DB -- look up by audio URL
      final enclosureUrl = widget.episode.enclosureUrl;
      if (enclosureUrl != null) {
        final episodeRepo = ref.read(episodeRepositoryProvider);
        final dbEpisode = await episodeRepo.getByAudioUrl(enclosureUrl);
        if (dbEpisode != null && context.mounted) {
          return _pushPodcastDetail(context, podcastId: dbEpisode.podcastId);
        }
      }

      // Fallback: navigate via deep link when itunesId is available
      if (widget.itunesId != null && context.mounted) {
        final path = AppRoutes.deepLinkPodcast.replaceFirst(
          ':itunesId',
          Uri.encodeComponent(widget.itunesId!),
        );
        context.push(path);
      }
      return;
    }
    return _pushPodcastDetail(context, podcastId: podcastId);
  }

  Future<void> _pushPodcastDetail(
    BuildContext context, {
    required int podcastId,
  }) async {
    final podcast = await lookupPodcastForEpisode(
      subscriptionRepo: ref.read(subscriptionRepositoryProvider),
      podcastId: podcastId,
      podcastTitle: widget.podcastTitle,
    );
    if (podcast == null || !context.mounted) return;

    context.push('${AppRoutes.library}/podcast/${podcast.id}', extra: podcast);
  }

  Future<void> _onPlayPausePressed(
    BuildContext context,
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

    final episodeId = widget.progress?.episode.id;
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
        sourceContext: widget.podcastTitle,
      );
    }

    controller.play(
      url,
      metadata: NowPlayingInfo(
        episodeUrl: url,
        episodeTitle: widget.episode.title,
        podcastTitle: widget.podcastTitle,
        artworkUrl: widget.artworkUrl ?? widget.episode.primaryImage?.url,
        totalDuration: widget.episode.duration,
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

  Future<void> _togglePlayedStatus(
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

/// Action bar with play, download, and queue buttons.
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.enclosureUrl,
    required this.isPlaying,
    required this.isLoading,
    required this.episodeId,
    required this.downloadTask,
    required this.onPlayPause,
    required this.onDownloadTap,
    required this.onQueuePlayLater,
  });

  final String? enclosureUrl;
  final bool isPlaying;
  final bool isLoading;
  final int? episodeId;
  final DownloadTask? downloadTask;
  final VoidCallback? onPlayPause;
  final VoidCallback? onDownloadTap;
  final VoidCallback? onQueuePlayLater;

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

/// Displays episode info and playback statistics in a two-column table.
class _EpisodeStatsSection extends StatelessWidget {
  const _EpisodeStatsSection({
    required this.episode,
    required this.podcastTitle,
    required this.progress,
  });

  final PodcastItem episode;
  final String podcastTitle;
  final EpisodeWithProgress? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final history = progress?.history;
    final dateFormat = DateFormat.yMMMd();

    final rows = <_StatsRow>[
      _StatsRow(label: l10n.statsTitle, value: episode.title),
      _StatsRow(label: l10n.statsPodcast, value: podcastTitle),
      if (episode.formattedDuration != null)
        _StatsRow(label: l10n.statsDuration, value: episode.formattedDuration!),
      if (episode.publishDate != null)
        _StatsRow(
          label: l10n.statsPublished,
          value: dateFormat.format(episode.publishDate!),
        ),
      _StatsRow(
        label: l10n.statsTimesCompleted,
        value: '${history?.completedCount ?? 0}',
      ),
      _StatsRow(
        label: l10n.statsTimesStarted,
        value: '${history?.playCount ?? 0}',
      ),
      _StatsRow(
        label: l10n.statsTotalListened,
        value: _formatMs(history?.totalListenedMs ?? 0),
      ),
      _StatsRow(
        label: l10n.statsRealtime,
        value: _formatMs(history?.totalRealtimeMs ?? 0),
      ),
      _StatsRow(
        label: l10n.statsFirstPlayed,
        value: history?.firstPlayedAt != null
            ? dateFormat.format(history!.firstPlayedAt!)
            : l10n.statsNever,
      ),
      _StatsRow(
        label: l10n.statsLastPlayed,
        value: history?.lastPlayedAt != null
            ? dateFormat.format(history!.lastPlayedAt!)
            : l10n.statsNever,
      ),
    ];

    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final valueStyle = theme.textTheme.bodySmall;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.statsSection,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Table(
          columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
          defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: rows
              .map(
                (row) => TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        right: Spacing.md,
                        bottom: Spacing.xs,
                      ),
                      child: Text(row.label, style: labelStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.xs),
                      child: Text(row.value, style: valueStyle),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  String _formatMs(int ms) {
    if (ms == 0) return '00:00';
    final duration = Duration(milliseconds: ms);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (0 < hours) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _StatsRow {
  const _StatsRow({required this.label, required this.value});

  final String label;
  final String value;
}
