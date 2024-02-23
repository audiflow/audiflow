// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:podcast_search/podcast_search.dart' as pcast;
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/repository/episode_event.dart';
import 'package:seasoning/repository/podcast_event.dart';

abstract class PodcastService {
  static const itunesGenres = [
    '<All>',
    'Arts',
    'Business',
    'Comedy',
    'Education',
    'Fiction',
    'Government',
    'Health & Fitness',
    'History',
    'Kids & Family',
    'Leisure',
    'Music',
    'News',
    'Religion & Spirituality',
    'Science',
    'Society & Culture',
    'Sports',
    'TV & Film',
    'Technology',
    'True Crime',
  ];

  static const podcastIndexGenres = <String>[
    '<All>',
    'After-Shows',
    'Alternative',
    'Animals',
    'Animation',
    'Arts',
    'Astronomy',
    'Automotive',
    'Aviation',
    'Baseball',
    'Basketball',
    'Beauty',
    'Books',
    'Buddhism',
    'Business',
    'Careers',
    'Chemistry',
    'Christianity',
    'Climate',
    'Comedy',
    'Commentary',
    'Courses',
    'Crafts',
    'Cricket',
    'Cryptocurrency',
    'Culture',
    'Daily',
    'Design',
    'Documentary',
    'Drama',
    'Earth',
    'Education',
    'Entertainment',
    'Entrepreneurship',
    'Family',
    'Fantasy',
    'Fashion',
    'Fiction',
    'Film',
    'Fitness',
    'Food',
    'Football',
    'Games',
    'Garden',
    'Golf',
    'Government',
    'Health',
    'Hinduism',
    'History',
    'Hobbies',
    'Hockey',
    'Home',
    'How-To',
    'Improv',
    'Interviews',
    'Investing',
    'Islam',
    'Journals',
    'Judaism',
    'Kids',
    'Language',
    'Learning',
    'Leisure',
    'Life',
    'Management',
    'Manga',
    'Marketing',
    'Mathematics',
    'Medicine',
    'Mental',
    'Music',
    'Natural',
    'Nature',
    'News',
    'Non-Profit',
    'Nutrition',
    'Parenting',
    'Performing',
    'Personal',
    'Pets',
    'Philosophy',
    'Physics',
    'Places',
    'Politics',
    'Relationships',
    'Religion',
    'Reviews',
    'Role-Playing',
    'Rugby',
    'Running',
    'Science',
    'Self-Improvement',
    'Sexuality',
    'Soccer',
    'Social',
    'Society',
    'Spirituality',
    'Sports',
    'Stand-Up',
    'Stories',
    'Swimming',
    'TV',
    'Tabletop',
    'Technology',
    'Tennis',
    'Travel',
    'True Crime',
    'Video-Games',
    'Visual',
    'Volleyball',
    'Weather',
    'Wilderness',
    'Wrestling',
  ];

  Future<void> setup();

  Future<pcast.SearchResult> search({
    required String term,
    String? country,
    String? attribute,
    int? limit,
    String? language,
    int version = 0,
    bool explicit = false,
  });

  Future<pcast.SearchResult> charts({
    required int size,
    String? genre,
    String? countryCode,
  });

  List<String> genres();

  Future<Podcast?> loadPodcast(
    PodcastSummary summary, {
    int? id,
    bool refresh = false,
  });

  Future<Podcast?> loadPodcastById(int id);

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

  Future<List<(PodcastStats, PodcastSummary)>> subscriptions();

  Future<PodcastStats> subscribe(Podcast podcast);

  Future<void> unsubscribe(Podcast podcast);

  Future<void> toggleSeasonView(Podcast podcast);

  Future<void> saveEpisode(Episode episode);

  Future<Transcript> saveTranscript(Transcript transcript);

  /// Event listeners
  Stream<PodcastEvent> get podcastStream;

  Stream<EpisodeEvent> get episodeStream;
}
