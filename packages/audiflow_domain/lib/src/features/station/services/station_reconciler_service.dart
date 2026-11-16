import 'package:isar_community/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
import '../../feed/models/episode.dart';
import '../../subscription/models/subscriptions.dart';
import '../models/station_podcast.dart';
import 'station_reconciler.dart';
import '../../user_state/services/station_state_access.dart';
import '../../user_state/services/user_state_store.dart';

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

  /// User state writes go through the store; see [UserStateStore].
  late final _store = UserStateStore(_isar);
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
  ///
  /// Also runs when a station is opened, so it first drops links to podcasts
  /// that are no longer subscribed to (FR 07).
  Future<void> onStationConfigChanged(int stationId) async {
    await _pruneUnsubscribedPodcasts(stationId);
    await _reconciler.reconcileFull(stationId);
  }

  /// Removes the station's links to podcasts that are missing or demoted to
  /// cached entries.
  ///
  /// Unsubscribing used to hard-delete the subscription and leave its station
  /// link behind; a resubscribe then created a new podcast id, so the station
  /// kept serving the old id's stale episodes under a blank podcast row.
  Future<void> _pruneUnsubscribedPodcasts(int stationId) {
    // Read inside the transaction so a resubscribe committing between the
    // check and the delete cannot lose its station link.
    return _store.write((txn) async {
      final links = await _isar.stationPodcasts
          .filter()
          .stationIdEqualTo(stationId)
          .findAll();
      if (links.isEmpty) return;
      final subscriptions = await _isar.subscriptions.getAll(
        links.map((link) => link.podcastId).toList(),
      );
      final stale = [
        for (var i = 0; i < links.length; i++)
          if (subscriptions[i]?.isCached ?? true) links[i],
      ];
      if (stale.isEmpty) return;
      await StationStateAccess(_isar).removeMembers(stale, txn);
      await _isar.stationPodcasts.deleteAll([for (final l in stale) l.id]);
    });
  }

  /// Called when a podcast stops being a subscription: unsubscribed (demoted
  /// to a cached entry) or deleted outright.
  ///
  /// Removes orphaned [StationPodcast] entries for the given podcast, then
  /// runs full reconciliation for each affected station so that orphaned
  /// [StationEpisode] rows are also cleaned up.
  Future<void> onSubscriptionRemoved(int podcastId) async {
    // Read and remove the podcast-to-station links in one transaction,
    // keeping the affected stations for the reconcile below.
    final affectedStationIds = await _store.write((txn) async {
      final stationPodcasts = await _isar.stationPodcasts
          .filter()
          .podcastIdEqualTo(podcastId)
          .findAll();
      await StationStateAccess(_isar).removeMembers(stationPodcasts, txn);
      await _isar.stationPodcasts.deleteAll([
        for (final sp in stationPodcasts) sp.id,
      ]);
      return {for (final sp in stationPodcasts) sp.stationId};
    });

    // Full reconciliation for each affected station cleans up StationEpisode.
    for (final stationId in affectedStationIds) {
      await _reconciler.reconcileFull(stationId);
    }
  }
}
