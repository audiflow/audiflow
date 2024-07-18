import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:audiflow/core/api_cache_dir.dart';
import 'package:audiflow/core/logger.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/services/http/cached_http.dart';
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:podcast_feed/parsers/podcast_feed_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:worker_manager/worker_manager.dart';

part 'podcast_feed_loader.freezed.dart';
part 'podcast_feed_loader.g.dart';

@riverpod
class PodcastFeedLoader extends _$PodcastFeedLoader {
  SendPort? _workerPort;

  String get _cacheDir => ref.read(apiCacheDirProvider);

  @override
  PodcastFeedLoaderState build({
    required String feedUrl,
    required int collectionId,
  }) {
    logger.d(() => 'build($feedUrl, $collectionId)');
    _setupWorker();
    return PodcastFeedLoaderState(
      feedUrl: feedUrl,
      collectionId: collectionId,
    );
  }

  Future<void> _setupWorker() async {
    void onWorkerMessage(_Result result) {
      logger.d('received $result');
      switch (result) {
        case _SendPortEvent():
          _workerPort = result.sendPort;
          _loadFeed();
        case _LoadFeedResult():
          state = state.copyWith(
            podcast: result.podcast,
            readingPodcast: false,
          );
          _workerPort!.send(_ReadEpisodesCommand(maxReadCount: 10));
        case _ReadEpisodesResult():
          state = state.copyWith(
            episodes: [...state.episodes, ...result.episodes],
            reachedLastPubDate:
                state.reachedLastPubDate || result.reachedLastPubDate,
            loadedAllEpisodes:
                state.loadedAllEpisodes || result.loadedAllEpisodes,
            readingEpisodes: false,
          );
        case _ErrorResult():
      }
    }

    final cancellable = workerManager.executeGentleWithPort<void, _Result>(
      (sendPort, isCancelled) async {
        logger.d('start worker');
        await _Worker(sendPort, isCancelled).listen();
        logger.d('worker done');
      },
      onMessage: onWorkerMessage,
    );

    ref.onDispose(() {
      logger.d('dispose');
      _workerPort = null;
      cancellable.cancel();
    });
  }

  void _loadFeed() {
    _workerPort?.send(
      _LoadFeedCommand(
        feedUrl: state.feedUrl,
        collectionId: state.collectionId,
        cacheDir: _cacheDir,
      ),
    );
  }

  void readEpisodes({
    int? maxReadCount,
    DateTime? lastPubDate,
  }) {
    if (state.readingEpisodes) {
      logger.d('skip readEpisodes due to readingEpisodes is true');
      return;
    }
    state = state.copyWith(readingEpisodes: true);
    _workerPort?.send(
      _ReadEpisodesCommand(
        maxReadCount: maxReadCount,
        lastPubDate: lastPubDate,
      ),
    );
  }
}

@freezed
class PodcastFeedLoaderState with _$PodcastFeedLoaderState {
  const factory PodcastFeedLoaderState({
    required String feedUrl,
    required int collectionId,
    Podcast? podcast,
    @Default([]) List<Episode> episodes,
    @Default(false) bool reachedLastPubDate,
    @Default(false) bool loadedAllEpisodes,
    @Default(true) bool readingPodcast,
    @Default(false) bool readingEpisodes,
  }) = _PodcastFeedLoaderState;
}

class _Worker {
  _Worker(
    this._uiPort,
    this._isCancelled,
  ) {
    _uiPort.send(_SendPortEvent(_workerPort.sendPort));
  }

  final SendPort _uiPort;
  final ReceivePort _workerPort = ReceivePort();
  final bool Function() _isCancelled;
  final _commandStreamController = StreamController<_Command>();
  final _completer = Completer<void>();
  PodcastFeedParser<Uint8List, Podcast, Episode>? _feedParser;
  Podcast? _podcast;

  void dispose() {
    _commandStreamController.close();
  }

  Future<void> listen() async {
    _listenCommandStream();
    _workerPort
        .listen((event) => _commandStreamController.add(event as _Command));
    return _completer.future;
  }

  void _listenCommandStream() {
    _commandStreamController.stream.flatMap(
      (command) async* {
        logger.d('received command $command');
        switch (command) {
          case _LoadFeedCommand():
            await _handleLoadFeedEvent(
              feedUrl: command.feedUrl,
              collectionId: command.collectionId,
              cacheDir: command.cacheDir,
            );
          case _ReadEpisodesCommand():
            await _handleReadEpisodesEvent(
              maxReadCount: command.maxReadCount,
              lastPubDate: command.lastPubDate,
            );
          case _CancelledCommand():
            _completer.complete();
        }
      },
      maxConcurrent: 1,
    ).drain<void>();
  }

  Future<void> _handleLoadFeedEvent({
    required String feedUrl,
    required int collectionId,
    required String cacheDir,
  }) async {
    final loaded = await _loadFeed(
      feedUrl: feedUrl,
      collectionId: collectionId,
      cacheDir: cacheDir,
    );
    if (!loaded || _isCancelled()) {
      _completer.complete();
      return;
    }

    final sent = await _readPodcast();
    if (!sent || _isCancelled()) {
      _completer.complete();
      return;
    }
  }

  Future<bool> _loadFeed({
    required String feedUrl,
    required int collectionId,
    required String cacheDir,
  }) async {
    for (final url in [
      feedUrl.replaceFirst(RegExp('^http:'), 'https:'),
      feedUrl.replaceFirst(RegExp('^https:'), 'http:'),
    ]) {
      logger.d(() => 'loadFeed $url, collectionId=$collectionId');
      try {
        final http = CachedHttp(cacheDir);
        final rs = await http
            .fetch<ResponseBody>(url, responseType: ResponseType.stream)
            .timeout(const Duration(seconds: 30));
        if (rs == null) {
          logger.d(() => 'rss is null, url=$feedUrl');
          return false;
        }

        _feedParser = PodcastFeedParser(
          rs.stream,
          channelBuilder: (channelValues) => Podcast.fromFeed(
            channelValues,
            collectionId: collectionId,
          ),
          channelItemBuilder: (channelItemValues) {
            if (_podcast == null) {
              throw StateError('cannot build Episode due to podcast is null');
            }
            return Episode.fromChannelItem(_podcast!.id, channelItemValues);
          },
        );
        return true;
      } on DioException catch (err) {
        logger.e('type: $err');
        return false;
        // ignore: avoid_catches_without_on_clauses
      } catch (err) {
        logger.e(err);
        return false;
      }
    }
    return false;
  }

  Future<bool> _readPodcast() async {
    try {
      _podcast = await _feedParser!.readChannel();
      _uiPort.send(_LoadFeedResult(_podcast!));
      return true;
      // ignore: avoid_catches_without_on_clauses
    } catch (err) {
      logger.e(err);
      return false;
    }
  }

  Future<void> _handleReadEpisodesEvent({
    int? maxReadCount,
    DateTime? lastPubDate,
  }) async {
    final episodes = <Episode>[];
    var loadedAllEpisodes = true;
    var reachedLastPubDate = false;
    while (true) {
      final episode = await _feedParser!.readChannelItem();
      if (episode == null) {
        return;
      }
      episodes.add(episode);

      if (lastPubDate != null && episode.publicationDate != null) {
        if (!lastPubDate.isBefore(episode.publicationDate!)) {
          loadedAllEpisodes = false;
          reachedLastPubDate = true;
          break;
        }
      } else if (maxReadCount != null && maxReadCount <= episodes.length) {
        loadedAllEpisodes = false;
        break;
      }
    }

    _uiPort.send(
      _ReadEpisodesResult(
        episodes,
        reachedLastPubDate: reachedLastPubDate,
        loadedAllEpisodes: loadedAllEpisodes,
      ),
    );
  }

// Future<(Podcast?, ItemParser?)> _lookupPodcastBy({
//   required String feedUrl,
//   required int collectionId,
// }) async {
//   // If we didn't get a cache hit load the podcast feed.
//   var tries = 2;
//   var url = feedUrl.replaceFirst('http:', 'https:');
//   while (0 < tries--) {
//     try {
//       logger.d('Loading podcast from feed $url');
//       return _loadPodcastFeed(feedUrl: url, collectionId: collectionId);
//     } on Exception {
//       if (tries <= 0 || !url.startsWith('https')) {
//         rethrow;
//       }
//       // Try the http only version - flesh out to setting later on
//       logger.d(
//         'Failed to load podcast. Fallback to http and try again',
//       );
//       url = url.replaceFirst('https:', 'http:');
//     }
//   }
//
//   throw UnimplementedError();
// }
}

sealed class _Command {}

sealed class _Result {}

class _SendPortEvent extends _Result {
  _SendPortEvent(this.sendPort);

  final SendPort sendPort;

  @override
  String toString() {
    return '_SendPortEvent{sendPort}';
  }
}

class _LoadFeedCommand extends _Command {
  _LoadFeedCommand({
    required this.feedUrl,
    required this.collectionId,
    required this.cacheDir,
  });

  final String feedUrl;
  final int collectionId;
  final String cacheDir;

  @override
  String toString() {
    return '_LoadFeedCommand{'
        'feedUrl: $feedUrl, '
        'collectionId: $collectionId, '
        'cacheDir: $cacheDir}';
  }
}

class _LoadFeedResult extends _Result {
  _LoadFeedResult(this.podcast);

  final Podcast podcast;

  @override
  String toString() {
    return '_LoadFeedResult{podcast: $podcast}';
  }
}

class _ReadEpisodesCommand extends _Command {
  _ReadEpisodesCommand({
    this.maxReadCount,
    this.lastPubDate,
  });

  final int? maxReadCount;
  final DateTime? lastPubDate;

  @override
  String toString() {
    return '_ReadEpisodesCommand{'
        'maxReadCount: $maxReadCount, '
        'lastPubDate: $lastPubDate}';
  }
}

class _ReadEpisodesResult extends _Result {
  _ReadEpisodesResult(
    this.episodes, {
    this.reachedLastPubDate = false,
    this.loadedAllEpisodes = false,
  });

  final List<Episode> episodes;
  final bool reachedLastPubDate;
  final bool loadedAllEpisodes;

  @override
  String toString() {
    return '_ReadEpisodesResult{'
        'episodes: ${episodes.length} episodes, '
        'reachedLastPubDate: $reachedLastPubDate, '
        'loadedAllEpisodes: $loadedAllEpisodes}';
  }
}

class _CancelledCommand extends _Command {
  _CancelledCommand();

  @override
  String toString() {
    return '_CancelledCommand{}';
  }
}

class _ErrorResult extends _Result {
  _ErrorResult(this.message);

  final String message;

  @override
  String toString() {
    return '_ErrorResult{message: $message}';
  }
}
