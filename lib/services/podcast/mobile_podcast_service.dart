// Copyright 2019 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:podcast_search/podcast_search.dart' as podcast_search;
import 'package:seasoning/api/podcast/podcast_api_provider.dart';
import 'package:seasoning/core/utils.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/l10n/messages_all.dart';
import 'package:seasoning/repository/repository_provider.dart';
import 'package:seasoning/services/audio/audio_player_service.dart';
import 'package:seasoning/services/podcast/podcast_service.dart';
import 'package:seasoning/services/queue/queue_manager.dart';
import 'package:seasoning/services/settings/settings_service.dart';

class MobilePodcastService implements PodcastService {
  MobilePodcastService(this._ref);

  final Ref _ref;

  PodcastApi get _api => _ref.read(podcastApiProvider);

  Repository get _repository => _ref.read(repositoryProvider);

  AppSettings get _appSettings => _ref.read(settingsServiceProvider);

  QueueManager get _queueManager => _ref.read(queueManagerProvider.notifier);

  AudioPlayerService get _audioService =>
      _ref.read(audioPlayerServiceProvider.notifier);

  final _log = Logger('MobilePodcastService');
  late var _categories = <String>[];
  late var _intlCategories = <String>[];
  late var _intlCategoriesSorted = <String>[];

  var _initialized = false;

  @override
  Future<void> setup() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

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
    _ref.listen(
        settingsServiceProvider.select((settings) => settings.searchProvider),
        (_, next) {
      _setupGenres(currentLocale);
    });
  }

  void _setupGenres(String locale) {
    var categoryList = '';

    /// Fetch the correct categories for the current local and selected
    /// provider.
    if (_appSettings.searchProvider == 'itunes') {
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
  Future<List<PodcastSearchResultItem>> search({
    required String term,
    String? country,
    String? attribute,
    int? limit,
    String? language,
    int version = 0,
    bool explicit = false,
  }) async {
    final result = await _api.search(
      term,
      country: country,
      attribute: attribute,
      limit: limit,
      language: language,
      explicit: explicit,
      searchProvider: _appSettings.searchProvider,
    );
    if (!result.successful) {
      throw Exception(result.lastError);
    }

    final items =
        result.items.map(PodcastSearchResultItem.fromSearchResultItem);
    await _repository.savePodcastPreview(items);
    return items.toList();
  }

  @override
  Future<List<PodcastSearchResultItem>> charts({
    int size = 20,
    String? genre,
    String? countryCode = '',
  }) async {
    final result = await _api.charts(
      size: size,
      searchProvider: _appSettings.searchProvider,
      genre: _decodeGenre(genre),
      countryCode: countryCode,
    );
    if (!result.successful) {
      throw Exception(result.lastError);
    }
    final items =
        result.items.map(PodcastSearchResultItem.fromSearchResultItem);
    return _repository.populatePodcastFeedUrl(items);
  }

  @override
  List<String> genres() {
    return _intlCategoriesSorted;
  }

  @override
  Future<PodcastPreview?> loadPodcastPreview(String guid) async {
    return _repository.findPodcastPreview(guid);
  }

  /// Loads the specified [Podcast]. If the Podcast instance has an ID we'll
  /// fetch it from storage. If not, we'll check the cache to see if we have
  /// seen it recently and return that if available. If not, we'll make a call
  /// to load it from the network.
  @override
  Future<Podcast?> loadPodcast(
    PodcastMetadata metadata, {
    bool refresh = false,
  }) async {
    if (refresh) {
      return _reloadPodcast(metadata);
    }
    return await loadPodcastByGuid(metadata.guid) ??
        await _reloadPodcast(metadata);
  }

  @override
  Future<Podcast?> loadPodcastByGuid(String guid) async {
    return _repository.findPodcast(guid);
  }

  Future<Podcast?> _reloadPodcast(PodcastMetadata metadata) async {
    _log.fine('Reloading podcast ${metadata.title}');

    var feedUrl = metadata.feedUrl ?? '';
    if (feedUrl.isEmpty) {
      feedUrl = (await _repository.findFeedUrl(metadata.guid)) ?? '';
    }
    if (feedUrl.isEmpty) {
      final newMetadata =
          await _lookupPodcastMetadata(collectionId: metadata.collectionId);
      if (newMetadata?.feedUrl == null) {
        return null;
      }
      feedUrl = newMetadata!.feedUrl!;
      await _repository.savePodcastPreview([newMetadata]);
    }

    final feedPodcast = await _lookupPodcast(url: feedUrl);
    final podcast = Podcast.fromSearch(feedPodcast, metadata);

    final saved = await _repository.findPodcast(podcast.guid);
    if (saved != null && saved != podcast) {
      await _repository.savePodcast(podcast);
    }

    return podcast;
  }

  @override
  Future<List<Chapter>> loadChaptersByUrl(String url) async {
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
    return _repository.findDownloads();
  }

  @override
  Future<List<Episode>> loadEpisodesByPodcastGuid(String pguid) async {
    return _repository.findEpisodesByPodcastGuid(pguid);
  }

  @override
  Future<Episode?> loadEpisode(String guid) async {
    return _repository.findEpisode(guid);
  }

  @override
  Future<List<Episode?>> loadEpisodes(Iterable<String> guids) async {
    return _repository.findEpisodes(guids);
  }

  @override
  Future<EpisodeStats?> loadEpisodeStats(Episode episode) async {
    return _repository.findEpisodeStats(episode.guid);
  }

  @override
  Future<void> deleteDownload(Episode episode) async {
    final download = await _repository.findDownload(episode.guid);
    if (download == null) {
      return;
    }

    // If this episode is currently downloading, cancel the download first.
    if (download.state == DownloadState.downloaded) {
      if (_appSettings.markDeletedEpisodesAsPlayed) {
        // episode.played = true;
      }
    } else if (download.state == DownloadState.downloading &&
        download.percentage < 100) {
      await FlutterDownloader.cancel(taskId: download.taskId);
    }

    await _repository.deleteDownload(download);

    if (await hasStoragePermission(_appSettings)) {
      final f =
          File.fromUri(Uri.file(await resolvePath(_appSettings, download)));
      if (f.existsSync()) {
        _log.fine('Deleting file ${f.path}');
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
  Future<List<(PodcastMetadata, PodcastStats)>> subscriptions() async {
    return _repository.subscriptions();
  }

  @override
  Future<void> subscribe(Podcast podcast) async {
    await _repository.subscribePodcast(podcast);
  }

  @override
  Future<void> unsubscribe(Podcast podcast) async {
    if (await hasStoragePermission(_appSettings)) {
      final filename = join(
        await getStorageDirectory(_appSettings),
        safeFile(podcast.title),
      );

      final d = Directory.fromUri(Uri.file(filename));

      if (d.existsSync()) {
        await d.delete(recursive: true);
      }
    }

    final stats = await _repository.findPodcastStats(podcast.guid);
    if (stats != null) {
      return _repository.unsubscribePodcast(podcast);
    }
  }

  @override
  Future<void> saveEpisode(Episode episode) async {
    await _repository.saveEpisode(episode);
  }

  @override
  Future<Transcript> saveTranscript(Transcript transcript) async {
    return _repository.saveTranscript(transcript);
  }

  @override
  Future<void> togglePlayState(
    Episode episode, {
    Iterable<Episode>? group,
  }) async {
    final playerState = _ref.read(audioPlayerServiceProvider);
    if (playerState != null && playerState.episode.guid == episode.guid) {
      if (playerState.phase == PlayerPhase.play) {
        await _audioService.pause();
      } else {
        await _audioService.play();
      }
    } else {
      await _playEpisode(episode, group: group);
    }
  }

  Future<void> _playEpisode(
    Episode episode, {
    Iterable<Episode>? group,
  }) async {
    if (group != null) {
      final list = group.toList();
      final i = list.indexWhere((e) => e.guid == episode.guid);
      if (0 <= i) {
        await _addToAdhocQueue(list.sublist(i));
      }
    }

    final stats = await _repository.findEpisodeStats(episode.guid);
    final position = stats?.position ?? Duration.zero;
    await _audioService.playEpisode(episode: episode, position: position);
  }

  Future<void> _addToAdhocQueue(Iterable<Episode> episodes) async {
    await _queueManager.replaceAllAdHoc(episodes);
    await Future.wait(
      episodes.map(
        (e) => _repository.updateEpisodeStats(
          EpisodeStatsUpdateParam(guid: e.guid, inQueue: true),
        ),
      ),
    );
  }

  Future<PodcastSearchResultItem?> _lookupPodcastMetadata({
    required int collectionId,
  }) async {
    final item = await _api.lookup(collectionId: collectionId);
    return item == null
        ? null
        : PodcastSearchResultItem.fromSearchResultItem(item);
  }

  Future<podcast_search.Podcast> _lookupPodcast({
    required String url,
  }) async {
    // If we didn't get a cache hit load the podcast feed.
    var tries = 2;
    while (0 < tries--) {
      try {
        _log.fine('Loading podcast from feed $url');
        return _loadPodcastFeed(url: url);
      } on Exception {
        if (tries <= 0 || !url.startsWith('https')) {
          rethrow;
        }
        // Try the http only version - flesh out to setting later on
        _log.fine(
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
      _FeedComputer(api: _api, url: url),
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
      _TranscriptComputer(api: _api, transcriptUrl: transcriptUrl),
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
      _FeedComputer(api: _api, url: url),
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
    final index = _intlCategories.indexOf(genre ?? '');
    return index < 0
        ? ''
        : _categories[index] == '<All>'
            ? ''
            : _categories[index];
  }
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
