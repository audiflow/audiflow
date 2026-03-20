import 'package:isar_community/isar.dart';

import '../../download/models/download_status.dart';
import '../../download/models/download_task.dart';
import '../../feed/models/episode.dart';
import '../../player/models/playback_history.dart';
import '../models/station.dart';
import '../models/station_duration_filter.dart';
import '../models/station_episode.dart';
import '../models/station_playback_state.dart';
import '../models/station_podcast.dart';

/// Evaluates episodes against station filter conditions and maintains
/// the [StationEpisode] materialized view via diff-based updates.
class StationReconciler {
  StationReconciler({required Isar isar}) : _isar = isar;

  final Isar _isar;

  /// Full reconciliation: recalculate all episodes for a station.
  ///
  /// Called when station config changes (filters, podcasts added/removed).
  Future<void> reconcileFull(int stationId) async {
    final station = await _isar.stations.get(stationId);
    if (station == null) return;

    final stationPodcasts = await _isar.stationPodcasts
        .filter()
        .stationIdEqualTo(stationId)
        .findAll();
    final podcastIds = stationPodcasts.map((sp) => sp.podcastId).toList();

    final episodes = <Episode>[];
    for (final podcastId in podcastIds) {
      final podcastEpisodes = await _isar.episodes
          .filter()
          .podcastIdEqualTo(podcastId)
          .findAll();
      episodes.addAll(podcastEpisodes);
    }

    final matchingIds = <int>{};
    for (final episode in episodes) {
      if (await _matchesConditions(episode, station)) {
        matchingIds.add(episode.id);
      }
    }

    final current = await _isar.stationEpisodes
        .filter()
        .stationIdEqualTo(stationId)
        .findAll();
    final currentIds = current.map((e) => e.episodeId).toSet();

    final toInsert = matchingIds.difference(currentIds);
    final toDelete = currentIds.difference(matchingIds);

    final episodeMap = {for (final e in episodes) e.id: e};

    await _isar.writeTxn(() async {
      if (toDelete.isNotEmpty) {
        final deleteIds = current
            .where((e) => toDelete.contains(e.episodeId))
            .map((e) => e.id)
            .toList();
        await _isar.stationEpisodes.deleteAll(deleteIds);
      }
      if (toInsert.isNotEmpty) {
        final newEntries = toInsert
            .map(
              (episodeId) => StationEpisode()
                ..stationId = stationId
                ..episodeId = episodeId
                ..sortKey = episodeMap[episodeId]?.publishedAt,
            )
            .toList();
        await _isar.stationEpisodes.putAll(newEntries);
      }
    });
  }

  /// Differential reconciliation: re-evaluate a single episode
  /// across all stations that include its podcast.
  Future<void> reconcileEpisode(int episodeId) async {
    final episode = await _isar.episodes.get(episodeId);
    if (episode == null) return;

    final stationPodcasts = await _isar.stationPodcasts
        .filter()
        .podcastIdEqualTo(episode.podcastId)
        .findAll();

    for (final sp in stationPodcasts) {
      final station = await _isar.stations.get(sp.stationId);
      if (station == null) continue;

      final matches = await _matchesConditions(episode, station);
      final existing = await _isar.stationEpisodes
          .filter()
          .stationIdEqualTo(sp.stationId)
          .and()
          .episodeIdEqualTo(episodeId)
          .findFirst();

      await _isar.writeTxn(() async {
        if (matches && existing == null) {
          await _isar.stationEpisodes.put(
            StationEpisode()
              ..stationId = sp.stationId
              ..episodeId = episodeId
              ..sortKey = episode.publishedAt,
          );
        } else if (!matches && existing != null) {
          await _isar.stationEpisodes.delete(existing.id);
        }
      });
    }
  }

  /// Evaluates whether an episode matches all station filter conditions.
  Future<bool> _matchesConditions(Episode episode, Station station) async {
    if (!await _matchesPlaybackState(episode.id, station.playbackStateFilter)) {
      return false;
    }
    if (station.filterDownloaded && !await _isDownloaded(episode.id)) {
      return false;
    }
    if (station.filterFavorited && !episode.isFavorited) {
      return false;
    }
    if (station.durationFilter != null) {
      if (!_matchesDuration(episode, station.durationFilter!)) return false;
    }
    if (station.publishedWithinDays != null) {
      if (!_matchesPublishedWithin(episode, station.publishedWithinDays!)) {
        return false;
      }
    }
    return true;
  }

  Future<bool> _matchesPlaybackState(
    int episodeId,
    StationPlaybackState state,
  ) async {
    if (state == StationPlaybackState.all) return true;

    final history = await _isar.playbackHistorys
        .filter()
        .episodeIdEqualTo(episodeId)
        .findFirst();

    return switch (state) {
      StationPlaybackState.all => true,
      StationPlaybackState.unplayed =>
        history == null ||
            (history.completedAt == null && history.positionMs == 0),
      StationPlaybackState.inProgress =>
        history != null &&
            history.completedAt == null &&
            0 < history.positionMs,
    };
  }

  Future<bool> _isDownloaded(int episodeId) async {
    final task = await _isar.downloadTasks
        .filter()
        .episodeIdEqualTo(episodeId)
        .findFirst();
    if (task == null) return false;
    return task.downloadStatus == const DownloadStatus.completed();
  }

  bool _matchesDuration(Episode episode, StationDurationFilter filter) {
    final durationMs = episode.durationMs;
    if (durationMs == null) return false;
    final thresholdMs = filter.durationMinutes * 60 * 1000;
    return switch (filter.durationOperator) {
      'shorterThan' => durationMs < thresholdMs,
      'longerThan' => thresholdMs < durationMs,
      _ => true,
    };
  }

  bool _matchesPublishedWithin(Episode episode, int days) {
    final publishedAt = episode.publishedAt;
    if (publishedAt == null) return false;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return cutoff.isBefore(publishedAt);
  }
}
