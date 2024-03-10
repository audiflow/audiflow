import 'package:audiflow/services/download/download_manager.dart';
import 'package:audiflow/services/download/mobile_download_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:audiflow/services/download/download_manager.dart';

part 'download_manager_provider.g.dart';

@Riverpod(keepAlive: true)
DownloadManager downloadManager(DownloadManagerRef ref) =>
    MobileDownloaderManager(ref);
