// import 'dart:io';
// import 'dart:ui';
//
// import 'package:audiflow/core/exception/app_exception.dart';
// import 'package:audiflow/utils/logger.dart';
// import 'package:audiflow/core/utils.dart';
// import 'package:audiflow/entities/entities.dart';
// import 'package:audiflow/repository/repository_provider.dart';
// import 'package:audiflow/services/audio/audio_playable_checker.dart';
// import 'package:audiflow/features/player/service/audio_player_service.dart';
// import 'package:audiflow/services/connectivity/connectivity.dart';
// import 'package:audiflow/features/browser/common/service/podcast_api.dart';
// import 'package:audiflow/services/queue/queue_manager.dart';
// import 'package:audiflow/features/preference/data/settings_service.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:path/path.dart';
// import 'package:podcast_search/podcast_search.dart' as podcast_search;
// import 'package:riverpod_annotation/riverpod_annotation.dart';
//
// export 'package:audiflow/services/podcast/podcast_service.dart';
//
// part 'podcast_genres.dart';
// part 'podcast_service.g.dart';
//
// @Riverpod(keepAlive: true)
// PodcastService podcastService(PodcastServiceRef ref) => PodcastService(ref);
//
// class PodcastService {
//   PodcastService(this._ref);
//
//   static const itunesGenres = _itunesGenres;
//   static const podcastIndexGenres = _podcastIndexGenres;
//
//   final Ref _ref;
//
//   PodcastApi get _api => _ref.read(podcastApiProvider);
//
//   Repository get _repository => _ref.read(repositoryProvider);
//
//   AppSettings get _appSettings => _ref.read(settingsServiceProvider);
//
//   QueueManager get _queueManager => _ref.read(queueManagerProvider.notifier);
//
//   AudioPlayerService get _audioService =>
//       _ref.read(audioPlayerServiceProvider.notifier);
//
//   late var _categories = <String>[];
//   late var _intlCategories = <String>[];
//   late var _intlCategoriesSorted = <String>[];
//
//   var _initialized = false;
//
//   Future<void> setup(Locale locale) async {
//     if (_initialized) {
//       return;
//     }
//     _initialized = true;
//
//     _setupGenres(locale);
//
//     /// Listen for user changes in search provider. If changed, reload the genre
//     /// list
//     _ref.listen(
//         settingsServiceProvider.select((settings) => settings.searchProvider),
//         (_, next) {
//       _setupGenres(locale);
//     });
//
//     await _resumeEpisode();
//   }
//
//   void _setupGenres(Locale locale) {
//     var categoryList = '';
//
//     /// Fetch the correct categories for the current local and selected
//     /// provider.
//     if (_appSettings.searchProvider == 'itunes') {
//       _categories = PodcastService.itunesGenres;
//       categoryList = Intl.message(
//         'discovery_categories_itunes',
//         locale: locale.languageCode,
//       );
//     } else {
//       _categories = PodcastService.podcastIndexGenres;
//       categoryList = Intl.message(
//         'discovery_categories_pindex',
//         locale: locale.languageCode,
//       );
//     }
//
//     _intlCategories = categoryList.split(',');
//     _intlCategoriesSorted = categoryList.split(',');
//     _intlCategoriesSorted
//         .sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
//   }
//
//   Future<void> _resumeEpisode() async {
//     final eid = await _repository.playingEpisodeId();
//     if (eid != null) {
//       final values = await Future.wait([
//         _repository.findEpisode(eid),
//         _repository.findEpisodeStats(eid),
//       ]);
//       final episode = values[0] as Episode?;
//       final stats = values[1] as EpisodeStats?;
//       if (episode != null) {
//         await _audioService.loadEpisode(
//           episode: episode,
//           position: stats?.position ?? Duration.zero,
//           autoPlay: false,
//         );
//       }
//     }
//   }
//
//   // --- API services ---
//
//   Future<List<ITunesSearchItem>> search({
//     required String term,
//     Country? country,
//     Attribute? attribute,
//     int limit = 20,
//     String? language,
//     int version = 0,
//     bool explicit = false,
//   }) async {
//     if (!await hasConnectivity()) {
//       logger.d('no network');
//       throw NoConnectivityException();
//     }
//
//     return _api.search(
//       term,
//       country: country,
//       attribute: attribute,
//       limit: limit,
//       language: language,
//       explicit: explicit,
//     );
//   }
//
//   Future<List<ITunesChartItem>> charts({
//     int size = 20,
//     String? genre,
//     Country country = Country.none,
//   }) async {
//     if (!await hasConnectivity()) {
//       logger.d('no network');
//       throw NoConnectivityException();
//     }
//
//     return _api.charts(
//       size: size,
//       genre: _decodeGenre(genre),
//       country: country,
//     );
//   }
//
//   List<String> genres() {
//     return _intlCategoriesSorted;
//   }
//
//   Future<String?> findOrFetchFeedUrlBy({required int collectionId}) async {
//     final feedUrl = await _repository.findFeedUrl(collectionId: collectionId);
//     if (feedUrl != null) {
//       return feedUrl;
//     }
//
//     final itunesSearchItem = await _api.lookup(collectionId: collectionId);
//     if (itunesSearchItem != null) {
//       await _repository.saveFeedUrl(
//         collectionId: collectionId,
//         feedUrl: itunesSearchItem.feedUrl,
//       );
//       return itunesSearchItem.feedUrl;
//     }
//     return null;
//   }
//
//   // --- Podcast ---
//
//   Future<Podcast?> findPodcastBy({
//     String? feedUrl,
//     int? collectionId,
//   }) async {
//     return _repository.findPodcastBy(
//       feedUrl: feedUrl,
//       collectionId: collectionId,
//     );
//   }
//
//   Future<int?> findOrFetchCollectionIdBy({required String feedUrl}) async {
//     return _repository.findCollectionId(feedUrl: feedUrl);
//   }
//
//   // @override
//   // Future<Podcast?> lookupPodcast(String feedUrl) async {
//   //   return _lookupPodcast(feedUrl: feedUrl);
//   // }
//   //
//   // /// Loads the specified [Podcast]. If the Podcast instance has an ID we'll
//   // /// fetch it from storage. If not, we'll check the cache to see if we have
//   // /// seen it recently and return that if available. If not, we'll make a call
//   // /// to load it from the network.
//   // @override
//   // Future<Podcast?> loadPodcast(
//   //   Podcast podcast, {
//   //   bool refresh = false,
//   // }) async {
//   //   if (refresh) {
//   //     return _lookupPodcast(podcast: podcast);
//   //   }
//   //   return await loadPodcastById(podcast.id) ??
//   //       await _lookupPodcast(metadata: metadata);
//   // }
//   //
//   Future<Podcast?> loadPodcastById(int id) async {
//     return _repository.findPodcast(id);
//   }
//
//   Future<Podcast?> _lookupPodcast({
//     required String feedUrl,
//   }) async {
//     assert(feedUrl.isNotEmpty);
//     logger.d('lookup podcast $feedUrl');
//
//     if (!await hasConnectivity()) {
//       logger.d('no network');
//       throw NoConnectivityException();
//     }
//
//     // final (podcast, itemParser) = await _lookupPodcastBy(feedUrl: feedUrl);
//     //   final podcast = Podcast.fromSearch(feedPodcast, metadata);
//     //
//     //   final saved = await _repository.findPodcast(podcast.guid);
//     //   final updateParam = PodcastStatsUpdateParam(
//     //     guid: podcast.guid,
//     //     lastCheckedAt: DateTime.now(),
//     //   );
//     //   if (saved != podcast) {
//     //     await _repository.savePodcast(podcast, param: updateParam);
//     //   } else {
//     //     await _repository.updatePodcastStats(updateParam);
//     //   }
//     //   await _repository.saveEpisodes(podcast.episodes);
//     //
//     //   return podcast;
//     // }
//     //
//     // @override
//     // Future<List<Chapter>> loadChaptersByUrl(String url) async {
//     //   final c = await _loadChaptersByUrl(url);
//     //   final chapters = <Chapter>[];
//     //
//     //   if (c != null) {
//     //     for (final chapter in c.chapters) {
//     //       chapters.add(
//     //         Chapter(
//     //           title: chapter.title,
//     //           url: chapter.url,
//     //           imageUrl: chapter.imageUrl,
//     //           startTime: chapter.startTime,
//     //           endTime: chapter.endTime,
//     //           toc: chapter.toc,
//     //         ),
//     //       );
//     //     }
//     //   }
//     //
//     //   return chapters;
//     // }
//     //
//     // /// This method will load either of the supported transcript types. Currently,
//     // /// we do not support word level highlighting of transcripts, therefore this
//     // /// routine will also group transcript lines together by speaker and/or
//     // /// timeframe.
//     // @override
//     // Future<Transcript> loadTranscriptByUrl({
//     //   required Episode episode,
//     //   required TranscriptUrl transcriptUrl,
//     // }) async {
//     //   final subtitles = <Subtitle>[];
//     //   final result = await _loadTranscriptByUrl(transcriptUrl);
//     //   if (result == null) {
//     //     return Transcript(
//     //       pid: episode.pid,
//     //       guid: episode.guid,
//     //     );
//     //   }
//     //
//     //   const threshold = Duration(seconds: 5);
//     //   Subtitle? groupSubtitle;
//     //
//     //   for (var index = 0; index < result.subtitles.length; index++) {
//     //     final subtitle = result.subtitles[index];
//     //     var completeGroup = true;
//     //     var data = subtitle.data;
//     //
//     //     if (groupSubtitle != null) {
//     //       if (transcriptUrl.type == TranscriptFormat.json) {
//     //         if (groupSubtitle.speaker == subtitle.speaker &&
//     //             (subtitle.start.compareTo(groupSubtitle.start + threshold) < 0 ||
//     //                 subtitle.data.length == 1)) {
//     //           /// We need to handle transcripts that have spaces between
//     //           /// sentences, and those which do not.
//     //           if (groupSubtitle.data != null &&
//     //               (groupSubtitle.data!.endsWith(' ') ||
//     //                   subtitle.data.startsWith(' ') ||
//     //                   subtitle.data.length == 1)) {
//     //             data = '${groupSubtitle.data}${subtitle.data}';
//     //           } else {
//     //             data = '${groupSubtitle.data} ${subtitle.data.trim()}';
//     //           }
//     //           completeGroup = false;
//     //         }
//     //       } else {
//     //         if (groupSubtitle.start == subtitle.start) {
//     //           if (groupSubtitle.data != null &&
//     //               (groupSubtitle.data!.endsWith(' ') ||
//     //                   subtitle.data.startsWith(' ') ||
//     //                   subtitle.data.length == 1)) {
//     //             data = '${groupSubtitle.data}${subtitle.data}';
//     //           } else {
//     //             data = '${groupSubtitle.data} ${subtitle.data.trim()}';
//     //           }
//     //           completeGroup = false;
//     //         }
//     //       }
//     //     } else {
//     //       completeGroup = false;
//     //       groupSubtitle = Subtitle(
//     //         data: subtitle.data,
//     //         speaker: subtitle.speaker,
//     //         startMS: subtitle.start.inMilliseconds,
//     //         endMS: subtitle.end.inMilliseconds,
//     //         index: subtitle.index,
//     //       );
//     //     }
//     //
//     //     /// If we have a complete group, or we're the very last subtitle -
//     //     /// add it.
//     //     if (completeGroup || index == result.subtitles.length - 1) {
//     //       groupSubtitle =
//     //           groupSubtitle.copyWith(data: groupSubtitle.data?.trim());
//     //
//     //       subtitles.add(groupSubtitle);
//     //
//     //       groupSubtitle = Subtitle(
//     //         data: subtitle.data,
//     //         speaker: subtitle.speaker,
//     //         start: subtitle.start,
//     //         end: subtitle.end,
//     //         index: subtitle.index,
//     //       );
//     //     } else {
//     //       groupSubtitle = Subtitle(
//     //         data: data,
//     //         speaker: subtitle.speaker,
//     //         start: groupSubtitle.start,
//     //         end: subtitle.end,
//     //         index: groupSubtitle.index,
//     //       );
//     //     }
//     //   }
//     //
//     //   return Transcript(
//     //     pguid: episode.pguid,
//     //     guid: episode.guid,
//     //     subtitles: subtitles,
//     //   );
//   }
//
//   // --- PodcastStats ---
//
//   Future<PodcastStats?> findPodcastStatsBy({
//     int? pid,
//     String? feedUrl,
//   }) async {
//     assert(pid != null || feedUrl != null);
//     final id = pid ?? Podcast.pidFrom(feedUrl!);
//     return _repository.findPodcastStats(id);
//   }
//
//   Future<List<Episode>> loadEpisodesByPodcastId(int pid) async {
//     return _repository.findEpisodesByPodcastId(pid);
//   }
//
//   Future<Episode?> loadEpisode(int id) async {
//     return _repository.findEpisode(id);
//   }
//
//   Future<List<Episode?>> loadEpisodes(Iterable<int> ids) async {
//     return _repository.findEpisodes(ids);
//   }
//
//   Future<EpisodeStats?> loadEpisodeStats(Episode episode) async {
//     return _repository.findEpisodeStats(episode.id);
//   }
//
//   Future<void> toggleEpisodePlayed(Episode episode) async {
//     // episode.played = !episode.played;
//     // episode.position = 0;
//     //
//     // await repository.saveEpisode(episode);
//   }
//
//   Future<List<Podcast>> subscriptions() async {
//     return _repository.subscriptions();
//   }
//
//   Future<void> subscribe(Podcast podcast) async {
//     await _repository.subscribePodcast(podcast);
//   }
//
//   Future<void> unsubscribe(Podcast podcast) async {
//     if (await hasStoragePermission(_appSettings)) {
//       final filename = join(
//         await getStorageDirectory(_appSettings),
//         safeFile(podcast.title),
//       );
//
//       final d = Directory.fromUri(Uri.file(filename));
//
//       if (d.existsSync()) {
//         await d.delete(recursive: true);
//       }
//     }
//
//     final stats = await _repository.findPodcastStats(podcast.id);
//     if (stats != null) {
//       return _repository.unsubscribePodcast(podcast);
//     }
//   }
//
//   Future<void> saveEpisode(Episode episode) async {
//     await _repository.saveEpisode(episode);
//   }
//
//   // --- Transcript ---
//
//   Future<Transcript> saveTranscript(Transcript transcript) async {
//     return _repository.saveTranscript(transcript);
//   }
//
//   // --- Play episode ---
//
//   Future<void> handlePlay(
//     Episode episode, {
//     Iterable<Episode>? group,
//   }) async {
//     final checker = _ref.read(audioPlayableCheckerProvider);
//     if (!await checker.canStartPlayback(episode)) {
//       return;
//     }
//
//     final playerState = _ref.read(audioPlayerServiceProvider);
//     if (playerState != null && playerState.episode.guid == episode.guid) {
//       if (playerState.phase == PlayerPhase.play) {
//         await _audioService.pause();
//       } else {
//         await _audioService.play();
//       }
//     } else {
//       await _playEpisode(episode, group: group);
//     }
//   }
//
//   Future<void> handlePlayFromQueue(QueueItem item, Episode episode) async {
//     final checker = _ref.read(audioPlayableCheckerProvider);
//     if (!await checker.canStartPlayback(episode)) {
//       return;
//     }
//
//     await _queueManager.removeFromTop(to: item);
//     await _playEpisode(episode);
//   }
//
//   Future<void> _playEpisode(
//     Episode episode, {
//     Iterable<Episode>? group,
//   }) async {
//     if (group != null) {
//       final list = group.toList();
//       final i = list.indexWhere((e) => e.guid == episode.guid);
//       if (0 <= i) {
//         await _addToAdhocQueue(list.sublist(i));
//       }
//     }
//
//     final stats = await _repository.findEpisodeStats(episode.id);
//     final position = stats?.position ?? Duration.zero;
//     await _audioService.loadEpisode(
//       episode: episode,
//       position: position,
//       autoPlay: true,
//     );
//   }
//
//   Future<void> _addToAdhocQueue(Iterable<Episode> episodes) async {
//     final items = episodes.map((e) => QueueItem.adhoc(pid: e.pid, eid: e.id));
//     await _queueManager.replaceAll(items);
//     await Future.wait(
//       episodes.map(
//         (e) => _repository.updateEpisodeStats(
//           EpisodeStatsUpdateParam(
//             pid: e.pid,
//             id: e.id,
//             inQueue: true,
//           ),
//         ),
//       ),
//     );
//   }
//
//   static Future<podcast_search.Chapters?> _loadChaptersByUrlCompute(
//     _FeedComputer c,
//   ) async {
//     podcast_search.Chapters? result;
//
//     try {
//       result = await c.api.loadChapters(c.url);
//       // ignore: avoid_catches_without_on_clauses
//     } catch (e) {
//       logger
//         ..w('Failed to download chapters')
//         ..w(e);
//     }
//
//     return result;
//   }
//
//   Future<podcast_search.Transcript?> _loadTranscriptByUrl(
//     TranscriptUrl transcriptUrl,
//   ) {
//     return compute<_TranscriptComputer, podcast_search.Transcript?>(
//       _loadTranscriptByUrlCompute,
//       _TranscriptComputer(api: _api, transcriptUrl: transcriptUrl),
//     );
//   }
//
//   static Future<podcast_search.Transcript?> _loadTranscriptByUrlCompute(
//     _TranscriptComputer c,
//   ) async {
//     podcast_search.Transcript? result;
//
//     try {
//       result = await c.api.loadTranscript(c.transcriptUrl);
//       // ignore: avoid_catches_without_on_clauses
//     } catch (e) {
//       logger
//         ..w('Failed to download transcript')
//         ..w(e);
//     }
//
//     return result;
//   }
//
//   /// The service providers expect the genre to be passed in English.
//   /// This function takes the selected genre and returns the English version.
//   String _decodeGenre(String? genre) {
//     final index = _intlCategories.indexOf(genre ?? '');
//     return index < 0
//         ? ''
//         : _categories[index] == '<All>'
//             ? ''
//             : _categories[index];
//   }
// }
//
// class _FeedComputer {
//   _FeedComputer({
//     required this.api,
//     required this.url,
//     required this.collectionId,
//   });
//
//   final PodcastApi api;
//   final String url;
//   final int collectionId;
// }
//
// class _TranscriptComputer {
//   _TranscriptComputer({required this.api, required this.transcriptUrl});
//
//   final PodcastApi api;
//   final TranscriptUrl transcriptUrl;
// }
//
// // String? _extractSeasonTitle(Episode episode) {
// //   if (episode.season < 1) {
// //     return null;
// //   }
// //
// //   switch (episode.pguid) {
// //     case 'https://anchor.fm/s/8c2088c/podcast/rss': // COTEN
// //       final m = RegExp(r'【COTEN RADIO\S*\s+(.*?)\d+】')
// //           .firstMatch(episode.title ?? '');
// //       return m?.group(1)!.replaceFirst(RegExp(r'\s+編$'), '編');
// //     default:
// //       return episode.title;
// //   }
// // }
