import 'package:isar_community/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
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

  /// Called when a station's config changes (filters, podcasts added/removed).
  Future<void> onStationConfigChanged(int stationId) async {
    await _reconciler.reconcileFull(stationId);
  }

  /// Called when a subscription is deleted.
  ///
  /// Removes orphaned [StationPodcast] entries for the given podcast, then
  /// runs full reconciliation for each affected station so that orphaned
  /// [StationEpisode] rows are also cleaned up.
  Future<void> onSubscriptionDeleted(int podcastId) async {
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
