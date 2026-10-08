import 'package:audiflow_domain/audiflow_domain.dart';

/// In-memory [DownloadRepository] covering the lookups and deletes the
/// download cleanup paths use. Other methods throw [NoSuchMethodError].
class FakeDownloadRepository implements DownloadRepository {
  final List<DownloadTask> tasks = [];

  @override
  Future<List<DownloadTask>> getByEpisodeIds(Iterable<int> episodeIds) async {
    final ids = episodeIds.toSet();
    return tasks.where((task) => ids.contains(task.episodeId)).toList();
  }

  @override
  Future<DownloadTask?> getById(int id) async =>
      tasks.where((task) => task.id == id).firstOrNull;

  @override
  Future<void> delete(int id) async =>
      tasks.removeWhere((task) => task.id == id);

  @override
  Future<DownloadTask?> deleteIfAuto(int id) async {
    final task = await getById(id);
    if (task == null || task.downloadOrigin != DownloadOrigin.auto) {
      return null;
    }
    tasks.remove(task);
    return task;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A download task for [episodeId], with an ID equal to it unless given.
DownloadTask fakeDownloadTask({
  required int episodeId,
  int? id,
  DownloadStatus status = const DownloadStatus.completed(),
  DownloadOrigin origin = DownloadOrigin.manual,
  String? localPath,
}) {
  return DownloadTask()
    ..id = id ?? episodeId
    ..episodeId = episodeId
    ..audioUrl = 'https://example.com/$episodeId.mp3'
    ..status = status.toDbValue()
    ..origin = origin.dbValue
    ..localPath = localPath
    ..createdAt = DateTime(2026);
}
