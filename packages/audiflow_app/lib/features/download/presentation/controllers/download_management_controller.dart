import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_management_controller.g.dart';

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

  Future<void> delete(int taskId) async {
    final service = ref.read(downloadServiceProvider);
    await service.delete(taskId);
  }

  Future<void> deleteAllCompleted() async {
    final service = ref.read(downloadServiceProvider);
    await service.deleteAllCompleted();
  }
}
