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
    void onWorkerMessage(dynamic message) {
      if (message is _SendPortEvent) {
        logger.d('received worker port');
        _workerPort = message.sendPort;
        _loadFeed();
      } else if (message is _GotPodcastEvent) {
        logger.d(() => 'received podcast ${message.podcast}');
        state = state.copyWith(podcast: message.podcast);
      } else if (message is List<Episode>) {
        state = state.copyWith(episodes: [...state.episodes, ...message]);
      }
    }

    final cancellable = workerManager.executeGentleWithPort<void, dynamic>(
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
      _LoadFeedEvent(
        feedUrl: state.feedUrl,
        collectionId: state.collectionId,
        cacheDir: _cacheDir,
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
  }) = _PodcastFeedLoaderState;
}

class _Worker {
  _Worker(
    this._uiPort,
    this._isCancelled,
  ) {
    _uiPort.send(_SendPortEvent(_workerPort.sendPort));
  }

  final _logger = createLogger();
  final _completer = Completer<void>();
  final SendPort _uiPort;
  final ReceivePort _workerPort = ReceivePort();
  final bool Function() _isCancelled;
  PodcastFeedParser<Uint8List, Podcast, Episode>? _feedParser;
  Podcast? _podcast;

  Future<void> listen() async {
    _workerPort.listen(_onMessage);
    return _completer.future;
  }

  void _onMessage(dynamic message) {
    switch (message) {
      case _LoadFeedEvent():
        _handleLoadFeedEvent(
          feedUrl: message.feedUrl,
          collectionId: message.collectionId,
          cacheDir: message.cacheDir,
        );
    }
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

    var  i = 0;
    while (await _readEpisode()) {
      i++;
    }
    logger.d('loaded $i episodes');
  }

  Future<bool> _loadFeed({
    required String feedUrl,
    required int collectionId,
    required String cacheDir,
  }) async {
    _logger.d(() => 'loadFeed $feedUrl, collectionId=$collectionId');

    ResponseBody? rs;
    try {
      final http = CachedHttp(cacheDir);
      rs = await http
          .fetch<ResponseBody>(feedUrl, responseType: ResponseType.stream)
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
      // ignore: avoid_catches_without_on_clauses
    } catch (err) {
      _logger.e(err);
      return false;
    }
  }

  Future<bool> _readPodcast() async {
    try {
      _podcast = await _feedParser!.readChannel();
      _uiPort.send(_GotPodcastEvent(_podcast!));
      return true;
      // ignore: avoid_catches_without_on_clauses
    } catch (err) {
      _logger.e(err);
      return false;
    }
  }

  Future<bool> _readEpisode() async {
    try {
      final episode = await _feedParser!.readChannelItem();
      // _logger.d(() => 'readEpisode $episode');
      return episode != null;
      // ignore: avoid_catches_without_on_clauses
    } catch (err) {
      _logger.e(err);
      return false;
    }
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

sealed class _Event {}

class _SendPortEvent extends _Event {
  _SendPortEvent(this.sendPort);

  final SendPort sendPort;
}

class _LoadFeedEvent extends _Event {
  _LoadFeedEvent({
    required this.feedUrl,
    required this.collectionId,
    required this.cacheDir,
  });

  final String feedUrl;
  final int collectionId;
  final String cacheDir;
}

class _GotPodcastEvent extends _Event {
  _GotPodcastEvent(this.podcast);

  final Podcast podcast;
}

class _GotEpisodesEvent extends _Event {
  _GotEpisodesEvent(this.podcast);

  final Podcast podcast;
}
