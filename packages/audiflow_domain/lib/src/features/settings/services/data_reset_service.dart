import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/datasources/shared_preferences_datasource.dart';
import '../../../common/providers/database_provider.dart';
import '../../../common/providers/platform_providers.dart';
import '../../download/services/download_file_service.dart';

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
    resolveDownloadsDirectory: fileService.getDownloadsDirectory,
  );
}

/// Returns the app to its initial state: every Isar collection, every
/// downloaded file, and every SharedPreferences key is removed.
///
/// Isar is cleared with [Isar.clear] rather than per collection so a
/// collection added later cannot drift out of the reset path; the
/// service test seeds every schema in `isarSchemas` to enforce this.
class DataResetService {
  DataResetService({
    required this._isar,
    required this._preferences,
    required this._resolveDownloadsDirectory,
  });

  final Isar _isar;
  final SharedPreferencesDataSource _preferences;
  final DownloadsDirectoryResolver _resolveDownloadsDirectory;

  /// Wipes all local data. Throws on I/O failure so the caller can report
  /// a partial reset instead of claiming success.
  Future<void> resetAll() async {
    // Database first: the parental PIN hash lives here, and the UI streams
    // watching Isar update as soon as the transaction commits.
    await _isar.writeTxn(() => _isar.clear());
    await _deleteDownloads();
    await _preferences.clear();
  }

  Future<void> _deleteDownloads() async {
    final directory = Directory(await _resolveDownloadsDirectory());
    if (!await directory.exists()) return;
    await directory.delete(recursive: true);
  }
}
