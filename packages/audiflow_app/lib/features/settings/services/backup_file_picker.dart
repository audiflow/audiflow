import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'content_uri_reader.dart';
import 'opml_file_picker.dart';

part 'backup_file_picker.g.dart';

/// A backup chosen in the system picker, not read yet.
class PickedBackupFile {
  const PickedBackupFile(this.read);

  /// Reads the file. May download it from a remote provider.
  final Future<Uint8List> Function() read;
}

/// Far above any real backup (user state only, gzipped), and low enough that
/// picking a video by mistake fails on its own. The Android read in
/// `MainActivity.kt` uses the same limit.
@visibleForTesting
const maxBackupFileBytes = 64 * 1024 * 1024;

/// Opens the system file picker for restoring a backup.
///
/// Shows every file: `.audiflow-backup` has no registered type (plan
/// decision D4), so a filter would hide it. A wrong pick fails validation.
// ignore: one_member_abstracts
abstract interface class BackupFilePicker {
  /// Resolves once the user has chosen a file, or with null on cancel.
  Future<PickedBackupFile?> pick();
}

/// Picks through the Storage Access Framework, as [AndroidOpmlFilePicker].
class AndroidBackupFilePicker implements BackupFilePicker {
  const AndroidBackupFilePicker([
    this._channel = const MethodChannel(AndroidOpmlFilePicker.channelName),
  ]);

  final MethodChannel _channel;

  @override
  Future<PickedBackupFile?> pick() async {
    final uri = await _channel.invokeMethod<String>('pickDocument', const [
      '*/*',
    ]);
    if (uri == null) return null;
    return PickedBackupFile(() => readContentUriBytes(uri));
  }
}

/// Picks through `UIDocumentPickerViewController` via file_picker.
class IosBackupFilePicker implements BackupFilePicker {
  const IosBackupFilePicker();

  @override
  Future<PickedBackupFile?> pick() async {
    final file = await FilePicker.pickFile();
    if (file == null) return null;

    final path = file.path;
    return PickedBackupFile(() async {
      if (path == null) {
        throw const FormatException('Picked file has no local path');
      }
      try {
        final onDisk = File(path);
        if (maxBackupFileBytes < await onDisk.length()) {
          throw const FormatException('File is too large to read');
        }
        return await onDisk.readAsBytes();
      } on FileSystemException catch (e) {
        throw FormatException(e.message);
      }
    });
  }
}

@riverpod
BackupFilePicker backupFilePicker(Ref ref) {
  return defaultTargetPlatform == TargetPlatform.android
      ? const AndroidBackupFilePicker()
      : const IosBackupFilePicker();
}
