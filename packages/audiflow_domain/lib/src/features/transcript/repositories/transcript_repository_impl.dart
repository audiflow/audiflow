import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/database/app_database.dart';
import '../../../common/providers/database_provider.dart';
import '../datasources/local/transcript_local_datasource.dart';
import 'transcript_repository.dart';

part 'transcript_repository_impl.g.dart';

/// Provides a singleton [TranscriptRepository] instance.
@Riverpod(keepAlive: true)
TranscriptRepository transcriptRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return TranscriptRepositoryImpl(datasource: TranscriptLocalDatasource(db));
}

/// Implementation of [TranscriptRepository] delegating to local datasource.
class TranscriptRepositoryImpl implements TranscriptRepository {
  TranscriptRepositoryImpl({required TranscriptLocalDatasource datasource})
    : _datasource = datasource;

  final TranscriptLocalDatasource _datasource;

  @override
  Future<List<EpisodeTranscript>> getMetasByEpisodeId(int episodeId) =>
      _datasource.getMetasByEpisodeId(episodeId);

  @override
  Future<List<TranscriptSegment>> getAllSegments(int transcriptId) =>
      _datasource.getAllSegments(transcriptId);

  @override
  Future<List<TranscriptSegment>> getSegments(
    int transcriptId, {
    required int startMs,
    required int endMs,
  }) => _datasource.getSegments(transcriptId, startMs: startMs, endMs: endMs);

  @override
  Future<void> upsertMetas(List<EpisodeTranscriptsCompanion> companions) =>
      _datasource.upsertMetas(companions);

  @override
  Future<void> insertSegments(List<TranscriptSegmentsCompanion> segments) =>
      _datasource.insertSegments(segments);

  @override
  Future<void> markAsFetched(int transcriptId) =>
      _datasource.markAsFetched(transcriptId);

  @override
  Future<bool> isContentFetched(int transcriptId) =>
      _datasource.isContentFetched(transcriptId);

  @override
  Future<int> deleteSegments(int transcriptId) =>
      _datasource.deleteSegments(transcriptId);
}
