import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shared_file_inbox.g.dart';

/// Removes the copies the OS leaves in the app's inbox for shared documents.
///
/// iOS copies a document opened in this app into `Documents/Inbox` (the app
/// does not open documents in place) and never deletes the copy.
// ignore: one_member_abstracts
abstract interface class SharedFileInbox {
  /// Deletes [filePath] if it is a file directly inside the inbox; any other
  /// path is left alone, since it belongs to the user or another app.
  ///
  /// Throws [FileSystemException] if the inbox copy cannot be deleted.
  Future<void> discard(String filePath);
}

/// [SharedFileInbox] backed by a directory, or none when [_inboxDirectory]
/// yields null (platforms that hand over documents another way).
class DirectorySharedFileInbox implements SharedFileInbox {
  DirectorySharedFileInbox(this._inboxDirectory);

  final Future<Directory?> Function() _inboxDirectory;

  @override
  Future<void> discard(String filePath) async {
    final inbox = await _inboxDirectory();
    if (inbox == null) return;

    final inboxPath = await _resolve(inbox.path);
    // A missing file or inbox means there is nothing of ours to delete.
    if (inboxPath == null) return;
    final resolvedFile = await _resolve(filePath);
    if (resolvedFile == null) return;

    // Resolving symlinks and ".." first means iOS's /private/var paths match
    // path_provider's /var paths, and nothing can escape the inbox. Only files
    // directly inside it are copies iOS made for us.
    final file = File(resolvedFile);
    if (file.parent.path != inboxPath) return;
    if (!await FileSystemEntity.isFile(resolvedFile)) return;
    await file.delete();
  }

  static Future<String?> _resolve(String path) async {
    try {
      return await File(path).resolveSymbolicLinks();
    } on FileSystemException {
      return null;
    }
  }
}

@riverpod
SharedFileInbox sharedFileInbox(Ref ref) {
  return DirectorySharedFileInbox(() async {
    // Android hands shared files over as content:// URIs, not inbox copies.
    if (defaultTargetPlatform != TargetPlatform.iOS) return null;
    final documents = await getApplicationDocumentsDirectory();
    return Directory('${documents.path}/Inbox');
  });
}
