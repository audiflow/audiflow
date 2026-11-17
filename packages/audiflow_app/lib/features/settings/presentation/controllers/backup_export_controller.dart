import 'dart:io';
import 'dart:typed_data';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'backup_export_controller.g.dart';

/// Where a backup goes once built.
// ignore: one_member_abstracts
abstract interface class BackupSharer {
  /// Offers [bytes] as [fileName] in the system share sheet. Returns
  /// whether the user sent or saved it somewhere.
  Future<bool> share(Uint8List bytes, String fileName);
}

/// Shares through a temporary file, removed once the sheet closes.
class SystemBackupSharer implements BackupSharer {
  const SystemBackupSharer();

  @override
  Future<bool> share(Uint8List bytes, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    try {
      // Inside the try, so a write that fails partway (a full disk) is
      // cleaned up too.
      await file.writeAsBytes(bytes, flush: true);
      final result = await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)]),
      );
      return result.status != ShareResultStatus.dismissed;
    } finally {
      // The file holds the user's whole listening history; do not leave a
      // copy in the cache.
      if (file.existsSync()) await file.delete();
    }
  }
}

@Riverpod(keepAlive: true)
BackupSharer backupSharer(Ref ref) => const SystemBackupSharer();

sealed class BackupExportState {}

class BackupExportIdle extends BackupExportState {}

class BackupExportLoading extends BackupExportState {}

class BackupExportSuccess extends BackupExportState {
  BackupExportSuccess({this.unkeyedPodcasts = 0});

  /// Subscribed podcasts the file left out; see [BackupFile].
  final int unkeyedPodcasts;
}

class BackupExportError extends BackupExportState {
  BackupExportError(this.error);

  /// The underlying failure, kept for diagnostics; never shown to users.
  final Object error;
}

/// Controls the manual backup: builds the file from user state and opens
/// the share sheet (Files, AirDrop, mail).
@riverpod
class BackupExportController extends _$BackupExportController {
  @override
  BackupExportState build() => BackupExportIdle();

  Future<void> export({DateTime? now}) async {
    if (state is BackupExportLoading) return;
    state = BackupExportLoading();
    // Read before the first await: leaving the screen disposes this
    // controller, and a disposed ref can no longer read.
    final isar = ref.read(isarProvider);
    final appVersion = ref.read(packageInfoProvider).version;
    final sharer = ref.read(backupSharerProvider);
    final logger = ref.read(namedLoggerProvider('BackupExport'));
    try {
      final at = now ?? DateTime.now();
      final backup = await buildBackupFile(
        isar,
        now: at,
        appVersion: appVersion,
        platform: Platform.isIOS ? 'ios' : 'android',
      );
      // Nobody is left to share with once the screen is gone.
      if (!ref.mounted) return;
      final sent = await sharer.share(backup.bytes, backupFileName(at));
      if (!ref.mounted) return;
      state = sent
          ? BackupExportSuccess(unkeyedPodcasts: backup.unkeyedPodcasts)
          : BackupExportIdle();
    } on Object catch (e, stack) {
      // IsarError extends Error, not Exception; a narrower clause would
      // leave the button stuck in loading.
      logger.e('Backup export failed', error: e, stackTrace: stack);
      if (ref.mounted) state = BackupExportError(e);
    }
  }
}
