// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:seasoning/entities/downloadable.dart';
import 'package:seasoning/entities/episode.dart';
import 'package:seasoning/entities/podcast.dart';
import 'package:seasoning/entities/transcript.dart';
import 'package:seasoning/events/download_event.dart';
import 'package:seasoning/events/episode_event.dart';
import 'package:seasoning/events/podcast_event.dart';

/// An abstract class that represent the actions supported by the chosen
/// database or storage implementation.
abstract class Repository {
  // Event listeners
  Stream<PodcastEvent> get podcastStream;

  Stream<EpisodeEvent> get episodeStream;

  Stream<DownloadEvent> get downloadStream;

  // --- General
  Future<void> close();

  // --- Podcast
  Future<void> savePodcast(int id, Podcast podcast);

  Future<Podcast?> findPodcastById(int id);

  Future<(int?, Podcast?)> findPodcastByGuid(String guid);

  Future<List<(PodcastStats, PodcastSummary)>> subscriptions();

  // -- PodcastStats

  Future<PodcastStats> subscribePodcast(Podcast podcast);

  Future<void> unsubscribePodcast(PodcastStats stats);

  Future<void> savePodcastStats(PodcastStats stats);

  Future<PodcastStats?> findPodcastStatsById(int id);

  Future<PodcastStats?> findPodcastStatsByGuid(String guid);

  // --- Episode

  Future<void> saveEpisodes(List<Episode> episodes);

  Future<void> saveEpisode(Episode episode);

  Future<void> deleteEpisodes(List<Episode> episodes);

  Future<void> deleteEpisode(Episode episode);

  Future<Episode?> findEpisodeById(int id);

  Future<(int?, Episode?)> findEpisodeByGuid(String guid);

  Future<List<Episode>> findEpisodesByPodcastGuid(String pguid);

  // --- EpisodeStats

  Future<EpisodeStats> createEpisodeStats(Episode episode);

  Future<void> saveEpisodeStats(EpisodeStats stats);

  Future<EpisodeStats?> findEpisodeStatsById(int id);

  Future<EpisodeStats?> findEpisodeStatsByGuid(String guid);

  // --- Downloads

  Future<Downloadable> saveDownload(Downloadable download);

  Future<void> deleteDownload(Downloadable download);

  Future<List<Downloadable>> findDownloadsByPodcastGuid(String pguid);

  Future<List<Downloadable>> findDownloads();

  Future<Downloadable?> findDownloadByGuid(String guid);

  Future<Downloadable?> findDownloadByTaskId(String taskId);

  // --- Transcript

  Future<Transcript> saveTranscript(Transcript transcript);

  Future<void> deleteTranscriptById(int id);

  Future<void> deleteTranscriptsById(List<int> id);

  Future<Transcript?> findTranscriptById(int id);

  // --- Queue

  Future<void> saveQueue(List<Episode> episodes);

  Future<List<Episode>> loadQueue();

  // --- Player

  Future<void> savePlayingEpisodeGuid(String guid);

  Future<String?> playingEpisodeGuid();
}
