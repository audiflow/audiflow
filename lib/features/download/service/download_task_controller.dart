import 'dart:async';

import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_task_controller.g.dart';

class DownloadProgress {
  const DownloadProgress(
    this.id,
    this.percentage,
    this.status,
  );

  static const empty = DownloadProgress('', 0, DownloadState.none);

  final String id;
  final int percentage;
  final DownloadState status;
}

@Riverpod(keepAlive: true)
class DownloadTaskController extends _$DownloadTaskController {
  @override
  Stream<DownloadProgress> build() {
    throw UnimplementedError();
  }

  Future<void> ensureInitialized() => throw UnimplementedError();

  Future<String?> enqueueTask(
    String url,
    String downloadPath,
    String fileName,
  ) =>
      throw UnimplementedError();
}
