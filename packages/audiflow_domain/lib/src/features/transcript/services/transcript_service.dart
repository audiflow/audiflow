import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/database/app_database.dart';
import '../../../common/providers/http_client_provider.dart';
import '../../../common/providers/logger_provider.dart';
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
    required TranscriptRepository repository,
    required Dio dio,
    required Logger logger,
  }) : _repository = repository,
       _dio = dio,
       _logger = logger;

  final TranscriptRepository _repository;
  final Dio _dio;
  final Logger _logger;
  final _parser = TranscriptFileParser();

  /// Ensures transcript content is available. Fetches if not already stored.
  ///
  /// Returns the transcriptId of the best available transcript, or null
  /// if no supported transcript exists.
  Future<int?> ensureContent(int episodeId) async {
    final metas = await _repository.getMetasByEpisodeId(episodeId);

    final supported = metas
        .where((m) => TranscriptFileParser.isSupported(m.type))
        .toList();
    if (supported.isEmpty) return null;

    // Prefer VTT for speaker support
    final chosen = supported.firstWhere(
      (m) => m.type == 'text/vtt',
      orElse: () => supported.first,
    );

    // Already fetched?
    if (chosen.fetchedAt != null) return chosen.id;

    return _fetchAndStore(episodeId, chosen);
  }

  Future<int?> _fetchAndStore(int episodeId, EpisodeTranscript chosen) async {
    try {
      final response = await _dio.get<String>(chosen.url);
      final content = response.data;
      if (content == null || content.isEmpty) return null;

      final segments = _parser.parse(content, mimeType: chosen.type);
      if (segments.isEmpty) return null;

      final companions = segments
          .map(
            (s) => TranscriptSegmentsCompanion.insert(
              transcriptId: chosen.id,
              startMs: s.startMs,
              endMs: s.endMs,
              body: s.text,
              speaker: Value(s.speaker),
            ),
          )
          .toList();

      await _repository.insertSegments(companions);
      await _repository.markAsFetched(chosen.id);

      _logger.i(
        'Fetched transcript for episode $episodeId: '
        '${segments.length} segments',
      );

      return chosen.id;
    } on DioException catch (e) {
      _logger.w('Failed to fetch transcript for episode $episodeId', error: e);
      return null;
    }
  }
}
