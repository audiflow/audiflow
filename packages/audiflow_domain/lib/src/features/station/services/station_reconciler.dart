import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../../download/models/download_status.dart';
import '../../download/models/download_task.dart';
import '../../feed/models/episode.dart';
import '../../player/models/playback_history.dart';
import '../models/station.dart';
import '../models/station_duration_filter.dart';
import '../models/station_episode.dart';
import '../models/station_podcast.dart';

/// Evaluates episodes against station filter conditions and maintains
/// the [StationEpisode] materialized view via diff-based updates.
class StationReconciler {
  StationReconciler({required Isar isar}) : _isar = isar;

  final Isar _isar;

  /// Full reconciliation: recalculate all episodes for a station.
  ///
  /// Called when station config changes (filters, podcasts added/removed).
  /// For each podcast, queries the newest N episodes (per [Station.defaultEpisodeLimit]
  /// or [StationPodcast.episodeLimit]), then evaluates attribute conditions
  /// (hideCompleted, filterDownloaded, filterFavorited, durationFilter).
  Future<void> reconcileFull(int stationId) async {
    final station = await _isar.stations.get(stationId);
    if (station == null) return;

    final stationPodcasts = await _isar.stationPodcasts
        .filter()
        .stationIdEqualTo(stationId)
        .findAll();

    // episodePodcastSortKeys maps episodeId -> sortOrder from its StationPodcast
    final episodePodcastSortKeys = <int, int>{};
    final episodes = <Episode>[];

    for (final sp in stationPodcasts) {
      // episodeLimit 0 means "explicitly all episodes" (per-podcast override).
      final rawLimit = sp.episodeLimit ?? station.defaultEpisodeLimit;
      final limit = (rawLimit == null || rawLimit == 0) ? null : rawLimit;

      // Apply count limit purely by date — attribute filters (favorited,
      // duration, completed, downloaded) are evaluated in _matchesConditions
      // so the limit always selects the N most-recent episodes regardless of
      // filter match.
      final sorted = _isar.episodes
          .filter()
          .podcastIdEqualTo(sp.podcastId)
          .sortByPublishedAtDesc();
      final podcastEpisodes = limit != null
          ? await sorted.limit(limit).findAll()
          : await sorted.findAll();

      for (final ep in podcastEpisodes) {
        episodePodcastSortKeys[ep.id] = sp.sortOrder;
      }
      episodes.addAll(podcastEpisodes);
    }

    final podcastIds = stationPodcasts.map((sp) => sp.podcastId).toList();

    debugPrint(
      '[Reconciler] reconcileFull: station=$stationId '
      'podcasts=${podcastIds.length} '
      'candidates=${episodes.length}',
    );

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
    final toKeep = matchingIds.intersection(currentIds);

    debugPrint(
      '[Reconciler] reconcileFull: '
      'matching=${matchingIds.length} '
      'insert=${toInsert.length} '
      'delete=${toDelete.length} '
      'keep=${toKeep.length}',
    );

    final episodeMap = {for (final e in episodes) e.id: e};
    final currentMap = {for (final e in current) e.episodeId: e};

    await _isar.writeTxn(() async {
      if (toDelete.isNotEmpty) {
        final deleteIds = current
            .where((e) => toDelete.contains(e.episodeId))
            .map((e) => e.id)
            .toList();
        await _isar.stationEpisodes.deleteAll(deleteIds);
      }

      final upsertEntries = <StationEpisode>[];

      for (final episodeId in toInsert) {
        upsertEntries.add(
          StationEpisode()
            ..stationId = stationId
            ..episodeId = episodeId
            ..sortKey = episodeMap[episodeId]?.publishedAt
            ..podcastSortKey = episodePodcastSortKeys[episodeId] ?? 0,
        );
      }

      // Update sortKey/podcastSortKey for existing entries whose values changed.
      for (final episodeId in toKeep) {
        final existing = currentMap[episodeId];
        final newSortKey = episodeMap[episodeId]?.publishedAt;
        final newPodcastSortKey = episodePodcastSortKeys[episodeId] ?? 0;
        if (existing != null &&
            (existing.sortKey != newSortKey ||
                existing.podcastSortKey != newPodcastSortKey)) {
          upsertEntries.add(
            StationEpisode()
              ..id = existing.id
              ..stationId = stationId
              ..episodeId = episodeId
              ..sortKey = newSortKey
              ..podcastSortKey = newPodcastSortKey,
          );
        }
      }

      if (upsertEntries.isNotEmpty) {
        await _isar.stationEpisodes.putAll(upsertEntries);
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

    if (stationPodcasts.isEmpty) return;

    for (final sp in stationPodcasts) {
      final station = await _isar.stations.get(sp.stationId);
      if (station == null) continue;

      final rawLimit = sp.episodeLimit ?? station.defaultEpisodeLimit;
      final limit = (rawLimit == null || rawLimit == 0) ? null : rawLimit;
      final withinLimit = await _isWithinCountLimit(
        episode,
        episode.podcastId,
        limit,
      );

      final matches = withinLimit && await _matchesConditions(episode, station);
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
              ..sortKey = episode.publishedAt
              ..podcastSortKey = sp.sortOrder,
          );
        } else if (matches && existing != null) {
          if (existing.sortKey != episode.publishedAt ||
              existing.podcastSortKey != sp.sortOrder) {
            existing
              ..sortKey = episode.publishedAt
              ..podcastSortKey = sp.sortOrder;
            await _isar.stationEpisodes.put(existing);
          }
        } else if (!matches && existing != null) {
          await _isar.stationEpisodes.delete(existing.id);
        }
      });
    }
  }

  /// Returns true if the episode is within the top [limit] newest episodes
  /// for its podcast. If [limit] is null, always returns true.
  Future<bool> _isWithinCountLimit(
    Episode episode,
    int podcastId,
    int? limit,
  ) async {
    if (limit == null) return true;
    final publishedAt = episode.publishedAt ?? DateTime(1970);
    final newerCount = await _isar.episodes
        .filter()
        .podcastIdEqualTo(podcastId)
        .and()
        .publishedAtGreaterThan(publishedAt)
        .count();
    return newerCount < limit;
  }

  /// Evaluates whether an episode matches all station attribute filter
  /// conditions (hideCompleted, filterDownloaded, filterFavorited,
  /// durationFilter). Count-based limiting is handled separately.
  Future<bool> _matchesConditions(Episode episode, Station station) async {
    if (station.hideCompleted && await _isCompleted(episode.id)) {
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
    return true;
  }

  Future<bool> _isCompleted(int episodeId) async {
    final history = await _isar.playbackHistorys
        .filter()
        .episodeIdEqualTo(episodeId)
        .findFirst();
    return history != null && history.completedAt != null;
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
      _ => false,
    };
  }
}
