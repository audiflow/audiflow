import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/providers/download_manager_provider.dart';
import 'package:seasoning/providers/repository_provider.dart';
import 'package:seasoning/services/download/download_service.dart';
import 'package:seasoning/services/download/mobile_download_service.dart';
import 'package:seasoning/services/podcast/mobile_podcast_service.dart';

export 'package:seasoning/services/download/download_service.dart';

part 'download_service_provider.g.dart';

@riverpod
DownloadService downloadService(DownloadServiceRef ref) {
  final repository = ref.watch(repositoryProvider);
  final downloadManager = ref.watch(downloadManagerProvider);
  final podcastService = ref.watch(podcastServiceProvider);
  return MobileDownloadService(
    repository: repository,
    downloadManager: downloadManager,
    podcastService: podcastService,
  );
}
