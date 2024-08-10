import 'dart:async';

import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_manager.g.dart';

class DownloadProgress {
  DownloadProgress(
    this.id,
    this.percentage,
    this.status,
  );

  final String id;
  final int percentage;
  final DownloadState status;
}

abstract class DownloadManager {
  Future<void> ensureInitialized();

  Future<String?> enqueueTask(String url, String downloadPath, String fileName);

  Stream<DownloadProgress> get downloadProgress;

  void dispose();
}

@Riverpod(keepAlive: true)
DownloadManager downloadManager(DownloadManagerRef ref) {
  // * Override this in the main method
  throw UnimplementedError();
}
