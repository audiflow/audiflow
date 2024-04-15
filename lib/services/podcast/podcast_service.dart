// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
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

  Future<List<ITunesSearchItem>> search({
    required String term,
    Country? country,
    Attribute? attribute,
    int limit = 20,
    String? language,
    int version = 0,
    bool explicit = false,
  });

  Future<List<ITunesChartItem>> charts({
    required int size,
    String? genre,
    Country country = Country.none,
  });

  List<String> genres();

  // --- Podcast ---

  // Future<Podcast?> lookupPodcast(String feedUrl);
  //
  // Future<Podcast?> loadPodcast(
  //   Podcast podcast, {
  //   bool refresh = false,
  // });
  //
  Future<Podcast?> loadPodcastById(int id);
  //
  // Future<List<Episode>> loadEpisodesByPodcastId(int pid);

  // --- Podcast subscription ---

  Future<List<Podcast>> subscriptions();

  Future<void> subscribe(Podcast podcast);

  Future<void> unsubscribe(Podcast podcast);

  // --- Episode ---

  Future<Episode?> loadEpisode(int id);

  Future<List<Episode?>> loadEpisodes(Iterable<int> ids);

  Future<void> saveEpisode(Episode episode);

  // --- Episode stats ---

  Future<EpisodeStats?> loadEpisodeStats(Episode episode);

  Future<void> toggleEpisodePlayed(Episode episode);

  // --- Chapter ---

  // Future<List<Chapter>> loadChaptersByUrl(String url);

  // --- Transcript ---

  // Future<Transcript> loadTranscriptByUrl({
  //   required Episode episode,
  //   required TranscriptUrl transcriptUrl,
  // });

  Future<Transcript> saveTranscript(Transcript transcript);

  // --- Play episode ---

  Future<void> handlePlay(Episode episode, {Iterable<Episode>? group});

  Future<void> handlePlayFromQueue(QueueItem item, Episode episode);
}
