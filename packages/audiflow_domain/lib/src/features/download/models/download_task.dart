import 'package:isar_community/isar.dart';

import 'download_origin.dart';
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

  /// [DownloadOrigin] as stored. Defaults to manual so rows written before
  /// this field existed are never removed by retention rules.
  int origin = 0;

  /// Converts the int [origin] to [DownloadOrigin].
  @ignore
  DownloadOrigin get downloadOrigin => DownloadOrigin.fromDbValue(origin);

  /// Converts the int [status] to the freezed [DownloadStatus].
  @ignore
  DownloadStatus get downloadStatus => DownloadStatus.fromDbValue(status);

  /// Whether retention rules may remove this download: an auto download
  /// that holds, or will hold, a file. Failed and cancelled tasks take no
  /// space, so there is nothing to keep.
  @ignore
  bool get isRemovableByRetention {
    if (downloadOrigin != DownloadOrigin.auto) return false;
    final status = downloadStatus;
    return status.isActive || status is DownloadStatusCompleted;
  }

  /// Download progress as a value from 0.0 to 1.0, or null if total is unknown.
  @ignore
  double? get progress {
    final total = totalBytes;
    if (total == null || total == 0) return null;
    return downloadedBytes / total;
  }
}
