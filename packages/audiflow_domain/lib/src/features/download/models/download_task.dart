import 'package:isar_community/isar.dart';

import 'download_status.dart';

part 'download_task.g.dart';

@collection
class DownloadTask {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int episodeId;

  late String audioUrl;
  String? localPath;
  int? totalBytes;
  int downloadedBytes = 0;
  int status = 0;
  bool wifiOnly = true;
  int retryCount = 0;
  String? lastError;
  late DateTime createdAt;
  DateTime? completedAt;

  /// Converts the int [status] to the freezed [DownloadStatus].
  @ignore
  DownloadStatus get downloadStatus => DownloadStatus.fromDbValue(status);

  /// Download progress as a value from 0.0 to 1.0, or null if total is unknown.
  @ignore
  double? get progress {
    final total = totalBytes;
    if (total == null || total == 0) return null;
    return downloadedBytes / total;
  }
}
