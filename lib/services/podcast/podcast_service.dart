// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:podcast_search/podcast_search.dart' as pcast;
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/repository/episode_event.dart';
import 'package:seasoning/repository/podcast_event.dart';

part 'podcast_genres.dart';

abstract class PodcastService {
  static const itunesGenres = _itunesGenres;
  static const podcastIndexGenres = _podcastIndexGenres;

  Future<void> setup();

  Future<List<PodcastSearchResultItem>> search({
    required String term,
    String? country,
    String? attribute,
    int? limit,
    String? language,
    int version = 0,
    bool explicit = false,
  });

  Future<List<PodcastSearchResultItem>> charts({
    required int size,
    String? genre,
    String? countryCode,
  });

  List<String> genres();

  Future<Podcast?> loadPodcast(
    PodcastMetadata metadata, {
    bool refresh = false,
  });

  Future<Podcast?> loadPodcastByGuid(String guid);

  Future<List<Downloadable>> loadDownloads();

  Future<List<Episode>> loadEpisodesByPodcastGuid(String pguid);

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

  Future<void> toggleSeasonView(Podcast podcast);

  Future<void> saveEpisode(Episode episode);

  Future<Transcript> saveTranscript(Transcript transcript);
}
