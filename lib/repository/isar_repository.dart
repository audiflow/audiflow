//  Copyright (c) 2024 by HANAI, Tohru.
//  Copyright (c) 2024 Reedom, Inc.
//  Additional contributions from project contributors.
//  All rights reserved.
//  Use of this source code is governed by a BSD-style license that can be
//  found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/repository/repository.dart';
import 'package:collection/collection.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarRepository implements Repository {
  bool _initialized = false;
  late Isar _isar;

  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        BlockSchema,
        EpisodeSchema,
        EpisodeStatsSchema,
        FundingSchema,
        LockedSchema,
        PersonSchema,
        PodcastSchema,
        PodcastStatsSchema,
        PodcastViewStatsSchema,
        TranscriptUrlSchema,
        ValueSchema,
        ValueRecipientSchema,
      ],
      directory: dir.path,
    );
  }

  @override
  Future<void> close() async {
    await _isar.close();
  }

  // --- Podcast

  @override
  Future<Podcast?> findPodcast({Id? id, int? collectionId}) {
    if (id != null) {
      return _isar.podcasts.get(id);
    }
    if (collectionId != null) {
      return _isar.podcasts
          .where()
          .filter()
          .collectionIdEqualTo(collectionId)
          .findFirst();
    }
    throw ArgumentError('pid or collectionId must be provided');
  }

  @override
  Future<void> savePodcasts(Iterable<Podcast> podcasts) async {
    await _isar.podcasts.putAll(podcasts.toList());
  }

  @override
  Future<void> savePodcast(
    Podcast podcast, {
    PodcastStatsUpdateParam? param,
  }) async {
    await _isar.writeTxn(() async {
      await _isar.podcasts.put(podcast);
      if (param != null) {
        await _updatePodcastStats(param);
      }
    });
  }

  @override
  Future<List<Podcast>> subscriptions() async {
    final statsList = await _isar.podcastStats
        .where()
        .filter()
        .subscribedDateIsNotNull()
        .findAll();
    return _isar.podcasts
        .getAll(statsList.map((e) => e.id).toList())
        .then((value) => value.whereNotNull().toList());
  }

  @override
  Future<void> subscribePodcast(Podcast podcast) async {
    return savePodcast(
      podcast,
      param: PodcastStatsUpdateParam(
        id: podcast.id,
        subscribed: true,
      ),
    );
  }

  @override
  Future<void> unsubscribePodcast(Podcast podcast) async {
    await updatePodcastStats(
      PodcastStatsUpdateParam(
        id: podcast.id,
        subscribed: false,
      ),
    );
  }

  // -- PodcastStats

  @override
  Future<PodcastStats?> findPodcastStats(int pid) async {
    return _isar.podcastStats.get(pid);
  }

  @override
  Future<PodcastStats> updatePodcastStats(PodcastStatsUpdateParam param) async {
    return _isar.writeTxn(() => _updatePodcastStats(param));
  }

  Future<PodcastStats> _updatePodcastStats(
    PodcastStatsUpdateParam param,
  ) async {
    final stats = await _isar.podcastStats.get(param.id);
    final newStats = PodcastStats(
      id: param.id,
      subscribedDate: param.subscribed == null
          ? stats?.subscribedDate
          : param.subscribed!
              ? DateTime.now()
              : null,
      lastCheckedAt: param.lastCheckedAt ?? stats?.lastCheckedAt,
    );
    await _isar.podcastStats.put(newStats);
    return newStats;
  }

  // -- PodcastViewStats

  @override
  Future<PodcastViewStats?> findPodcastViewStats(int pid) async {
    return _isar.podcastViewStats.get(pid);
  }

  @override
  Future<PodcastViewStats> updatePodcastViewStats(
    PodcastViewStatsUpdateParam param,
  ) async {
    final stats = await _isar.podcastViewStats.get(param.id);
    final newStats = stats != null
        ? stats.copyWith(
            viewMode: param.viewMode ?? stats.viewMode,
            ascend: param.ascend ?? stats.ascend,
            ascendSeasonEpisodes:
                param.ascendSeasonEpisodes ?? stats.ascendSeasonEpisodes,
          )
        : PodcastViewStats(
            id: param.id,
            viewMode: param.viewMode ?? PodcastDetailViewMode.seasons,
            ascend: param.ascend ?? false,
            ascendSeasonEpisodes: param.ascendSeasonEpisodes ?? true,
          );
    await _isar.podcastViewStats.put(newStats);
    return newStats;
  }

  // --- Episode

  @override
  Future<Episode?> findEpisode(Id id) async {
    return _isar.episodes.get(id);
  }

  @override
  Future<List<Episode?>> findEpisodes(Iterable<Id> ids) async {
    return _isar.episodes.getAll(ids.toList());
  }

  @override
  Future<List<Episode>> findEpisodesByPodcastId(Id pid) async {
    return _isar.episodes.where().filter().pidEqualTo(pid).findAll();
  }

  @override
  Future<void> saveEpisode(Episode episode) async {
    await _isar.episodes.put(episode);
  }

  @override
  Future<void> saveEpisodes(Iterable<Episode> episodes) async {
    await _isar.episodes.putAll(episodes.toList());
  }

  // --- EpisodeStats

  @override
  Future<EpisodeStats?> findEpisodeStats(Id id) async {
    return _isar.episodeStats.get(id);
  }

  @override
  Future<List<EpisodeStats?>> findEpisodeStatsList(Iterable<Id> ids) async {
    return _isar.episodeStats.getAll(ids.toList());
  }

  @override
  Future<EpisodeStats> updateEpisodeStats(EpisodeStatsUpdateParam param) async {
    return _updateEpisodeStats(param);
  }

  Future<EpisodeStats> _updateEpisodeStats(
    EpisodeStatsUpdateParam param,
  ) async {
    final stats = await _isar.episodeStats.get(param.id);
    final newStats = EpisodeStats(
      id: param.id,
      pid: param.pid,
      positionMS: param.position?.inMilliseconds ?? stats?.positionMS ?? 0,
      playCount: (stats?.playCount ?? 0) + (param.played == true ? 1 : 0),
      playTotalMS: (stats?.playTotalMS ?? 0) +
          (param.playTotalDelta?.inMilliseconds ?? 0),
      played: (stats?.played ?? false) || (param.played ?? false),
      completeCount:
          (stats?.completeCount ?? 0) + (param.completed == true ? 1 : 0),
      inQueue: (stats?.inQueue ?? false) || (param.inQueue ?? false),
      downloadedTime: param.downloaded == null
          ? stats?.downloadedTime
          : param.downloaded!
              ? DateTime.now()
              : null,
      lastPlayedAt: param.lastPlayedAt ?? stats?.lastPlayedAt,
    );
    await _isar.episodeStats.put(newStats);
    return newStats;
  }

  @override
  Future<List<EpisodeStats>> updateEpisodeStatsList(
    Iterable<EpisodeStatsUpdateParam> params,
  ) async {
    return _isar.writeTxn(() => Future.wait(params.map(_updateEpisodeStats)));
  }

  @override
  Future<List<EpisodeStats>> findDownloadedEpisodeStatsList(Id pid) async {
    return _isar.episodeStats
        .where()
        .filter()
        .pidEqualTo(pid)
        .downloadedTimeIsNotNull()
        .findAll();
  }

  @override
  Future<List<EpisodeStats>> findPlayedEpisodeStatsList(Id pid) async {
    return _isar.episodeStats
        .where()
        .filter()
        .playedEqualTo(true)
        .downloadedTimeIsNotNull()
        .findAll();
  }

  @override
  Future<List<EpisodeStats>> findUnplayedEpisodeStatsList(Id pid) async {
    return _isar.episodeStats
        .where()
        .filter()
        .playedEqualTo(false)
        .downloadedTimeIsNotNull()
        .findAll();
  }

  // --- Recently played episodes

  @override
  Future<(List<Episode>, int?)> findRecentlyPlayedEpisodeList({
    int? cursor,
    int limit = 100,
  }) async {
    final ids = await _isar.episodeStats
        .where(sort: Sort.desc)
        .sortByLastPlayedAtDesc()
        .offset(cursor ?? 0)
        .limit(limit)
        .idProperty()
        .findAll();
    final nextCursor = ids.length < limit ? null : (cursor ?? 0) + limit;
    final episodes = await _isar.episodes
        .getAll(ids)
        .then((value) => value.whereNotNull().toList());
    return (episodes, nextCursor);
  }

  @override
  Future<void> saveRecentlyPlayedEpisode(
    Episode episode, {
    DateTime? playedAt,
  }) async {
    await updateEpisodeStats(
      EpisodeStatsUpdateParam(
        id: episode.id,
        pid: episode.pid,
        lastPlayedAt: playedAt ?? DateTime.now(),
      ),
    );
  }

  @override
  Future<void> clearPlayingEpisodeGuid() {
    // TODO: implement clearPlayingEpisodeGuid
    throw UnimplementedError();
  }

  @override
  Future<void> deleteDownload(Downloadable download) {
    // TODO: implement deleteDownload
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTranscriptById(int id) {
    // TODO: implement deleteTranscriptById
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTranscriptsById(List<int> id) {
    // TODO: implement deleteTranscriptsById
    throw UnimplementedError();
  }

  @override
  Future<List<Downloadable>> findAllDownloads() {
    // TODO: implement findAllDownloads
    throw UnimplementedError();
  }

  @override
  Future<Downloadable?> findDownload(String guid) {
    // TODO: implement findDownload
    throw UnimplementedError();
  }

  @override
  Future<Downloadable?> findDownloadByTaskId(String taskId) {
    // TODO: implement findDownloadByTaskId
    throw UnimplementedError();
  }

  @override
  Future<List<Downloadable>> findDownloads(Iterable<String> guids) {
    // TODO: implement findDownloads
    throw UnimplementedError();
  }

  @override
  Future<List<Downloadable>> findDownloadsByPodcastGuid(String pguid) {
    // TODO: implement findDownloadsByPodcastGuid
    throw UnimplementedError();
  }

  @override
  Future<Transcript?> findTranscriptById(int id) {
    // TODO: implement findTranscriptById
    throw UnimplementedError();
  }

  @override
  Future<Queue> loadQueue() {
    // TODO: implement loadQueue
    throw UnimplementedError();
  }

  @override
  Future<String?> playingEpisodeGuid() {
    // TODO: implement playingEpisodeGuid
    throw UnimplementedError();
  }

  @override
  Future<void> saveDownload(Downloadable download) {
    // TODO: implement saveDownload
    throw UnimplementedError();
  }

  @override
  Future<void> savePlayingEpisodeGuid(String guid) {
    // TODO: implement savePlayingEpisodeGuid
    throw UnimplementedError();
  }

  @override
  Future<void> saveQueue(Queue queue) {
    // TODO: implement saveQueue
    throw UnimplementedError();
  }

  @override
  Future<Transcript> saveTranscript(Transcript transcript) {
    // TODO: implement saveTranscript
    throw UnimplementedError();
  }
}
