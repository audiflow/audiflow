// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:seasoning/entities/entities.dart';

/// An abstract class that represent the actions supported by the chosen
/// database or storage implementation.
abstract class Repository {
  // --- General

  Future<void> close();

  // --- charts

  Future<void> savePodcastChart(PodcastChartState chart);

  Future<PodcastChartState?> loadPodcastChart();

  // --- PodcastPreview

  Future<void> savePodcastPreview(Iterable<PodcastMetadata> metadataList);

  Future<PodcastPreview?> findPodcastPreview(String guid);

  Future<List<PodcastSearchResultItem>> populatePodcastFeedUrl(
    Iterable<PodcastSearchResultItem> items,
  );

  Future<String?> findFeedUrl(String guid);

  // --- Podcast

  Future<void> savePodcast(Podcast podcast,
      {PodcastStatsUpdateParam? statsParam});

  Future<Podcast?> findPodcast(String guid);

  Future<List<(PodcastMetadata, PodcastStats)>> subscriptions();

  // -- PodcastStats

  Future<void> subscribePodcast(Podcast podcast);

  Future<void> unsubscribePodcast(Podcast podcast);

  Future<void> savePodcastStats(PodcastStats stats);

  Future<PodcastStats?> findPodcastStats(String guid);

  Future<PodcastStats> updatePodcastStats(PodcastStatsUpdateParam param);

  // --- Episode

  Future<void> saveEpisode(Episode episode);

  Future<Episode?> findEpisode(String guid);

  Future<List<Episode?>> findEpisodes(Iterable<String> guids);

  Future<List<Episode>> findEpisodesByPodcastGuid(String pguid);

  // --- EpisodeStats

  Future<EpisodeStats> updateEpisodeStats(EpisodeStatsUpdateParam param);

  Future<List<EpisodeStats>> updateEpisodeStatsList(
      Iterable<EpisodeStatsUpdateParam> params);

  Future<EpisodeStats?> findEpisodeStats(String guid);

  Future<List<EpisodeStats?>> findEpisodeStatsList(Iterable<String> guids);

  // --- Downloads

  Future<void> saveDownload(Downloadable download);

  Future<void> deleteDownload(Downloadable download);

  Future<List<Downloadable>> findDownloadsByPodcastGuid(String pguid);

  Future<List<Downloadable>> findDownloads();

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

  Future<String?> playingEpisodeGuid();
}
