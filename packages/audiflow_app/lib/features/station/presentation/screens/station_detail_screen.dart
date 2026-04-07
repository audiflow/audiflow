import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../../../podcast_detail/presentation/controllers/podcast_detail_controller.dart';
import '../../../podcast_detail/presentation/widgets/smart_playlist_episode_list_tile.dart';
import '../../../download/presentation/helpers/batch_download_action_helper.dart';
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
    final allTasksAsync = ref.watch(allDownloadsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.station.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                context.push(
                  '${AppRoutes.library}/station/${widget.station.id}/edit',
                );
                return;
              }

              final ids = episodesAsync.value
                  ?.map((se) => se.episodeId)
                  .toList();
              if (ids == null || ids.isEmpty) return;

              final dlState = computeBatchDownloadState(
                episodeIds: ids,
                allTasks: allTasksAsync.value ?? [],
              );

              switch (value) {
                case 'download_all':
                  if (dlState.hasDownloadable) {
                    handleBatchDownload(
                      context: context,
                      ref: ref,
                      episodeIds: ids,
                    );
                  }
                case 'cancel_all':
                  handleBatchCancel(
                    context: context,
                    ref: ref,
                    episodeIds: ids,
                  );
                case 'resume_all':
                  handleBatchResume(
                    context: context,
                    ref: ref,
                    episodeIds: ids,
                  );
              }
            },
            itemBuilder: (context) {
              final l10n = AppLocalizations.of(context);
              final ids =
                  episodesAsync.value?.map((se) => se.episodeId).toList() ?? [];
              final dlState = computeBatchDownloadState(
                episodeIds: ids,
                allTasks: allTasksAsync.value ?? [],
              );
              return [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: const Icon(Symbols.edit),
                    title: Text(l10n.stationEditTooltip),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  enabled: dlState.hasDownloadable,
                  value: 'download_all',
                  child: ListTile(
                    leading: const Icon(Icons.download),
                    title: Text(l10n.downloadAllEpisodes),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                if (dlState.hasActive)
                  PopupMenuItem(
                    value: 'cancel_all',
                    child: ListTile(
                      leading: const Icon(Icons.cancel_outlined),
                      title: Text(l10n.downloadCancelAll),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                if (dlState.hasPaused)
                  PopupMenuItem(
                    value: 'resume_all',
                    child: ListTile(
                      leading: const Icon(Icons.play_arrow),
                      title: Text(l10n.downloadResumeAll),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
              ];
            },
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

/// Loads episode and subscription data, then delegates to the shared
/// [SmartPlaylistEpisodeListTile] which provides full action buttons
/// (queue, download, share, context menu).
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

        final subscriptionAsync = ref.watch(
          subscriptionByIdProvider(episode.podcastId),
        );
        final subscription = subscriptionAsync.value;

        final progress = ref
            .watch(episodeProgressProvider(episode.audioUrl))
            .value;

        return SmartPlaylistEpisodeListTile(
          episode: episode,
          podcastTitle: subscription?.title ?? stationName,
          artworkUrl: subscription?.artworkUrl,
          fallbackThumbnailUrl: subscription?.artworkUrl,
          progress: progress,
          siblingEpisodeIds: siblingEpisodeIds,
          forceDisplayOrder: true,
          lastRefreshedAt: subscription?.lastRefreshedAt,
          itunesId: subscription?.itunesId,
          feedUrl: subscription?.feedUrl,
        );
      },
      loading: () => const SizedBox(height: episodeCardExtent),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
