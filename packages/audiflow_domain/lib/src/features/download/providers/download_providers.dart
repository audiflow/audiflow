import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/database/app_database.dart';
import '../models/download_status.dart';
import '../repositories/download_repository_impl.dart';
import '../services/download_service.dart';

part 'download_providers.g.dart';

/// Watches download task for a specific episode.
final episodeDownloadProvider = StreamProvider.family<DownloadTask?, int>((
  ref,
  episodeId,
) {
  final repository = ref.watch(downloadRepositoryProvider);
  return repository.watchByEpisodeId(episodeId);
});

/// Watches all download tasks.
final allDownloadsProvider = StreamProvider<List<DownloadTask>>((ref) {
  final repository = ref.watch(downloadRepositoryProvider);
  return repository.watchAll();
});

/// Watches pending downloads (queue).
final pendingDownloadsProvider = StreamProvider<List<DownloadTask>>((ref) {
  final repository = ref.watch(downloadRepositoryProvider);
  return repository.watchByStatus(const DownloadStatus.pending());
});

/// Watches completed downloads.
final completedDownloadsProvider = StreamProvider<List<DownloadTask>>((ref) {
  final repository = ref.watch(downloadRepositoryProvider);
  return repository.watchByStatus(const DownloadStatus.completed());
});

/// Watches failed downloads.
final failedDownloadsProvider = StreamProvider<List<DownloadTask>>((ref) {
  final repository = ref.watch(downloadRepositoryProvider);
  return repository.watchByStatus(const DownloadStatus.failed());
});

/// Watches the currently active download.
final activeDownloadProvider = StreamProvider<DownloadTask?>((ref) {
  final service = ref.watch(downloadServiceProvider);
  return service.activeDownloadStream;
});

/// Returns count of downloads needing attention (failed).
@riverpod
Future<int> downloadsNeedingAttention(Ref ref) async {
  final repository = ref.watch(downloadRepositoryProvider);
  final failed = await repository.getByStatus(const DownloadStatus.failed());
  return failed.length;
}

/// Returns total storage used by downloads.
@riverpod
Future<int> downloadStorageUsed(Ref ref) {
  final service = ref.watch(downloadServiceProvider);
  return service.getTotalStorageUsed();
}

/// Check if an episode is downloaded.
@riverpod
Future<bool> isEpisodeDownloaded(Ref ref, int episodeId) async {
  final repository = ref.watch(downloadRepositoryProvider);
  final task = await repository.getCompletedForEpisode(episodeId);
  return task != null;
}
