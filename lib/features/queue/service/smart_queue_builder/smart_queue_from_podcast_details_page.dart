import 'dart:async';
import 'dart:convert';

import 'package:audiflow/features/browser/common/data/episode_stats_repository/episode_stats_repository.dart';
import 'package:audiflow/features/browser/common/model/episode_filter_mode.dart';
import 'package:audiflow/features/download/data/download_repository.dart';
import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:audiflow/features/feed/data/episode_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/features/queue/model/queue_item.dart';
import 'package:audiflow/features/queue/service/smart_queue_builder/smart_queue_builder.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'smart_queue_from_podcast_details_page.freezed.dart';
part 'smart_queue_from_podcast_details_page.g.dart';

@Riverpod(keepAlive: true)
class SmartQueueFromPodcastDetailsPage
    extends _$SmartQueueFromPodcastDetailsPage implements SmartQueueBuilder {
  int _pid = 0;
  int? _ordinal;
  EpisodeFilterMode _filterMode = EpisodeFilterMode.all;

  EpisodeRepository get _episodeRepository =>
      ref.read(episodeRepositoryProvider);

  EpisodeStatsRepository get _episodeStatsRepository =>
      ref.read(episodeStatsRepositoryProvider);

  DownloadRepository get _downloadRepository =>
      ref.read(downloadRepositoryProvider);

  @override
  QueueItem? build() => null;

  void setup({
    required Episode start,
    required EpisodeFilterMode filterMode,
  }) {
    _pid = start.pid;
    _ordinal = start.ordinal;
    _filterMode = filterMode;
    state = _toQueueItemFromEpisode(start);
  }

  @override
  void clear() {
    _pid = 0;
    _ordinal = null;
  }

  @override
  QueueItem? get current => state;

  @override
  FutureOr<List<QueueItem>> getQueuedItems({required int limit}) async {
    if (state == null || _ordinal == null) {
      return [];
    }

    final (items, _) = await _getQueuedItems(limit: limit);
    return items;
  }

  @override
  FutureOr<bool> moveNext() async {
    final (items, ordinal) = await _getQueuedItems(limit: 1);
    state = items.lastOrNull;
    _ordinal = ordinal;
    return state != null;
  }

  @override
  FutureOr<bool> decodeState(String encoded) {
    try {
      final map = jsonDecode(encoded);
      final info = _Info.fromJson(map as Map<String, dynamic>);
      _pid = info.pid;
      _ordinal = info.ordinal;
      _filterMode = info.filterMode;
      return true;
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return false;
    }
  }

  @override
  String encodeState() {
    final info = _Info(
      pid: _pid,
      ordinal: _ordinal ?? 0,
      filterMode: _filterMode,
    );
    return jsonEncode(info.toJson());
  }

  FutureOr<(List<QueueItem>, int?)> _getQueuedItems({
    required int limit,
  }) async {
    if (state == null || _ordinal == null) {
      return (<QueueItem>[], null);
    }

    switch (_filterMode) {
      case EpisodeFilterMode.all:
        return _queryEpisodes(limit);
      case EpisodeFilterMode.unplayed:
        return _queryUnplayedEpisodes(limit);
      case EpisodeFilterMode.completed:
        return _queryCompletedEpisodes(limit);
      case EpisodeFilterMode.downloaded:
        return _queryDownloadedEpisodes(limit);
    }
  }

  Future<(List<QueueItem>, int?)> _queryEpisodes(int limit) async {
    final episodes = await _episodeRepository.queryEpisodes(
      pid: _pid,
      lastOrdinal: _ordinal,
      ascending: true,
      limit: limit,
    );
    final queueItems = episodes.map(_toQueueItemFromEpisode).toList();
    return (queueItems, episodes.lastOrNull?.ordinal);
  }

  Future<(List<QueueItem>, int?)> _queryUnplayedEpisodes(int limit) async {
    final result = <QueueItem>[];

    var ordinal = _ordinal;
    while (result.length < limit) {
      final episodes = await _episodeRepository.queryEpisodes(
        pid: _pid,
        lastOrdinal: ordinal,
        ascending: true,
        limit: 100,
      );
      if (episodes.isEmpty) {
        break;
      }

      final statsList = await _episodeStatsRepository
          .findEpisodeStatsList(episodes.map((e) => e.id));
      final unplayed = episodes
          .whereIndexed((i, e) => (statsList[i]?.completeCount ?? 0) < 1)
          .take(limit - result.length);
      result.addAll(unplayed.map(_toQueueItemFromEpisode));
      if (result.length == limit) {
        return (result, unplayed.last.ordinal);
      }
      ordinal = episodes.last.ordinal;
    }
    return (result, null);
  }

  Future<(List<QueueItem>, int?)> _queryCompletedEpisodes(
    int limit,
  ) async {
    final statsList =
        await _episodeStatsRepository.queryCompletedEpisodeStatsList(
      pid: _pid,
      lastOrdinal: _ordinal,
      ascending: true,
      limit: limit,
    );
    final queueItems = statsList.map(_toQueueItemFromStats).toList();
    return (queueItems, statsList.lastOrNull?.ordinal);
  }

  Future<(List<QueueItem>, int?)> _queryDownloadedEpisodes(
    int limit,
  ) async {
    final downloads = await _downloadRepository.queryDownloaded(
      pid: _pid,
      lastOrdinal: _ordinal,
      ascending: true,
      limit: limit,
    );
    final queueItems = downloads.map(_toQueueItemFromDownloadable).toList();
    return (queueItems, downloads.lastOrNull?.ordinal);
  }

  QueueItem _toQueueItemFromEpisode(Episode e) {
    return SmartQueueItem(pid: _pid, eid: e.id, ordinal: e.ordinal);
  }

  QueueItem _toQueueItemFromStats(EpisodeStats stats) {
    return SmartQueueItem(pid: _pid, eid: stats.eid, ordinal: stats.ordinal);
  }

  QueueItem _toQueueItemFromDownloadable(Downloadable d) {
    return SmartQueueItem(pid: _pid, eid: d.eid, ordinal: d.ordinal);
  }
}

@freezed
class _Info with _$Info {
  const factory _Info({
    required int pid,
    required int ordinal,
    required EpisodeFilterMode filterMode,
  }) = __Info;

  factory _Info.fromJson(Map<String, dynamic> json) => _$InfoFromJson(json);
}
