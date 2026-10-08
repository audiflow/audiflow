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

  /// File removals recorded by [deleteIfAuto] and not yet completed.
  final List<DownloadFileRemoval> fileRemovals = [];

  @override
  Future<DownloadTask?> getByEpisodeId(int episodeId) async =>
      tasks.where((task) => task.episodeId == episodeId).firstOrNull;

  @override
  Future<DeletedAutoDownload?> deleteIfAuto(int id) async {
    final task = await getById(id);
    if (task == null || task.downloadOrigin != DownloadOrigin.auto) {
      return null;
    }
    tasks.remove(task);
    fileRemovals.removeWhere((r) => r.episodeId == task.episodeId);
    final fileRemoval = DownloadFileRemoval()
      ..id = task.id
      ..episodeId = task.episodeId
      ..storedPath = task.localPath;
    fileRemovals.add(fileRemoval);
    return (task: task, fileRemoval: fileRemoval);
  }

  @override
  Future<List<DownloadFileRemoval>> getPendingFileRemovals() async =>
      List.of(fileRemovals);

  @override
  Future<void> completeFileRemoval(int id) async =>
      fileRemovals.removeWhere((removal) => removal.id == id);

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
