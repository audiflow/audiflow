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
  Future<Podcast?> findPodcast({int? pid, int? collectionId}) {
    if (pid != null) {
      return _isar.podcasts.get(pid);
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
    PodcastStatsUpdateParam? statsParam,
  }) async {
    await _isar.writeTxn(() async {
      await _isar.podcasts.put(podcast);
      if (statsParam != null) {
        await _updatePodcastStats(statsParam);
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
      statsParam: PodcastStatsUpdateParam(
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
      PodcastStatsUpdateParam param) async {
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
  Future<List<EpisodeStats>> findDownloadedEpisodeStatsList(String pguid) {
    // TODO: implement findDownloadedEpisodeStatsList
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
  Future<Episode?> findEpisode(String guid) {
    // TODO: implement findEpisode
    throw UnimplementedError();
  }

  @override
  Future<EpisodeStats?> findEpisodeStats(String guid) {
    // TODO: implement findEpisodeStats
    throw UnimplementedError();
  }

  @override
  Future<List<EpisodeStats?>> findEpisodeStatsList(Iterable<String> guids) {
    // TODO: implement findEpisodeStatsList
    throw UnimplementedError();
  }

  @override
  Future<List<Episode?>> findEpisodes(Iterable<String> guids) {
    // TODO: implement findEpisodes
    throw UnimplementedError();
  }

  @override
  Future<List<Episode>> findEpisodesByPodcastGuid(String pguid) {
    // TODO: implement findEpisodesByPodcastGuid
    throw UnimplementedError();
  }

  @override
  Future<List<EpisodeStats>> findPlayedEpisodeStatsList(String pguid) {
    // TODO: implement findPlayedEpisodeStatsList
    throw UnimplementedError();
  }

  @override
  Future<(List<Episode>, int?)> findRecentlyPlayedEpisodeList(
      {int? cursor, int limit = 100}) {
    // TODO: implement findRecentlyPlayedEpisodeList
    throw UnimplementedError();
  }

  @override
  Future<Transcript?> findTranscriptById(int id) {
    // TODO: implement findTranscriptById
    throw UnimplementedError();
  }

  @override
  Future<List<EpisodeStats>> findUnplayedEpisodeStatsList(String pguid) {
    // TODO: implement findUnplayedEpisodeStatsList
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
  Future<void> saveEpisode(Episode episode) {
    // TODO: implement saveEpisode
    throw UnimplementedError();
  }

  @override
  Future<void> saveEpisodes(Iterable<Episode> episodes) {
    // TODO: implement saveEpisodes
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
  Future<void> saveRecentlyPlayedEpisode(Episode episode,
      {DateTime? playedAt}) {
    // TODO: implement saveRecentlyPlayedEpisode
    throw UnimplementedError();
  }

  @override
  Future<Transcript> saveTranscript(Transcript transcript) {
    // TODO: implement saveTranscript
    throw UnimplementedError();
  }

  @override
  Future<EpisodeStats> updateEpisodeStats(EpisodeStatsUpdateParam param) {
    // TODO: implement updateEpisodeStats
    throw UnimplementedError();
  }

  @override
  Future<List<EpisodeStats>> updateEpisodeStatsList(
      Iterable<EpisodeStatsUpdateParam> params) {
    // TODO: implement updateEpisodeStatsList
    throw UnimplementedError();
  }
}
