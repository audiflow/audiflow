// Copyright 2019 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';
import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:podcast_search/podcast_search.dart' as podcast_search;
import 'package:seasoning/api/podcast/podcast_api.dart';
import 'package:seasoning/core/utils.dart';
import 'package:seasoning/entities/chapter.dart';
import 'package:seasoning/entities/downloadable.dart';
import 'package:seasoning/entities/episode.dart';
import 'package:seasoning/entities/podcast.dart';
import 'package:seasoning/entities/transcript.dart';
import 'package:seasoning/events/episode_event.dart';
import 'package:seasoning/l10n/messages_all.dart';
import 'package:seasoning/services/podcast/podcast_service.dart';

class MobilePodcastService extends PodcastService {
  MobilePodcastService({
    required super.api,
    required super.repository,
    required super.settingsService,
  }) {
    _init();
  }

  final log = Logger('MobilePodcastService');
  final _cache =
      _PodcastCache(maxItems: 10, expiration: const Duration(minutes: 30));
  var _categories = <String>[];
  var _intlCategories = <String?>[];
  var _intlCategoriesSorted = <String>[];

  Future<void> _init() async {
    final systemLocales = PlatformDispatcher.instance.locales;

    var currentLocale = Platform.localeName;
    // Attempt to get current locale
    var supportedLocale = await initializeMessages(Platform.localeName);

    // If we do not support the default, try all supported locales
    if (!supportedLocale) {
      for (final l in systemLocales) {
        supportedLocale =
            await initializeMessages('${l.languageCode}_${l.countryCode}');
        if (supportedLocale) {
          currentLocale = '${l.languageCode}_${l.countryCode}';
          break;
        }
      }

      if (!supportedLocale) {
        // We give up! Default to English
        currentLocale = 'en';
        supportedLocale = await initializeMessages(currentLocale);
      }
    }

    _setupGenres(currentLocale);

    /// Listen for user changes in search provider. If changed, reload the genre
    /// list
    settingsService.settingsListener
        .where((event) => event == 'search')
        .listen((event) {
      _setupGenres(currentLocale);
    });
  }

  void _setupGenres(String locale) {
    var categoryList = '';

    /// Fetch the correct categories for the current local and selected
    /// provider.
    if (settingsService.searchProvider == 'itunes') {
      _categories = PodcastService.itunesGenres;
      categoryList =
          Intl.message('discovery_categories_itunes', locale: locale);
    } else {
      _categories = PodcastService.podcastIndexGenres;
      categoryList =
          Intl.message('discovery_categories_pindex', locale: locale);
    }

    _intlCategories = categoryList.split(',');
    _intlCategoriesSorted = categoryList.split(',');
    _intlCategoriesSorted
        .sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  @override
  Future<podcast_search.SearchResult> search({
    required String term,
    String? country,
    String? attribute,
    int? limit,
    String? language,
    int version = 0,
    bool explicit = false,
  }) {
    return api.search(
      term,
      country: country,
      attribute: attribute,
      limit: limit,
      language: language,
      explicit: explicit,
      searchProvider: settingsService.searchProvider,
    );
  }

  @override
  Future<podcast_search.SearchResult> charts({
    int size = 20,
    String? genre,
    String? countryCode = '',
  }) {
    final providerGenre = _decodeGenre(genre);

    return api.charts(
      size: size,
      searchProvider: settingsService.searchProvider,
      genre: providerGenre,
      countryCode: countryCode,
    );
  }

  @override
  List<String> genres() {
    return _intlCategoriesSorted;
  }

  /// Loads the specified [Podcast]. If the Podcast instance has an ID we'll
  /// fetch it from storage. If not, we'll check the cache to see if we have
  /// seen it recently and return that if available. If not, we'll make a call
  /// to load it from the network.
  @override
  Future<Podcast?> loadPodcast({
    required Podcast podcast,
    bool highlightNewEpisodes = false,
    bool refresh = false,
  }) async {
    log.fine('loadPodcast. ID ${podcast.id} (refresh $refresh)');

    return refresh
        ? loadPodcastByUrl(url: podcast.url, ignoreCache: true)
        : podcast.id != null
            ? loadPodcastById(id: podcast.id ?? 0)
            : loadPodcastByGuid(guid: podcast.guid);
  }

  @override
  Future<Podcast?> loadPodcastByUrl({
    required String url,
    bool highlightNewEpisodes = false,
    bool ignoreCache = false,
  }) async {
    final feedPodcast =
        await _lookupPodcast(url: url, ignoreCache: ignoreCache);
    var podcast = Podcast.fromSearch(feedPodcast);

    // We could be subscribing this podcast already. Let's check.
    final saved = await repository.findPodcastByGuid(podcast.guid);
    if (saved != null) {
      podcast = podcast.copyWith(id: saved.id);
    }

    final existingEpisodes = await repository.findEpisodesByPodcastGuid(url);
    final episodes = feedPodcast.episodes
        .map((e) => Episode.fromSearch(e, podcast))
        .map((episode) {
      final existingEpisode =
          existingEpisodes.firstWhereOrNull((ep) => ep.guid == episode.guid);
      if (existingEpisode != null) {
        existingEpisodes.remove(existingEpisode);

        return existingEpisode.copyWith(
          podcast: episode.title,
          title: episode.title,
          description: episode.description,
          content: episode.content,
          author: episode.author,
          season: episode.season,
          episode: episode.episode,
          contentUrl: episode.contentUrl,
          link: episode.link,
          imageUrl: episode.imageUrl,
          thumbImageUrl: episode.thumbImageUrl,
          duration: 0 < episode.duration
              ? episode.duration
              : existingEpisode.duration,
          publicationDate: episode.publicationDate,
          chaptersUrl: episode.chaptersUrl,
          transcriptUrls: episode.transcriptUrls,
          persons: episode.persons,
        );
      }

      return episode;
    }).toList();

    final downloads = await repository.findDownloadsByPodcastGuid(podcast.guid);

    // Add any downloaded episodes that are no longer in the feed - they
    // may have expired but we still want them.
    final expired = <Episode>[];
    for (final existingEpisode in existingEpisodes) {
      final episode =
          episodes.firstWhereOrNull((e) => e.guid == existingEpisode.guid);
      if (episode == null) {
        final download =
            downloads.firstWhereOrNull((d) => d.guid == existingEpisode.guid);
        if (download?.downloaded == true) {
          episodes.add(existingEpisode);
        } else {
          expired.add(existingEpisode);
        }
      }
    }
    episodes.sort((a, b) => b.publicationDate!.compareTo(a.publicationDate!));

    if (saved != null && expired.isNotEmpty) {
      await repository.deleteEpisodes(expired);
    }
    await repository.saveEpisodes(episodes);
    return repository.savePodcast(podcast);
  }

  @override
  Future<Podcast?> loadPodcastById({required int id}) async {
    return repository.findPodcastById(id);
  }

  @override
  Future<Podcast?> loadPodcastByGuid({required String guid}) async {
    return repository.findPodcastByGuid(guid);
  }

  @override
  Future<List<Chapter>> loadChaptersByUrl({required String url}) async {
    final c = await _loadChaptersByUrl(url);
    final chapters = <Chapter>[];

    if (c != null) {
      for (final chapter in c.chapters) {
        chapters.add(
          Chapter(
            title: chapter.title,
            url: chapter.url,
            imageUrl: chapter.imageUrl,
            startTime: chapter.startTime,
            endTime: chapter.endTime,
            toc: chapter.toc,
          ),
        );
      }
    }

    return chapters;
  }

  /// This method will load either of the supported transcript types. Currently,
  /// we do not support word level highlighting of transcripts, therefore this
  /// routine will also group transcript lines together by speaker and/or
  /// timeframe.
  @override
  Future<Transcript> loadTranscriptByUrl({
    required Episode episode,
    required TranscriptUrl transcriptUrl,
  }) async {
    final subtitles = <Subtitle>[];
    final result = await _loadTranscriptByUrl(transcriptUrl);
    if (result == null) {
      return Transcript(
        pguid: episode.pguid,
        guid: episode.guid,
        subtitles: [],
      );
    }

    const threshold = Duration(seconds: 5);
    Subtitle? groupSubtitle;

    for (var index = 0; index < result.subtitles.length; index++) {
      final subtitle = result.subtitles[index];
      var completeGroup = true;
      var data = subtitle.data;

      if (groupSubtitle != null) {
        if (transcriptUrl.type == TranscriptFormat.json) {
          if (groupSubtitle.speaker == subtitle.speaker &&
              (subtitle.start.compareTo(groupSubtitle.start + threshold) < 0 ||
                  subtitle.data.length == 1)) {
            /// We need to handle transcripts that have spaces between
            /// sentences, and those which do not.
            if (groupSubtitle.data != null &&
                (groupSubtitle.data!.endsWith(' ') ||
                    subtitle.data.startsWith(' ') ||
                    subtitle.data.length == 1)) {
              data = '${groupSubtitle.data}${subtitle.data}';
            } else {
              data = '${groupSubtitle.data} ${subtitle.data.trim()}';
            }
            completeGroup = false;
          }
        } else {
          if (groupSubtitle.start == subtitle.start) {
            if (groupSubtitle.data != null &&
                (groupSubtitle.data!.endsWith(' ') ||
                    subtitle.data.startsWith(' ') ||
                    subtitle.data.length == 1)) {
              data = '${groupSubtitle.data}${subtitle.data}';
            } else {
              data = '${groupSubtitle.data} ${subtitle.data.trim()}';
            }
            completeGroup = false;
          }
        }
      } else {
        completeGroup = false;
        groupSubtitle = Subtitle(
          data: subtitle.data,
          speaker: subtitle.speaker,
          start: subtitle.start,
          end: subtitle.end,
          index: subtitle.index,
        );
      }

      /// If we have a complete group, or we're the very last subtitle -
      /// add it.
      if (completeGroup || index == result.subtitles.length - 1) {
        groupSubtitle =
            groupSubtitle.copyWith(data: groupSubtitle.data?.trim());

        subtitles.add(groupSubtitle);

        groupSubtitle = Subtitle(
          data: subtitle.data,
          speaker: subtitle.speaker,
          start: subtitle.start,
          end: subtitle.end,
          index: subtitle.index,
        );
      } else {
        groupSubtitle = Subtitle(
          data: data,
          speaker: subtitle.speaker,
          start: groupSubtitle.start,
          end: subtitle.end,
          index: groupSubtitle.index,
        );
      }
    }

    return Transcript(
      pguid: episode.pguid,
      guid: episode.guid,
      subtitles: subtitles,
    );
  }

  @override
  Future<List<Downloadable>> loadDownloads() async {
    return repository.findDownloads();
  }

  @override
  Future<List<Episode>> loadEpisodes() async {
    return repository.findAllEpisodes();
  }

  @override
  Future<void> deleteDownload(Episode episode) async {
    final download = await repository.findDownloadByGuid(episode.guid);
    if (download == null) {
      return;
    }

    // If this episode is currently downloading, cancel the download first.
    if (download.state == DownloadState.downloaded) {
      if (settingsService.markDeletedEpisodesAsPlayed) {
        // episode.played = true;
      }
    } else if (download.state == DownloadState.downloading &&
        download.percentage < 100) {
      await FlutterDownloader.cancel(taskId: download.taskId);
    }

    await repository.deleteDownload(download);

    if (await hasStoragePermission()) {
      final f = File.fromUri(Uri.file(await resolvePath(download)));
      if (f.existsSync()) {
        log.fine('Deleting file ${f.path}');
        await f.delete();
      }
    }

    return;
  }

  @override
  Future<void> toggleEpisodePlayed(Episode episode) async {
    // episode.played = !episode.played;
    // episode.position = 0;
    //
    // await repository.saveEpisode(episode);
  }

  @override
  Future<List<Podcast>> subscriptions() {
    return repository.subscriptions();
  }

  @override
  Future<void> unsubscribe(Podcast podcast) async {
    if (await hasStoragePermission()) {
      final filename =
          join(await getStorageDirectory(), safeFile(podcast.title));

      final d = Directory.fromUri(Uri.file(filename));

      if (d.existsSync()) {
        await d.delete(recursive: true);
      }
    }

    return repository.deletePodcast(podcast);
  }

  @override
  Future<void> toggleSeasonView(Podcast podcast) async {
    // podcast.seasonView = !podcast.seasonView;
    await repository.savePodcast(podcast);
  }

  @override
  Future<Podcast> subscribe(Podcast podcast) async {
    return repository.savePodcast(podcast);
  }

  @override
  Future<Episode> saveEpisode(Episode episode) async {
    return repository.saveEpisode(episode);
  }

  @override
  Future<Transcript> saveTranscript(Transcript transcript) async {
    return repository.saveTranscript(transcript);
  }

  @override
  Future<void> saveQueue(List<Episode> episodes) async {
    await repository.saveQueue(episodes);
  }

  @override
  Future<List<Episode>> loadQueue() async {
    return repository.loadQueue();
  }

  Future<podcast_search.Podcast> _lookupPodcast({
    required String url,
    bool ignoreCache = false,
  }) async {
    podcast_search.Podcast? loadedPodcast;

    if (!ignoreCache) {
      log.fine('Not a refresh so try to fetch from cache');
      loadedPodcast = _cache.item(url);
      if (loadedPodcast != null) {
        return loadedPodcast;
      }
    }

    // If we didn't get a cache hit load the podcast feed.
    var tries = 2;
    while (0 < tries--) {
      try {
        log.fine('Loading podcast from feed $url');
        loadedPodcast = await _loadPodcastFeed(url: url);
        _cache.store(loadedPodcast);
        return loadedPodcast;
      } on Exception {
        if (tries <= 0 || !url.startsWith('https')) {
          rethrow;
        }
        // Try the http only version - flesh out to setting later on
        log.fine(
          'Failed to load podcast. Fallback to http and try again',
        );
        url = url.replaceFirst('https', 'http');
      }
    }

    throw UnimplementedError();
  }

  Future<podcast_search.Chapters?> _loadChaptersByUrl(String url) {
    return compute<_FeedComputer, podcast_search.Chapters?>(
      _loadChaptersByUrlCompute,
      _FeedComputer(api: api, url: url),
    );
  }

  static Future<podcast_search.Chapters?> _loadChaptersByUrlCompute(
    _FeedComputer c,
  ) async {
    podcast_search.Chapters? result;

    try {
      result = await c.api.loadChapters(c.url);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      Logger('MobilePodcastService')
        ..fine('Failed to download chapters')
        ..fine(e);
    }

    return result;
  }

  Future<podcast_search.Transcript?> _loadTranscriptByUrl(
    TranscriptUrl transcriptUrl,
  ) {
    return compute<_TranscriptComputer, podcast_search.Transcript?>(
      _loadTranscriptByUrlCompute,
      _TranscriptComputer(api: api, transcriptUrl: transcriptUrl),
    );
  }

  static Future<podcast_search.Transcript?> _loadTranscriptByUrlCompute(
    _TranscriptComputer c,
  ) async {
    podcast_search.Transcript? result;

    try {
      result = await c.api.loadTranscript(c.transcriptUrl);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      Logger('MobilePodcastService')
        ..fine('Failed to download transcript')
        ..fine(e);
    }

    return result;
  }

  /// Loading and parsing a podcast feed can take several seconds. Larger feeds
  /// can end up blocking the UI thread. We perform our feed load in a
  /// separate isolate so that the UI can continue to present a loading
  /// indicator whilst the data is fetched without locking the UI.
  Future<podcast_search.Podcast> _loadPodcastFeed({required String url}) {
    return compute<_FeedComputer, podcast_search.Podcast>(
      _loadPodcastFeedCompute,
      _FeedComputer(api: api, url: url),
    );
  }

  /// We have to separate the process of calling compute as you cannot use
  /// named parameters with compute. The podcast feed load API uses named
  /// parameters so we need to change it to a single, positional parameter.
  static Future<podcast_search.Podcast> _loadPodcastFeedCompute(
    _FeedComputer c,
  ) {
    return c.api.loadFeed(c.url);
  }

  /// The service providers expect the genre to be passed in English.
  /// This function takes the selected genre and returns the English version.
  String _decodeGenre(String? genre) {
    final index = _intlCategories.indexOf(genre);
    var decodedGenre = '';

    if (index >= 0) {
      decodedGenre = _categories[index];

      if (decodedGenre == '<All>') {
        decodedGenre = '';
      }
    }

    return decodedGenre;
  }

  @override
  Stream<Podcast?>? get podcastListener => repository.podcastListener;

  @override
  Stream<EpisodeEvent>? get episodeListener => repository.episodeListener;
}

/// A simple cache to reduce the number of network calls when loading podcast
/// feeds. We can cache up to [maxItems] items with each item having an
/// expiration time of [expiration]. The cache works as a FIFO queue, so if we
/// attempt to store a new item in the cache and it is full we remove the
/// first (and therefore oldest) item from the cache. Cache misses are returned
/// as null.
class _PodcastCache {
  _PodcastCache({required this.maxItems, required this.expiration})
      : _queue = Queue<_CacheItem>();
  final int maxItems;
  final Duration expiration;
  final Queue<_CacheItem> _queue;

  podcast_search.Podcast? item(String key) {
    final hit = _queue.firstWhereOrNull((_CacheItem i) => i.podcast.url == key);
    podcast_search.Podcast? p;

    if (hit != null) {
      final now = DateTime.now();

      if (now.difference(hit.dateAdded) <= expiration) {
        p = hit.podcast;
      } else {
        _queue.remove(hit);
      }
    }

    return p;
  }

  void store(podcast_search.Podcast podcast) {
    if (_queue.length == maxItems) {
      _queue.removeFirst();
    }

    _queue.addLast(_CacheItem(podcast));
  }
}

/// A simple class that stores an instance of a Podcast and the
/// date and time it was added. This can be used by the cache to
/// keep a small and up-to-date list of searched for Podcasts.
class _CacheItem {
  _CacheItem(this.podcast) : dateAdded = DateTime.now();
  final podcast_search.Podcast podcast;
  final DateTime dateAdded;
}

class _FeedComputer {
  _FeedComputer({required this.api, required this.url});

  final PodcastApi api;
  final String url;
}

class _TranscriptComputer {
  _TranscriptComputer({required this.api, required this.transcriptUrl});

  final PodcastApi api;
  final TranscriptUrl transcriptUrl;
}

// String? _extractSeasonTitle(Episode episode) {
//   if (episode.season < 1) {
//     return null;
//   }
//
//   switch (episode.pguid) {
//     case 'https://anchor.fm/s/8c2088c/podcast/rss': // COTEN
//       final m = RegExp(r'【COTEN RADIO\S*\s+(.*?)\d+】')
//           .firstMatch(episode.title ?? '');
//       return m?.group(1)!.replaceFirst(RegExp(r'\s+編$'), '編');
//     default:
//       return episode.title;
//   }
// }
