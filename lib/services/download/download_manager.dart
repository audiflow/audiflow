import 'dart:async';

import 'package:audiflow/entities/downloadable.dart';

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
