import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_management_controller.g.dart';

/// Looks up an episode by ID for download tile display.
@riverpod
Future<Episode?> episodeByIdForDownload(Ref ref, int episodeId) {
  return ref.watch(episodeRepositoryProvider).getById(episodeId);
}

/// Controller for download management actions.
@riverpod
class DownloadManagementController extends _$DownloadManagementController {
  @override
  FutureOr<void> build() {}

  Future<void> pause(int taskId) async {
    final service = ref.read(downloadServiceProvider);
    await service.pause(taskId);
  }

  Future<void> resume(int taskId) async {
    final service = ref.read(downloadServiceProvider);
    await service.resume(taskId);
  }

  Future<void> cancel(int taskId) async {
    final service = ref.read(downloadServiceProvider);
    await service.cancel(taskId);
  }

  Future<void> retry(int taskId) async {
    final service = ref.read(downloadServiceProvider);
    await service.retry(taskId);
  }

  /// Returns whether the download was kept (false when there was nothing
  /// to keep).
  Future<bool> keep(int taskId) {
    final service = ref.read(downloadServiceProvider);
    return service.keep(taskId);
  }

  Future<void> delete(int taskId) async {
    final service = ref.read(downloadServiceProvider);
    await service.delete(taskId);
  }

  Future<int> deleteTasks(
    Iterable<int> taskIds, {
    required Set<DownloadStatus> statuses,
  }) {
    final service = ref.read(downloadServiceProvider);
    return service.deleteTasks(taskIds, statuses: statuses);
  }
}
