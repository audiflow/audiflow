import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/logger_provider.dart';
import '../../download/models/download_status.dart';
import '../../download/repositories/download_repository_impl.dart';
import '../../feed/repositories/episode_repository_impl.dart';
import '../repositories/playback_history_repository_impl.dart';
import 'audio_player_service.dart';

part 'stream_cache_service.g.dart';

/// The native cache behind the player, separated so tests need no platform.
abstract interface class StreamCacheStore {
  Future<void> configure({required int maxBytes});
  Future<int> size();
  Future<List<String>> urls();
  Future<void> clear({required bool includeInUse});
  Future<void> remove(String url);
}

class _JustAudioStreamCacheStore implements StreamCacheStore {
  const _JustAudioStreamCacheStore();

  @override
  Future<void> configure({required int maxBytes}) =>
      StreamAudioCache.configure(maxBytes: maxBytes);

  @override
  Future<int> size() => StreamAudioCache.size();

  @override
  Future<List<String>> urls() => StreamAudioCache.urls();

  @override
  Future<void> clear({required bool includeInUse}) =>
      StreamAudioCache.clear(includeInUse: includeInUse);

  @override
  Future<void> remove(String url) => StreamAudioCache.remove(url);
}

@Riverpod(keepAlive: true)
class StreamCacheServiceNotifier extends _$StreamCacheServiceNotifier {
  @override
  StreamCacheService build() {
    final episodes = ref.watch(episodeRepositoryProvider);
    final downloads = ref.watch(downloadRepositoryProvider);
    final histories = ref.watch(playbackHistoryRepositoryProvider);
    return StreamCacheService(
      store: const _JustAudioStreamCacheStore(),
      completedDownloadUrls: () async => [
        for (final task in await downloads.getByStatus(
          const DownloadStatus.completed(),
        ))
          task.audioUrl,
      ],
      finishedEpisodeUrls: (time) async {
        final finished = await histories.getFinishedBefore(time);
        if (finished.isEmpty) return const [];
        final ids = [for (final history in finished) history.episodeId];
        return [for (final e in await episodes.getByIds(ids)) e.audioUrl];
      },
      isPlayerIdle: () =>
          ref.read(audioPlayerProvider).processingState == ProcessingState.idle,
      logger: ref.watch(namedLoggerProvider('StreamCache')),
    );
  }
}

/// The bytes currently held by the streamed-audio cache, kept current while
/// something shows them.
@riverpod
class StreamCacheSize extends _$StreamCacheSize {
  /// The native cache reports no changes, and playback or a sweep can change
  /// the size while a screen shows it.
  static const _refreshInterval = Duration(seconds: 10);

  @override
  Future<int> build() {
    final service = ref.watch(streamCacheServiceProvider);
    final timer = Timer.periodic(_refreshInterval, (_) => _refresh(service));
    ref.onDispose(timer.cancel);
    return service.size();
  }

  /// Assigns the result instead of invalidating, which would pass through a
  /// loading state and blank the displayed size on every refresh.
  Future<void> _refresh(StreamCacheService service) async {
    final next = await AsyncValue.guard(service.size);
    if (ref.mounted) state = next;
  }
}

/// Lifecycle of the streamed-audio cache (FR 04).
///
/// The native layer stores what the player reads and enforces the size limit.
/// This class adds the rules only the app can decide: which episodes no
/// longer need their bytes.
class StreamCacheService {
  StreamCacheService({
    required this._store,
    required this._completedDownloadUrls,
    required this._finishedEpisodeUrls,
    required this._isPlayerIdle,
    this._logger,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// Listing finished episodes is not free and resume can fire often, while
  /// the grace period makes an hour's delay irrelevant. Completed downloads
  /// are not throttled: a download makes its cached copy redundant at once.
  static const _minFinishedCheckInterval = Duration(hours: 1);

  final StreamCacheStore _store;
  final Future<List<String>> Function() _completedDownloadUrls;
  final Future<List<String>> Function(DateTime time) _finishedEpisodeUrls;
  final bool Function() _isPlayerIdle;
  final Logger? _logger;
  final DateTime Function() _clock;
  DateTime? _lastFinishedCheck;

  /// Turns the cache on. Must run before the first episode loads, because a
  /// source only goes through the cache if it was on when the source loaded.
  ///
  /// A failure is not fatal: without the cache, episodes still stream.
  Future<void> configure() async {
    try {
      await _store.configure(maxBytes: AppConstants.streamCacheMaxBytes);
    } catch (e, stack) {
      _logger?.w('Stream cache unavailable', error: e, stackTrace: stack);
    }
  }

  Future<int> size() => _store.size();

  /// Removes the cached audio the listener can do without. A loaded stream
  /// stays while the player holds it, since playback is reading from it.
  Future<void> clear() => _store.clear(includeInUse: _isPlayerIdle());

  /// Removes all cached audio. For a data reset, which stops playback first.
  Future<void> clearForReset() => _store.clear(includeInUse: true);

  /// Removes episodes that no longer need cached audio: those with a
  /// completed download, which plays from its own file, and those finished
  /// for the whole grace period. Returns the number removed.
  ///
  /// This runs on launch and resume rather than when a download completes,
  /// because downloads can also complete in a background isolate.
  /// Best-effort: the size limit still holds if a removal fails.
  Future<int> sweep() async {
    try {
      return await _sweep(_clock());
    } catch (e, stack) {
      // Isar reports storage failures as Error subclasses too.
      _logger?.w('Failed to sweep stream cache', error: e, stackTrace: stack);
      return 0;
    }
  }

  Future<int> _sweep(DateTime now) async {
    final urls = await _store.urls();
    if (urls.isEmpty) return 0;
    final last = _lastFinishedCheck;
    final checkFinished =
        last == null || !now.isBefore(last.add(_minFinishedCheckInterval));
    final cutoff = now.subtract(AppConstants.playedDownloadGracePeriod);
    final disposable = {
      for (final url in await _completedDownloadUrls()) _cacheKeyOf(url),
      if (checkFinished)
        for (final url in await _finishedEpisodeUrls(cutoff)) _cacheKeyOf(url),
    };
    var removed = 0;
    for (final url in urls) {
      if (!disposable.contains(url)) continue;
      try {
        await _store.remove(url);
        removed++;
      } on Exception catch (e, stack) {
        _logger?.w('Failed to remove $url', error: e, stackTrace: stack);
      }
    }
    // Only now: a sweep that failed earlier has to be able to retry.
    if (checkFinished) _lastFinishedCheck = now;
    return removed;
  }

  /// The form a feed URL takes as a cache key: `AudioPlayer.setUrl` parses the
  /// URL, which percent-encodes non-ASCII paths and lowercases the host. Feeds
  /// store the raw string, so comparing without this misses such episodes.
  static String _cacheKeyOf(String url) {
    final uri = Uri.tryParse(url);
    return uri == null ? url : uri.toString();
  }
}
