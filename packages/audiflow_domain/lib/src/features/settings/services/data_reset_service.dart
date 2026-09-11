import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/datasources/shared_preferences_datasource.dart';
import '../../../common/providers/background_task_canceller_provider.dart';
import '../../../common/providers/database_provider.dart';
import '../../../common/providers/platform_providers.dart';
import '../../download/services/download_file_service.dart';
import '../../download/services/download_queue_service.dart';
import '../../feed/services/feed_sync_service.dart';
import '../../player/services/audio_playback_controller.dart';
import '../../player/services/audio_player_service.dart';

part 'data_reset_service.g.dart';

/// Resolves the absolute path of the downloads directory.
///
/// Injected as a function so the service stays free of `path_provider`,
/// which has no implementation in plain unit tests.
typedef DownloadsDirectoryResolver = Future<String> Function();

/// Cancels a writer's in-flight work and completes once it has settled.
///
/// Injected as functions so the reset can be tested without constructing
/// the download queue (which listens to connectivity) or the feed sync
/// service (which needs a full provider graph).
typedef WriterCanceller = Future<void> Function();

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
    cancelDownloads: ref.watch(downloadQueueServiceProvider).cancelAll,
    cancelFeedSync: ref.watch(feedSyncServiceProvider).cancelAll,
    resolveDownloadsDirectory: fileService.getDownloadsDirectory,
  );
}

/// Returns the app to its initial state: playback is stopped and every
/// in-flight writer is cancelled, then every downloaded file, every Isar
/// collection, and every SharedPreferences key is removed.
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
    required this._cancelDownloads,
    required this._cancelFeedSync,
    required this._resolveDownloadsDirectory,
  });

  final Isar _isar;
  final SharedPreferencesDataSource _preferences;
  final AudioPlaybackController _playback;
  final WriterCanceller _cancelBackgroundTasks;
  final WriterCanceller _cancelDownloads;
  final WriterCanceller _cancelFeedSync;
  final DownloadsDirectoryResolver _resolveDownloadsDirectory;

  /// Wipes all local data. Throws on I/O failure so the caller can report
  /// a partial reset instead of claiming success.
  Future<void> resetAll() async {
    await _quiesceWriters();
    // File deletion is the step most likely to fail, so it runs before the
    // database and preferences are touched; a failure then leaves the
    // parental PIN and consent state intact rather than half-reset.
    await _deleteDownloads();
    await _isar.writeTxn(() => _isar.clear());
    await _preferences.clear();
  }

  /// Stops everything that could write to storage after the clear.
  ///
  /// Playback stops first: the progress ticker would otherwise re-create a
  /// PlaybackHistory row for the current episode seconds after the clear.
  /// The download queue and feed sync are awaited so a status write or an
  /// episode upsert that was mid-flight lands before the clear, not after.
  Future<void> _quiesceWriters() async {
    await _playback.stop();
    await _cancelBackgroundTasks();
    await _cancelDownloads();
    await _cancelFeedSync();
  }

  Future<void> _deleteDownloads() async {
    final directory = Directory(await _resolveDownloadsDirectory());
    if (!await directory.exists()) return;
    await directory.delete(recursive: true);
  }
}
