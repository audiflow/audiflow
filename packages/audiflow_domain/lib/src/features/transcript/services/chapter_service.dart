import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/http_client_provider.dart';
import '../../../common/providers/logger_provider.dart';
import '../../feed/models/episode.dart';
import '../../feed/repositories/episode_repository.dart';
import '../../feed/repositories/episode_repository_impl.dart';
import '../models/chapter_source.dart';
import '../models/episode_chapter.dart';
import '../repositories/chapter_repository.dart';
import '../repositories/chapter_repository_impl.dart';

part 'chapter_service.g.dart';

@Riverpod(keepAlive: true)
ChapterService chapterService(Ref ref) {
  return ChapterService(
    chapterRepository: ref.watch(chapterRepositoryProvider),
    episodeRepository: ref.watch(episodeRepositoryProvider),
    dio: ref.watch(dioProvider),
    logger: ref.watch(namedLoggerProvider('ChapterService')),
  );
}

/// Loads chapters that are not stored during feed sync.
///
/// `<podcast:chapters>` only links a JSON file, so sync stores the link and
/// this service fetches the file the first time the episode's chapters are
/// needed, mirroring how transcripts are fetched on demand.
class ChapterService {
  ChapterService({
    required this._chapterRepository,
    required this._episodeRepository,
    required this._dio,
    required this._logger,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  /// How long a failed chapters URL is left alone before it is tried again,
  /// so repeated opens of a broken episode do not hammer the server.
  static const retryCooldown = Duration(minutes: 10);

  final ChapterRepository _chapterRepository;
  final EpisodeRepository _episodeRepository;
  final Dio _dio;
  final Logger _logger;
  final DateTime Function() _now;
  final _parser = const JsonChaptersParser();
  final Map<int, Future<bool>> _inFlight = {};
  final Map<String, DateTime> _failedAt = {};

  /// Makes sure the best available chapters for [episodeId] are stored.
  ///
  /// Returns true when stored chapters changed. Never throws: a network or
  /// parse failure leaves the stored chapters as they are.
  Future<bool> ensureChapters(int episodeId) {
    final pending = _inFlight[episodeId];
    if (pending != null) return pending;
    // Block body on purpose: returning the removed future from the callback
    // would make whenComplete wait on itself.
    final future = _ensure(episodeId).whenComplete(() {
      _inFlight.remove(episodeId);
    });
    _inFlight[episodeId] = future;
    return future;
  }

  Future<bool> _ensure(int episodeId) async {
    try {
      final episode = await _episodeRepository.getById(episodeId);
      if (episode == null) return false;
      return await _ensureJsonChapters(episode);
    } catch (e, st) {
      // Isar failures surface as Error subclasses, so catch everything:
      // chapter loading must never break the caller.
      _logger.w(
        'Failed to load chapters for episode $episodeId',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  Future<bool> _ensureJsonChapters(Episode episode) async {
    final stored = await _chapterRepository.getByEpisodeId(episode.id);
    final storedJsonUrl =
        stored.firstOrNull?.source == ChapterSource.podcastChaptersJson
        ? stored.first.sourceUrl
        : null;
    final url = _isJsonChapters(episode.chaptersType)
        ? episode.chaptersUrl
        : null;
    if (url == null) return _dropUnlinkedJsonChapters(episode, stored);
    // Publishers revise chapter files after release; a new URL means new
    // content, so only an unchanged URL counts as already fetched.
    if (storedJsonUrl == url) return false;
    if (_isCoolingDown(url)) return false;

    final chapters = await _fetchJsonChapters(url);
    if (chapters == null) return false;

    final replaced = await _chapterRepository.replaceChapters({
      episode.id: _toEntities(episode.id, chapters, url),
    }, source: ChapterSource.podcastChaptersJson);
    return replaced.isNotEmpty;
  }

  /// Removes JSON chapters whose link the feed no longer carries, so they
  /// stop outranking chapters from the feed itself.
  Future<bool> _dropUnlinkedJsonChapters(
    Episode episode,
    List<EpisodeChapter> stored,
  ) async {
    if (stored.firstOrNull?.source != ChapterSource.podcastChaptersJson) {
      return false;
    }
    await _chapterRepository.deleteByEpisodeId(episode.id);
    return true;
  }

  /// Fetches and parses a chapters file; null when it yields no chapters.
  Future<List<PodcastChapter>?> _fetchJsonChapters(String url) async {
    try {
      final response = await _dio.get<String>(
        url,
        // Plain text: a JSON content type would otherwise be decoded by Dio
        // into a Map before the parser sees it.
        options: Options(responseType: ResponseType.plain),
      );
      final body = response.data;
      final chapters = body == null ? null : _parser.parse(body);
      if (chapters != null && chapters.isNotEmpty) {
        _failedAt.remove(url);
        return chapters;
      }
      _logger.w('Chapters file has no usable chapters: $url');
    } on DioException catch (e) {
      _logger.w('Failed to fetch chapters file: $url', error: e);
    } on FormatException catch (e) {
      _logger.w('Malformed chapters file: $url', error: e);
    } catch (e, st) {
      // Anything else still counts as a failed attempt for the cooldown.
      _logger.w('Failed to load chapters file: $url', error: e, stackTrace: st);
    }
    _failedAt[url] = _now();
    return null;
  }

  bool _isCoolingDown(String url) {
    final failedAt = _failedAt[url];
    if (failedAt == null) return false;
    return _now().isBefore(failedAt.add(retryCooldown));
  }

  // Feeds declare `application/json+chapters`, but some use plain
  // `application/json` for the same file.
  static bool _isJsonChapters(String? type) =>
      type != null && type.toLowerCase().contains('json');

  static List<EpisodeChapter> _toEntities(
    int episodeId,
    List<PodcastChapter> chapters,
    String sourceUrl,
  ) => [
    for (final (index, chapter) in chapters.indexed)
      EpisodeChapter()
        ..episodeId = episodeId
        ..sortOrder = index
        ..title = chapter.title
        ..startMs = chapter.startTime.inMilliseconds
        ..endMs = chapter.endTime?.inMilliseconds
        ..url = chapter.url
        ..imageUrl = chapter.imageUrl
        ..sourceUrl = sourceUrl,
  ];
}
