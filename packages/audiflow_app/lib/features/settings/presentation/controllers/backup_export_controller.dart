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
    await file.writeAsBytes(bytes, flush: true);
    try {
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

class BackupExportSuccess extends BackupExportState {}

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
    try {
      final at = now ?? DateTime.now();
      final bytes = await buildBackupFile(
        ref.read(isarProvider),
        now: at,
        appVersion: ref.read(packageInfoProvider).version,
        platform: Platform.isIOS ? 'ios' : 'android',
      );
      final sent = await ref
          .read(backupSharerProvider)
          .share(bytes, backupFileName(at));
      if (!ref.mounted) return;
      state = sent ? BackupExportSuccess() : BackupExportIdle();
    } on Exception catch (e, stack) {
      ref
          .read(namedLoggerProvider('BackupExport'))
          .e('Backup export failed', error: e, stackTrace: stack);
      if (ref.mounted) state = BackupExportError(e);
    }
  }
}
