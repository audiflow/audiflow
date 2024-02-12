// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:seasoning/entities/downloadable.dart';
import 'package:seasoning/entities/episode.dart';
import 'package:seasoning/entities/podcast.dart';
import 'package:seasoning/entities/transcript.dart';
import 'package:seasoning/events/episode_event.dart';

/// An abstract class that represent the actions supported by the chosen
/// database or storage implementation.
abstract class Repository {
  /// General
  Future<void> close();

  /// Podcasts
  Future<Podcast?> findPodcastById(num id);

  Future<Podcast?> findPodcastByGuid(String guid);

  Future<Podcast> savePodcast(Podcast podcast);

  Future<void> deletePodcast(Podcast podcast);

  Future<List<Podcast>> subscriptions();

  /// Episodes
  Future<List<Episode>> findAllEpisodes();

  Future<Episode?> findEpisodeById(int id);

  Future<Episode?> findEpisodeByGuid(String guid);

  Future<List<Episode>> findEpisodesByPodcastGuid(String pguid);

  Future<List<Episode>> saveEpisodes(List<Episode> episodes);

  Future<Episode> saveEpisode(Episode episode);

  Future<void> deleteEpisode(Episode episode);

  Future<void> deleteEpisodes(List<Episode> episodes);

  Future<List<Downloadable>> findDownloadsByPodcastGuid(String pguid);

  Future<List<Downloadable>> findDownloads();

  Future<Downloadable?> findDownloadByGuid(String guid);

  Future<Downloadable?> findDownloadByTaskId(String taskId);

  Future<Downloadable> saveDownload(Downloadable download);

  Future<void> deleteDownload(Downloadable download);

  Future<Transcript?> findTranscriptById(int id);

  Future<Transcript> saveTranscript(Transcript transcript);

  Future<void> deleteTranscriptById(int id);

  Future<void> deleteTranscriptsById(List<int> id);

  /// Queue
  Future<void> saveQueue(List<Episode> episodes);

  Future<List<Episode>> loadQueue();

  /// Event listeners
  Stream<Podcast> get podcastListener;

  Stream<EpisodeEvent> get episodeListener;
}
