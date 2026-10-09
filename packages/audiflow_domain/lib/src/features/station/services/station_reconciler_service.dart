import 'package:isar_community/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
import '../../feed/models/episode.dart';
import '../models/station_podcast.dart';
import 'station_reconciler.dart';

part 'station_reconciler_service.g.dart';

@Riverpod(keepAlive: true)
StationReconcilerService stationReconcilerService(Ref ref) {
  final isar = ref.watch(isarProvider);
  return StationReconcilerService(isar: isar);
}

/// Wraps [StationReconciler] with event-driven convenience methods and
/// orchestrates cleanup for multi-step operations like subscription deletion.
class StationReconcilerService {
  StationReconcilerService({required Isar isar})
    : _isar = isar,
      _reconciler = StationReconciler(isar: isar);

  final Isar _isar;
  final StationReconciler _reconciler;

  /// Called when an episode's state changes (playback, download, favorite).
  Future<void> onEpisodeChanged(int episodeId) async {
    await _reconciler.reconcileEpisode(episodeId);
  }

  /// Called after many episodes changed at once (e.g. a whole podcast
  /// marked played). Fully reconciles each station that holds one of their
  /// podcasts once, instead of a differential pass per episode, which for
  /// a large podcast would re-read the podcast's episodes every time.
  Future<void> onEpisodesChanged(Iterable<int> episodeIds) async {
    final episodes = await _isar.episodes.getAll(episodeIds.toList());
    final podcastIds = {
      for (final episode in episodes)
        if (episode != null) episode.podcastId,
    };
    if (podcastIds.isEmpty) return;
    final links = await _isar.stationPodcasts
        .filter()
        .anyOf(podcastIds, (q, podcastId) => q.podcastIdEqualTo(podcastId))
        .findAll();
    for (final stationId in {for (final link in links) link.stationId}) {
      await _reconciler.reconcileFull(stationId);
    }
  }

  /// Called when a station's config changes (filters, podcasts added/removed).
  Future<void> onStationConfigChanged(int stationId) async {
    await _reconciler.reconcileFull(stationId);
  }

  /// Called when a podcast stops being a subscription: unsubscribed (demoted
  /// to a cached entry) or deleted outright.
  ///
  /// Removes orphaned [StationPodcast] entries for the given podcast, then
  /// runs full reconciliation for each affected station so that orphaned
  /// [StationEpisode] rows are also cleaned up.
  Future<void> onSubscriptionRemoved(int podcastId) async {
    // Capture affected stations before deleting the link rows.
    final stationPodcasts = await _isar.stationPodcasts
        .filter()
        .podcastIdEqualTo(podcastId)
        .findAll();
    final affectedStationIds = stationPodcasts
        .map((sp) => sp.stationId)
        .toSet();

    // Remove the podcast-to-station links in a single transaction.
    await _isar.writeTxn(() async {
      final ids = stationPodcasts.map((sp) => sp.id).toList();
      await _isar.stationPodcasts.deleteAll(ids);
    });

    // Full reconciliation for each affected station cleans up StationEpisode.
    for (final stationId in affectedStationIds) {
      await _reconciler.reconcileFull(stationId);
    }
  }
}
