// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:podcast_search/podcast_search.dart' as pcast;
import 'package:seasoning/api/podcast/podcast_api.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/events/episode_event.dart';
import 'package:seasoning/repository/repository.dart';
import 'package:seasoning/services/settings/settings_service.dart';

abstract class PodcastService {
  PodcastService({
    required this.api,
    required this.repository,
    required this.settingsService,
  });

  final PodcastApi api;
  final Repository repository;
  final SettingsService settingsService;

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

  Future<Podcast?> loadPodcast({
    required Podcast podcast,
    bool highlightNewEpisodes = false,
    bool refresh = false,
  });

  Future<Podcast?> loadPodcastByUrl({
    required String url,
    bool highlightNewEpisodes = false,
    bool ignoreCache = false,
  });

  Future<Podcast?> loadPodcastById({required int id});

  Future<Podcast?> loadPodcastByGuid({required String guid});

  Future<List<Downloadable>> loadDownloads();

  Future<List<Episode>> loadEpisodes();

  Future<List<Chapter>> loadChaptersByUrl({required String url});

  Future<Transcript> loadTranscriptByUrl({
    required Episode episode,
    required TranscriptUrl transcriptUrl,
  });

  Future<void> deleteDownload(Episode episode);

  Future<void> toggleEpisodePlayed(Episode episode);

  Future<List<Podcast>> subscriptions();

  Future<Podcast> subscribe(Podcast podcast);

  Future<void> unsubscribe(Podcast podcast);

  Future<void> toggleSeasonView(Podcast podcast);

  Future<Episode> saveEpisode(Episode episode);

  Future<Transcript> saveTranscript(Transcript transcript);

  Future<void> saveQueue(List<Episode> episodes);

  Future<List<Episode>> loadQueue();

  /// Event listeners
  Stream<Podcast?>? podcastListener;
  Stream<EpisodeEvent>? episodeListener;
}
