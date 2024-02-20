import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/services/download/download_manager.dart';
import 'package:seasoning/services/download/mobile_download_manager.dart';

export 'package:seasoning/services/download/download_manager.dart';

part 'download_manager_provider.g.dart';

@Riverpod(keepAlive: true)
DownloadManager downloadManager(DownloadManagerRef ref) =>
    MobileDownloaderManager(ref);
