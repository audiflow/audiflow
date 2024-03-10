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

  Future<PodcastMetadata?> loadPodcastMetadata(String guid);

  Future<Podcast?> loadPodcast(
    PodcastMetadata metadata, {
    bool refresh = false,
  });

  Future<Podcast?> loadPodcastByGuid(String guid);

  Future<List<Downloadable>> loadDownloads();

  Future<List<Episode>> loadEpisodesByPodcastGuid(String pguid);

  Future<Episode?> loadEpisode(String guid);

  Future<List<Episode?>> loadEpisodes(Iterable<String> guids);

  Future<EpisodeStats?> loadEpisodeStats(Episode episode);

  Future<List<Chapter>> loadChaptersByUrl(String url);

  Future<Transcript> loadTranscriptByUrl({
    required Episode episode,
    required TranscriptUrl transcriptUrl,
  });

  Future<void> deleteDownload(Episode episode);

  Future<void> toggleEpisodePlayed(Episode episode);

  Future<List<(PodcastMetadata, PodcastStats)>> subscriptions();

  Future<void> subscribe(Podcast podcast);

  Future<void> unsubscribe(Podcast podcast);

  Future<void> saveEpisode(Episode episode);

  Future<Transcript> saveTranscript(Transcript transcript);

  Future<void> handlePlay(Episode episode, {Iterable<Episode>? group});

  Future<void> handlePlayFromQueue(QueueItem item, Episode episode);
}
