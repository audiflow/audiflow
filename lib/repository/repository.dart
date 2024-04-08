// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:isar/isar.dart';

/// An abstract class that represent the actions supported by the chosen
/// database or storage implementation.
///
/// An implementation of [Repository] that is backed by
/// [Sembast](https://github.com/tekartik/sembast.dart/tree/master/sembast)
///
///
/// <Data Management Rules>
///
/// It utilize [PodcastMetadata], [EpisodeMetadata] to reduce the data size.
/// It stores in [Podcast] only for subscribed podcasts. Otherwise, it stores in
/// [PodcastMetadata].
/// Either [Podcast] or [PodcastMetadata] must be found if any of their episode
/// is saved under the following state:
///  - downloaded
///  - queued
///  - once played(for Recently Played feature)
///
/// It stores in [Episode] if the episode in the following state:
///  - its podcast is subscribed
///  - downloaded
///  - queued
/// Or it stores in [EpisodeMetadata] if the episode in the following state:
///  - once played(for Recently Played feature)
///
/// xxxStats never get deleted.
///  - [PodcastStats]
///  - [PodcastViewStats]
///  - [EpisodeStats]
abstract class Repository {
  // --- General

  Future<void> close();

  // --- Podcast

  Future<Podcast?> findPodcast({Id? id, int? collectionId});

  Future<void> savePodcasts(Iterable<Podcast> podcasts);

  Future<void> savePodcast(
    Podcast podcast, {
    PodcastStatsUpdateParam? param,
  });

  Future<List<Podcast>> subscriptions();

  Future<void> subscribePodcast(Podcast podcast);

  Future<void> unsubscribePodcast(Podcast podcast);

  // -- PodcastStats

  Future<PodcastStats?> findPodcastStats(int pid);

  Future<PodcastStats> updatePodcastStats(PodcastStatsUpdateParam param);

  // -- PodcastViewStats

  Future<PodcastViewStats?> findPodcastViewStats(int pid);

  Future<PodcastViewStats> updatePodcastViewStats(
    PodcastViewStatsUpdateParam param,
  );

  // --- Episode

  Future<Episode?> findEpisode(Id id);

  Future<List<Episode?>> findEpisodes(Iterable<Id> ids);

  Future<List<Episode>> findEpisodesByPodcastId(Id pid);

  Future<void> saveEpisode(Episode episode);

  Future<void> saveEpisodes(Iterable<Episode> episodes);

  // --- EpisodeStats

  Future<EpisodeStats?> findEpisodeStats(Id id);

  Future<List<EpisodeStats?>> findEpisodeStatsList(Iterable<Id> ids);

  Future<EpisodeStats> updateEpisodeStats(EpisodeStatsUpdateParam param);

  Future<List<EpisodeStats>> updateEpisodeStatsList(
    Iterable<EpisodeStatsUpdateParam> params,
  );

  Future<List<EpisodeStats>> findDownloadedEpisodeStatsList(Id pid);

  Future<List<EpisodeStats>> findPlayedEpisodeStatsList(Id pid);

  Future<List<EpisodeStats>> findUnplayedEpisodeStatsList(Id pid);

  // --- Recently played episodes

  Future<(List<Episode>, int?)> findRecentlyPlayedEpisodeList({
    int? cursor,
    int limit = 100,
  });

  Future<void> saveRecentlyPlayedEpisode(
    Episode episode, {
    DateTime? playedAt,
  });

  // --- Downloads

  Future<void> saveDownload(Downloadable download);

  Future<void> deleteDownload(Downloadable download);

  Future<List<Downloadable>> findDownloadsByPodcastGuid(String pguid);

  Future<List<Downloadable>> findAllDownloads();

  Future<List<Downloadable>> findDownloads(Iterable<String> guids);

  Future<Downloadable?> findDownload(String guid);

  Future<Downloadable?> findDownloadByTaskId(String taskId);

  // --- Transcript

  Future<Transcript> saveTranscript(Transcript transcript);

  Future<void> deleteTranscriptById(int id);

  Future<void> deleteTranscriptsById(List<int> id);

  Future<Transcript?> findTranscriptById(int id);

  // --- Queue

  Future<void> saveQueue(Queue queue);

  Future<Queue> loadQueue();

  // --- Player

  Future<void> savePlayingEpisodeGuid(String guid);

  Future<void> clearPlayingEpisodeGuid();

  Future<String?> playingEpisodeGuid();
}
