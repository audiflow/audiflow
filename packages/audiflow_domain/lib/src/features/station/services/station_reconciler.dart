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
  /// When a [publishedWithinDays] filter is set, only queries episodes
  /// newer than the cutoff date from the DB, avoiding evaluation of
  /// the entire episode history.
  Future<void> reconcileFull(int stationId) async {
    final station = await _isar.stations.get(stationId);
    if (station == null) return;

    final stationPodcasts = await _isar.stationPodcasts
        .filter()
        .stationIdEqualTo(stationId)
        .findAll();
    final podcastIds = stationPodcasts.map((sp) => sp.podcastId).toList();

    final now = DateTime.now();
    final cutoff = station.publishedWithinDays != null
        ? now.subtract(Duration(days: station.publishedWithinDays!))
        : null;

    final episodes = <Episode>[];
    for (final podcastId in podcastIds) {
      var query = _isar.episodes.filter().podcastIdEqualTo(podcastId);
      if (cutoff != null) {
        query = query.and().publishedAtGreaterThan(cutoff, include: true);
      }
      if (station.filterFavorited) {
        query = query.and().isFavoritedEqualTo(true);
      }
      if (station.durationFilter case final df?) {
        final thresholdMs = df.durationMinutes * 60 * 1000;
        query = switch (df.durationOperator) {
          'shorterThan' => query.and().durationMsLessThan(thresholdMs),
          'longerThan' => query.and().durationMsGreaterThan(thresholdMs),
          _ => query,
        };
      }
      episodes.addAll(await query.findAll());
    }

    debugPrint(
      '[Reconciler] reconcileFull: station=$stationId '
      'podcasts=${podcastIds.length} '
      'candidates=${episodes.length} '
      'cutoff=$cutoff',
    );

    final matchingIds = <int>{};
    for (final episode in episodes) {
      if (await _matchesConditions(episode, station, now: now)) {
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
            ..sortKey = episodeMap[episodeId]?.publishedAt,
        );
      }

      // Update sortKey for existing entries whose publishedAt changed.
      for (final episodeId in toKeep) {
        final existing = currentMap[episodeId];
        final newSortKey = episodeMap[episodeId]?.publishedAt;
        if (existing != null && existing.sortKey != newSortKey) {
          upsertEntries.add(
            StationEpisode()
              ..id = existing.id
              ..stationId = stationId
              ..episodeId = episodeId
              ..sortKey = newSortKey,
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
        } else if (matches && existing != null) {
          if (existing.sortKey != episode.publishedAt) {
            existing.sortKey = episode.publishedAt;
            await _isar.stationEpisodes.put(existing);
          }
        } else if (!matches && existing != null) {
          await _isar.stationEpisodes.delete(existing.id);
        }
      });
    }
  }

  /// Evaluates whether an episode matches all station filter conditions.
  ///
  /// [now] anchors the time-based filters so that the DB pre-filter
  /// and in-memory predicate use the same reference instant.
  Future<bool> _matchesConditions(
    Episode episode,
    Station station, {
    DateTime? now,
  }) async {
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
    if (station.publishedWithinDays != null) {
      if (!_matchesPublishedWithin(
        episode,
        station.publishedWithinDays!,
        now: now,
      )) {
        return false;
      }
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

  bool _matchesPublishedWithin(Episode episode, int days, {DateTime? now}) {
    final publishedAt = episode.publishedAt;
    if (publishedAt == null) return false;
    final cutoff = (now ?? DateTime.now()).subtract(Duration(days: days));
    return !publishedAt.isBefore(cutoff);
  }
}
