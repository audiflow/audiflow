import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/datasources/shared_preferences_datasource.dart';
import '../../../common/providers/background_task_canceller_provider.dart';
import '../../../common/providers/database_provider.dart';
import '../../../common/providers/platform_providers.dart';
import '../../../common/services/suspendable_writer.dart';
import '../../download/services/download_file_service.dart';
import '../../download/services/download_queue_service.dart';
import '../../player/services/stream_cache_service.dart';
import '../../feed/services/feed_sync_service.dart';
import '../../player/services/audio_playback_controller.dart';
import '../../player/services/audio_player_service.dart';
import '../../snapshot/auto_snapshot_scheduler.dart';
import '../../snapshot/continuity_snapshot.dart';

part 'data_reset_service.g.dart';

/// Resolves the absolute path of the downloads directory.
///
/// Injected as a function so the service stays free of `path_provider`,
/// which has no implementation in plain unit tests.
typedef DownloadsDirectoryResolver = Future<String> Function();

/// Provides the [DataResetService] backing "Reset All Data".
@Riverpod(keepAlive: true)
DataResetService dataResetService(Ref ref) {
  final fileService = ref.watch(downloadFileServiceProvider);
  return DataResetService(
    isar: ref.watch(isarProvider),
    preferences: SharedPreferencesDataSource(
      ref.watch(sharedPreferencesProvider),
    ),
    playback: ref.watch(audioPlayerControllerProvider.notifier),
    cancelBackgroundTasks: ref.watch(backgroundTaskCancellerProvider),
    writers: [
      ref.watch(downloadQueueServiceProvider),
      ref.watch(feedSyncServiceProvider),
      ref.watch(autoSnapshotSchedulerProvider),
    ],
    resolveDownloadsDirectory: fileService.getDownloadsDirectory,
    resolveContinuitySnapshotPath: ref.watch(continuitySnapshotPathProvider),
    clearStreamCache: ref.watch(streamCacheServiceProvider).clearForReset,
  );
}

/// Returns the app to its initial state: playback is stopped and every
/// writer is suspended, then every downloaded file, the streamed-audio cache,
/// the continuity snapshot, every Isar collection, and every
/// SharedPreferences key is removed.
///
/// Isar is cleared with [Isar.clear] rather than per collection so a
/// collection added later cannot drift out of the reset path; the
/// service test seeds every schema in `isarSchemas` to enforce this.
class DataResetService {
  DataResetService({
    required this._isar,
    required this._preferences,
    required this._playback,
    required this._cancelBackgroundTasks,
    required this._writers,
    required this._resolveDownloadsDirectory,
    required this._resolveContinuitySnapshotPath,
    required this._clearStreamCache,
  });

  final Isar _isar;
  final SharedPreferencesDataSource _preferences;
  final AudioPlaybackController _playback;
  final WriterCanceller _cancelBackgroundTasks;

  /// Foreground services that write to storage, in suspend order.
  final List<SuspendableWriter> _writers;
  final DownloadsDirectoryResolver _resolveDownloadsDirectory;
  final ContinuitySnapshotPathResolver _resolveContinuitySnapshotPath;
  final Future<void> Function() _clearStreamCache;

  /// Wipes all local data. Throws on I/O failure so the caller can report
  /// a partial reset instead of claiming success.
  ///
  /// Every writer is suspended before the storage it writes to is cleared
  /// and resumed only afterwards, so a status write or an episode upsert
  /// that was mid-flight lands before the clear, and work started during
  /// the reset writes nothing. Playback stops first: the progress ticker
  /// would otherwise re-create a PlaybackHistory row for the current
  /// episode seconds after the clear.
  Future<void> resetAll() async {
    await _playback.stop();
    await _cancelBackgroundTasks();
    // Suspending happens inside the try so a writer that fails to suspend
    // does not strand the ones suspended before it.
    try {
      for (final writer in _writers) {
        await writer.suspend();
      }
      // File deletion is the step most likely to fail, so it runs before
      // the database and preferences are touched; a failure then leaves
      // the parental PIN and consent state intact rather than half-reset.
      // The cache goes first: losing it costs nothing, while downloads
      // cannot be brought back if a later step fails.
      await _clearStreamCache();
      await _deleteDownloads();
      // Otherwise the next launch sees an empty database next to a
      // snapshot and restores the data the user just reset. Before the
      // database, so a failure here leaves the data whole.
      await _deleteContinuitySnapshot();
      await _isar.writeTxn(() => _isar.clear());
      await _preferences.clear();
    } finally {
      for (final writer in _writers.reversed) {
        writer.resume();
      }
    }
  }

  /// Deletes the snapshot and any unreadable one moved aside next to it,
  /// which a later version would otherwise merge back in.
  Future<void> _deleteContinuitySnapshot() async {
    final file = File(await _resolveContinuitySnapshotPath());
    final retained = File(p.join(file.parent.path, retainedSnapshotFileName));
    for (final f in [file, retained]) {
      if (await f.exists()) await f.delete();
    }
  }

  /// Deletes every file under the downloads directory, keeping the
  /// directory itself: iOS marks it as excluded from backup at launch, and
  /// a re-created directory would lack that flag until the next launch.
  Future<void> _deleteDownloads() async {
    final directory = Directory(await _resolveDownloadsDirectory());
    if (!await directory.exists()) return;
    await for (final entry in directory.list(followLinks: false)) {
      await entry.delete(recursive: true);
    }
  }
}
