import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:audiflow/core/environment.dart';
import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:audiflow/features/download/service/download_manager.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A [DownloadManager] for handling downloading of podcasts on a mobile device.
class DefaultDownloaderManager implements DownloadManager {
  DefaultDownloaderManager(this.ref);

  final Ref ref;
  static const portName = 'downloader_send_port';
  final ReceivePort _port = ReceivePort();
  final downloadController = StreamController<DownloadProgress>();
  var _lastUpdateTime = 0;
  var _initialized = false;

  @override
  Stream<DownloadProgress> get downloadProgress => downloadController.stream;

  @override
  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    logger.d('Initialising download manager');

    await FlutterDownloader.initialize();
    IsolateNameServer.removePortNameMapping(portName);
    IsolateNameServer.registerPortWithName(_port.sendPort, portName);

    final tasks = await FlutterDownloader.loadTasks();

    // Update the status of any tasks that may have been updated whilst
    // AnyTime was close or in the background.
    if (tasks != null && tasks.isNotEmpty) {
      for (final t in tasks) {
        _updateDownloadState(
          id: t.taskId,
          progress: t.progress,
          status: t.status,
        );

        /// If we are not queued or running we can safely clean up this event
        if (t.status != DownloadTaskStatus.enqueued &&
            t.status != DownloadTaskStatus.running) {
          await FlutterDownloader.remove(
            taskId: t.taskId,
          );
        }
      }
    }

    _port.listen((dynamic data) {
      // ignore: avoid_dynamic_calls
      final id = data[0] as String;
      // ignore: avoid_dynamic_calls
      final status = DownloadTaskStatus.values[data[1] as int];
      // ignore: avoid_dynamic_calls
      final progress = data[2] as int;

      _updateDownloadState(id: id, progress: progress, status: status);
    });

    await FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  Future<String?> enqueueTask(
    String url,
    String downloadPath,
    String fileName,
  ) async {
    return FlutterDownloader.enqueue(
      url: url,
      savedDir: downloadPath,
      fileName: fileName,
      openFileFromNotification: false,
      headers: {
        'User-Agent': Environment.userAgent(),
      },
    );
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping(portName);
    downloadController.close();
  }

  void _updateDownloadState({
    required String id,
    required int progress,
    required DownloadTaskStatus status,
  }) {
    var state = DownloadState.none;
    final updateTime = DateTime.now().millisecondsSinceEpoch;

    switch (status) {
      case DownloadTaskStatus.enqueued:
        state = DownloadState.queued;
      case DownloadTaskStatus.canceled:
        state = DownloadState.cancelled;
      case DownloadTaskStatus.complete:
        state = DownloadState.downloaded;
      case DownloadTaskStatus.running:
        state = DownloadState.downloading;
      case DownloadTaskStatus.failed:
        state = DownloadState.failed;
      case DownloadTaskStatus.paused:
        state = DownloadState.paused;
      case DownloadTaskStatus.undefined:
        state = DownloadState.none;
    }

    /// If we are running, we want to limit notifications to 1 per second.
    /// Otherwise, small downloads can cause a flood of events. Any other
    /// status we always want to push through.
    if (status != DownloadTaskStatus.running ||
        progress == 0 ||
        progress == 100 ||
        _lastUpdateTime + 1000 < updateTime) {
      downloadController.add(DownloadProgress(id, progress, state));
      _lastUpdateTime = updateTime;
    }
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
    String id,
    int status,
    int progress,
  ) {
    IsolateNameServer.lookupPortByName('downloader_send_port')
        ?.send([id, status, progress]);
  }
}
