import 'package:audiflow_podcast/audiflow_podcast.dart' hide TranscriptSegment;
import 'package:audiflow_podcast/audiflow_podcast.dart'
    as podcast
    show TranscriptSegment;
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/http_client_provider.dart';
import '../../../common/providers/logger_provider.dart';
import '../models/episode_transcript.dart';
import '../models/transcript_segment_table.dart';
import '../repositories/transcript_repository.dart';
import '../repositories/transcript_repository_impl.dart';

part 'transcript_service.g.dart';

@Riverpod(keepAlive: true)
TranscriptService transcriptService(Ref ref) {
  return TranscriptService(
    repository: ref.watch(transcriptRepositoryProvider),
    dio: ref.watch(dioProvider),
    logger: ref.watch(namedLoggerProvider('TranscriptService')),
  );
}

/// Orchestrates downloading, parsing, and storing transcript content.
class TranscriptService {
  TranscriptService({
    required this._repository,
    required this._dio,
    required this._logger,
  });

  final TranscriptRepository _repository;
  final Dio _dio;
  final Logger _logger;
  final _parser = TranscriptFileParser();

  /// Ensures transcript content is available. Fetches if not already stored.
  ///
  /// Tries the declared files in order of preference (VTT first, for its
  /// speaker labels) and returns the id of the first one whose content is
  /// stored, or null when none yields a transcript. A file that downloads
  /// but holds no transcript is marked unusable so it is not offered or
  /// fetched again; a network or HTTP failure is left to a later try.
  ///
  /// Cancelling [cancelToken] abandons the download and answers null
  /// without marking anything: the caller no longer wants the answer, which
  /// says nothing about whether the file is usable.
  Future<int?> ensureContent(int episodeId, {CancelToken? cancelToken}) async {
    final metas = await _repository.getMetasByEpisodeId(episodeId);
    final candidates = _byPreference(metas.where((m) => m.isCandidate));

    for (final candidate in candidates) {
      if (candidate.fetchedAt != null) return candidate.id;
      if (cancelToken?.isCancelled ?? false) return null;

      final stored = await _fetchAndStore(episodeId, candidate, cancelToken);
      if (stored) return candidate.id;
    }
    return null;
  }

  List<EpisodeTranscript> _byPreference(Iterable<EpisodeTranscript> metas) {
    final vtt = metas.where((m) => m.type == 'text/vtt');
    final others = metas.where((m) => m.type != 'text/vtt');
    return [...vtt, ...others];
  }

  /// Returns whether the file's segments are now stored.
  Future<bool> _fetchAndStore(
    int episodeId,
    EpisodeTranscript chosen,
    CancelToken? cancelToken,
  ) async {
    final String? content;
    try {
      final response = await _dio.get<String>(
        chosen.url,
        cancelToken: cancelToken,
      );
      content = response.data;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        _logger.d('Transcript fetch for episode $episodeId cancelled');
        return false;
      }
      _logger.w('Failed to fetch transcript for episode $episodeId', error: e);
      return false;
    }

    final segments = _parse(content, chosen.type);
    if (segments.isEmpty) {
      _logger.w(
        'Transcript for episode $episodeId has no segments: ${chosen.url}',
      );
      await _repository.markAsUnusable(chosen.id);
      return false;
    }

    await _repository.insertSegments(_toRows(chosen.id, segments));
    await _repository.markAsFetched(chosen.id);
    _logger.i(
      'Fetched transcript for episode $episodeId: '
      '${segments.length} segments',
    );
    return true;
  }

  /// Parses [content]; empty content and malformed files yield no segments.
  List<podcast.TranscriptSegment> _parse(String? content, String mimeType) {
    if (content == null || content.isEmpty) return const [];
    try {
      return _parser.parse(content, mimeType: mimeType);
    } on FormatException catch (e) {
      _logger.w('Malformed $mimeType transcript', error: e);
      return const [];
    }
  }

  List<TranscriptSegment> _toRows(
    int transcriptId,
    List<podcast.TranscriptSegment> segments,
  ) {
    return segments
        .map(
          (s) => TranscriptSegment()
            ..transcriptId = transcriptId
            ..startMs = s.startMs
            ..endMs = s.endMs
            ..body = s.text
            ..speaker = s.speaker,
        )
        .toList();
  }
}
