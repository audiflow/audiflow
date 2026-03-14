import 'package:isar_community/isar.dart';

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
}

enum DownloadStatus {
  pending(0),
  downloading(1),
  completed(2),
  failed(3),
  paused(4),
  canceled(5);

  const DownloadStatus(this.value);
  final int value;
}

extension DownloadTaskStatusX on DownloadTask {
  DownloadStatus get downloadStatus => DownloadStatus.values.firstWhere(
    (e) => e.value == status,
    orElse: () => DownloadStatus.pending,
  );
}
