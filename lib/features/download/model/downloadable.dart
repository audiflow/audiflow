import 'package:audiflow/utils/hash.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';

part 'downloadable.g.dart';

enum DownloadState {
  none,
  queued,
  downloading,
  failed,
  cancelled,
  paused,
  downloaded
}

/// A Downloadable is an object that holds information about a podcast episode
/// and its download status.
///
/// Downloadable can be used to determine if a download has been successful and
/// if an episode can be played from the filesystem.
@collection
class Downloadable {
  Downloadable({
    required this.pid,
    required this.eid,
    required this.ordinal,
    required this.url,
    required this.directory,
    required this.filename,
    required this.taskId,
    required this.state,
    required this.downloadStartedAt,
    this.percentage = 0,
  });

  static Id fromGuid(String guid) => fastHash(guid);

  Id get id => eid;

  /// The podcast id.
  @Index(composite: [CompositeIndex('ordinal')])
  final int pid;

  /// Unique identifier for the episode.
  @Index(unique: true)
  final int eid;

  /// The ordinal number of the episode.
  final int ordinal;

  /// Unique identifier for the download
  final String url;

  /// Destination directory
  final String directory;

  /// Name of file
  final String filename;

  /// Current task ID for the download
  @Index()
  final String taskId;

  /// Time when the download started
  @Index()
  final DateTime downloadStartedAt;

  /// Current state of the download
  @enumerated
  final DownloadState state;

  /// Percentage of MP3 downloaded
  @Default(0)
  int percentage;

  Downloadable copyWith({
    String? url,
    String? directory,
    String? filename,
    String? taskId,
    DownloadState? state,
    DateTime? downloadStartedAt,
    int? percentage,
  }) {
    return Downloadable(
      pid: pid,
      eid: eid,
      ordinal: ordinal,
      url: url ?? this.url,
      directory: directory ?? this.directory,
      filename: filename ?? this.filename,
      taskId: taskId ?? this.taskId,
      state: state ?? this.state,
      downloadStartedAt: downloadStartedAt ?? this.downloadStartedAt,
      percentage: percentage ?? this.percentage,
    );
  }

  @override
  String toString() {
    return 'Downloadable('
        'pid: $pid, '
        'eid: $eid,'
        'taskId: $taskId,'
        ' state: $state,'
        ' downloadStartedAt: $downloadStartedAt,'
        ' percentage: $percentage)';
  }
}

extension DownloadableExt on Downloadable {
  bool get downloaded => state == DownloadState.downloaded;
}
