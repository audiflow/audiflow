import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../../../podcast_detail/presentation/controllers/podcast_detail_controller.dart';
import '../../../podcast_detail/presentation/screens/episode_detail_screen.dart';
import '../../../queue/presentation/controllers/queue_controller.dart';
import '../controllers/station_detail_controller.dart';

/// Shows filtered episodes for a single [Station].
class StationDetailScreen extends ConsumerWidget {
  const StationDetailScreen({required this.stationId, super.key});

  final int stationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationAsync = ref.watch(stationByIdProvider(stationId));

    return stationAsync.when(
      data: (station) {
        if (station == null) {
          return _buildNotFound(context);
        }
        return _StationDetailContent(station: station);
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).stationSectionTitle),
        ),
        body: Center(child: Text(error.toString())),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.stationNotFoundTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: Spacing.md),
            Text(l10n.stationNotFoundMessage),
            const SizedBox(height: Spacing.sm),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(l10n.commonGoBack),
            ),
          ],
        ),
      ),
    );
  }
}

class _StationDetailContent extends ConsumerStatefulWidget {
  const _StationDetailContent({required this.station});

  final Station station;

  @override
  ConsumerState<_StationDetailContent> createState() =>
      _StationDetailContentState();
}

class _StationDetailContentState extends ConsumerState<_StationDetailContent> {
  Future<void>? _activeSyncFuture;
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(onResume: _syncStationFeeds);
    _reconcileAndSync();
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  /// On first open: reconcile existing DB episodes into the station,
  /// then sync feeds for new ones.  Reconciliation catches episodes
  /// that were synced by other paths (launch, background) but never
  /// linked to this station due to early termination.
  Future<void> _reconcileAndSync() {
    return _runSync(() async {
      final reconcilerService = ref.read(stationReconcilerServiceProvider);
      await reconcilerService.onStationConfigChanged(widget.station.id);
      final syncService = ref.read(feedSyncServiceProvider);
      await syncService.syncStationFeeds(widget.station.id);
    });
  }

  /// Pull-to-refresh and app resume: sync feeds only.
  /// New episodes are reconciled per-episode via onBatchReady.
  Future<void> _syncStationFeeds() {
    return _runSync(() async {
      final syncService = ref.read(feedSyncServiceProvider);
      await syncService.syncStationFeeds(widget.station.id);
    });
  }

  /// Runs [action] as the active sync, reusing the in-flight Future
  /// if one is already running so RefreshIndicator reflects the real
  /// sync lifecycle.
  Future<void> _runSync(Future<void> Function() action) {
    if (_activeSyncFuture != null) return _activeSyncFuture!;
    _activeSyncFuture = action().whenComplete(() {
      _activeSyncFuture = null;
    });
    return _activeSyncFuture!;
  }

  @override
  Widget build(BuildContext context) {
    final episodesAsync = ref.watch(stationEpisodesProvider(widget.station.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.station.name),
        actions: [
          IconButton(
            icon: const Icon(Symbols.edit),
            tooltip: AppLocalizations.of(context).stationEditTooltip,
            onPressed: () => context.push(
              '${AppRoutes.library}/station/${widget.station.id}/edit',
            ),
          ),
        ],
      ),
      body: episodesAsync.when(
        data: (episodes) => _buildEpisodeList(context, episodes),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }

  Widget _buildEpisodeList(
    BuildContext context,
    List<StationEpisode> stationEpisodes,
  ) {
    if (stationEpisodes.isEmpty) {
      return _buildEmptyState(context);
    }

    final siblingEpisodeIds = stationEpisodes
        .map((se) => se.episodeId)
        .toList();

    return RefreshIndicator(
      onRefresh: _syncStationFeeds,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: stationEpisodes.length,
        itemExtent: episodeCardExtent,
        itemBuilder: (context, index) {
          return _StationEpisodeTile(
            key: ValueKey(stationEpisodes[index].id),
            stationEpisode: stationEpisodes[index],
            stationName: widget.station.name,
            siblingEpisodeIds: siblingEpisodeIds,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.radio,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              AppLocalizations.of(context).stationEmpty,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              AppLocalizations.of(context).stationEmptySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Loads and renders a single episode from a [StationEpisode] row with
/// playback controls and podcast artwork.
class _StationEpisodeTile extends ConsumerWidget {
  const _StationEpisodeTile({
    required this.stationEpisode,
    required this.stationName,
    required this.siblingEpisodeIds,
    super.key,
  });

  final StationEpisode stationEpisode;
  final String stationName;
  final List<int> siblingEpisodeIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodeAsync = ref.watch(
      episodeByIdProvider(stationEpisode.episodeId),
    );

    return episodeAsync.when(
      data: (episode) {
        if (episode == null) return const SizedBox.shrink();
        return _StationEpisodeCard(
          episode: episode,
          stationName: stationName,
          siblingEpisodeIds: siblingEpisodeIds,
        );
      },
      loading: () => const SizedBox(height: episodeCardExtent),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

/// Renders an [EpisodeCard] with playback state and podcast metadata.
class _StationEpisodeCard extends ConsumerWidget {
  const _StationEpisodeCard({
    required this.episode,
    required this.stationName,
    required this.siblingEpisodeIds,
  });

  final Episode episode;
  final String stationName;
  final List<int> siblingEpisodeIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioUrl = episode.audioUrl;
    final l10n = AppLocalizations.of(context);

    final currentPlayingUrl = ref.watch(currentPlayingEpisodeUrlProvider);
    final isCurrentEpisode = currentPlayingUrl == audioUrl;
    final isPlaying = ref.watch(isEpisodePlayingProvider(audioUrl));
    final isLoading = ref.watch(isEpisodeLoadingProvider(audioUrl));

    final subscriptionAsync = ref.watch(
      subscriptionByIdProvider(episode.podcastId),
    );
    final subscription = subscriptionAsync.value;
    final podcastTitle = subscription?.title ?? stationName;
    final artworkUrl = subscription?.artworkUrl;

    return EpisodeCard(
      title: episode.title,
      subtitle: _buildSubtitleText(l10n),
      description: episode.description,
      thumbnailUrl: episode.imageUrl ?? artworkUrl,
      isPlaying: isPlaying,
      isLoading: isLoading,
      isCurrentEpisode: isCurrentEpisode,
      onTap: () => _navigateToDetail(
        context,
        podcastTitle,
        artworkUrl,
        feedUrl: subscription?.feedUrl,
      ),
      onPlayPause: () => _onPlayPausePressed(
        context,
        ref,
        audioUrl,
        isPlaying,
        podcastTitle,
        artworkUrl,
      ),
      actionButtons: [
        AddToQueueButton(
          onPlayLater: () {
            ref.read(queueControllerProvider.notifier).playLater(episode.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.queueAddedToQueue),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          onPlayNext: () {
            ref.read(queueControllerProvider.notifier).playNext(episode.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.queuePlayingNext),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
      ],
    );
  }

  String _buildSubtitleText(AppLocalizations l10n) {
    final parts = <String>[];

    if (episode.durationMs != null) {
      parts.add(_formatDuration(episode.durationMs!));
    }

    if (episode.publishedAt != null) {
      parts.add(
        episode.publishedAt!.formatEpisodeDate(
          todayLabel: l10n.dateToday,
          yesterdayLabel: l10n.dateYesterday,
        ),
      );
    }

    return parts.join('  ');
  }

  String _formatDuration(int durationMs) {
    final duration = Duration(milliseconds: durationMs);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (0 < hours) return '${hours}h ${minutes}min';
    return '$minutes min';
  }

  void _navigateToDetail(
    BuildContext context,
    String podcastTitle,
    String? artworkUrl, {
    String? feedUrl,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EpisodeDetailScreen(
          episode: episode.toPodcastItem(feedUrl: feedUrl ?? ''),
          podcastTitle: podcastTitle,
          artworkUrl: artworkUrl,
        ),
      ),
    );
  }

  Future<void> _onPlayPausePressed(
    BuildContext context,
    WidgetRef ref,
    String url,
    bool isPlaying,
    String podcastTitle,
    String? artworkUrl,
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

    final queueService = ref.read(queueServiceProvider);

    final shouldConfirm = await queueService.shouldConfirmAdhocReplace();
    if (shouldConfirm) {
      if (!context.mounted) return;
      final confirmed = await _showReplaceQueueDialog(context);
      if (!confirmed) return;
    }

    await queueService.createAdhocQueue(
      startingEpisodeId: episode.id,
      sourceContext: stationName,
      siblingEpisodeIds: siblingEpisodeIds,
      forceDisplayOrder: true,
    );

    controller.play(
      url,
      metadata: NowPlayingInfo(
        episodeUrl: url,
        episodeTitle: episode.title,
        podcastTitle: podcastTitle,
        artworkUrl: episode.imageUrl ?? artworkUrl,
        totalDuration: episode.durationMs != null
            ? Duration(milliseconds: episode.durationMs!)
            : null,
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
}
