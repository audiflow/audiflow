// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:audiflow/entities/entities.dart';

part 'podcast_genres.dart';

abstract class PodcastService {
  static const itunesGenres = _itunesGenres;
  static const podcastIndexGenres = _podcastIndexGenres;

  Future<void> setup(Locale locale);

  // --- Search and Load ---

  Future<List<PodcastMetadata>> search({
    required String term,
    String? country,
    String? attribute,
    int? limit,
    String? language,
    int version = 0,
    bool explicit = false,
  });

  Future<List<PodcastMetadata>> charts({
    required int size,
    String? genre,
    String? countryCode,
  });

  List<String> genres();

  // --- Podcast ---

  Future<PodcastMetadata?> loadPodcastMetadata(String guid);

  Future<Podcast?> loadPodcast(
    PodcastMetadata metadata, {
    bool refresh = false,
  });

  Future<Podcast?> loadPodcastByGuid(String guid);

  Future<List<Episode>> loadEpisodesByPodcastGuid(String pguid);

  // --- Podcast subscription ---

  Future<List<(PodcastMetadata, PodcastStats)>> subscriptions();

  Future<void> subscribe(Podcast podcast);

  Future<void> unsubscribe(Podcast podcast);

  // --- Episode ---

  Future<Episode?> loadEpisode(String guid);

  Future<List<Episode?>> loadEpisodes(Iterable<String> guids);

  Future<void> saveEpisode(Episode episode);

  // --- Episode stats ---

  Future<EpisodeStats?> loadEpisodeStats(Episode episode);

  Future<void> toggleEpisodePlayed(Episode episode);

  // --- Chapter ---

  Future<List<Chapter>> loadChaptersByUrl(String url);

  // --- Transcript ---

  Future<Transcript> loadTranscriptByUrl({
    required Episode episode,
    required TranscriptUrl transcriptUrl,
  });

  Future<Transcript> saveTranscript(Transcript transcript);

  // --- Download ---

  Future<List<Downloadable>> loadAllDownloads();

  Future<void> deleteDownload(Episode episode);

  Future<void> downloadEpisodes(
    Iterable<Episode> episodes, {
    bool unplayedOnly = false,
  });

  // --- Play episode ---

  Future<void> handlePlay(Episode episode, {Iterable<Episode>? group});

  Future<void> handlePlayFromQueue(QueueItem item, Episode episode);
}
