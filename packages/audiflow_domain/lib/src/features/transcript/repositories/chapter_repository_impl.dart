import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/database/app_database.dart';
import '../../../common/providers/database_provider.dart';
import '../datasources/local/chapter_local_datasource.dart';
import 'chapter_repository.dart';

part 'chapter_repository_impl.g.dart';

/// Provides a singleton [ChapterRepository] instance.
@Riverpod(keepAlive: true)
ChapterRepository chapterRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return ChapterRepositoryImpl(datasource: ChapterLocalDatasource(db));
}

/// Implementation of [ChapterRepository] delegating to local datasource.
class ChapterRepositoryImpl implements ChapterRepository {
  ChapterRepositoryImpl({required ChapterLocalDatasource datasource})
    : _datasource = datasource;

  final ChapterLocalDatasource _datasource;

  @override
  Future<List<EpisodeChapter>> getByEpisodeId(int episodeId) =>
      _datasource.getByEpisodeId(episodeId);

  @override
  Stream<List<EpisodeChapter>> watchByEpisodeId(int episodeId) =>
      _datasource.watchByEpisodeId(episodeId);

  @override
  Future<void> upsertChapters(List<EpisodeChaptersCompanion> companions) =>
      _datasource.upsertChapters(companions);

  @override
  Future<int> deleteByEpisodeId(int episodeId) =>
      _datasource.deleteByEpisodeId(episodeId);
}
