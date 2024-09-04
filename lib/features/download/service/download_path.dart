import 'dart:io';

import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/features/preference/data/app_preference_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_path.g.dart';

abstract class DownloadPath {
  /// Returns the storage directory for the current platform.
  ///
  /// On iOS, the directory that the app has available to it for storing
  /// episodes may change between updates, whereas on Android we are able to
  /// save the full path. To ensure we can handle the directory name change on
  /// iOS without breaking existing Android installations we have created the
  /// following three functions to help with resolving the various paths
  /// correctly depending upon platform.
  Future<String> resolvePath(Downloadable download);

  Future<String> directoryToRecord(Episode episode);

  Future<String> createDownloadDirectory(Episode episode);

  Future<bool> hasStoragePermission();

  Future<String> getStorageDirectory();

  Future<bool> hasExternalStorage();

  String safePath(String s);

  String safeFile(String s);
}

@Riverpod(keepAlive: true)
DownloadPath downloadPath(DownloadPathRef ref) {
  return DownloadPathImpl(ref);
}

class DownloadPathImpl implements DownloadPath {
  DownloadPathImpl(this.ref);

  final Ref ref;

  @override
  Future<String> resolvePath(Downloadable download) async {
    return Platform.isAndroid
        ? join(download.directory, download.filename)
        : join(
            await getStorageDirectory(),
            download.directory,
            download.filename,
          );
  }

  @override
  Future<String> directoryToRecord(Episode episode) async {
    return Platform.isAndroid
        ? join(await getStorageDirectory(), safePath(episode.guid))
        : safePath(episode.guid);
  }

  @override
  Future<String> createDownloadDirectory(Episode episode) async {
    final path = join(await getStorageDirectory(), safePath(episode.guid));
    Directory(path).createSync(recursive: true);
    return path;
  }

  @override
  Future<bool> hasStoragePermission() async {
    if (Platform.isIOS ||
        !ref.read(appPreferenceRepositoryProvider).storeDownloadsSDCard) {
      return true;
    } else {
      final permissionStatus = await Permission.storage.request();

      return permissionStatus.isGranted;
    }
  }

  @override
  Future<String> getStorageDirectory() async {
    Directory directory;

    if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else if (ref.read(appPreferenceRepositoryProvider).storeDownloadsSDCard) {
      directory = await _getSDCard();
    } else {
      directory = await getApplicationSupportDirectory();
    }

    return join(directory.path, 'audiflow');
  }

  @override
  Future<bool> hasExternalStorage() async {
    return _getSDCard().then((_) => true).catchError((_) => false);
  }

  Future<Directory> _getSDCard() async {
    final appDocumentDir =
        (await getExternalStorageDirectories(type: StorageDirectory.podcasts))!;

    Directory? path;

    // If the directory contains the word 'emulated' we are
    // probably looking at a mapped user partition rather than
    // an actual SD card - so skip those and find the first
    // non-emulated directory.
    if (appDocumentDir.isNotEmpty) {
      // See if we can find the last card without emulated
      for (final d in appDocumentDir) {
        if (!d.path.contains('emulated')) {
          path = d.absolute;
        }
      }
    }

    if (path == null) {
      throw Exception('No SD card found');
    }

    return path;
  }

  /// Strips characters that are invalid for file and directory names.
  @override
  String safePath(String s) {
    return s.replaceAll(RegExp(r'[^\w\s]+'), '').trim();
  }

  @override
  String safeFile(String s) {
    return s.replaceAll(RegExp(r'[^\w\s.]+'), '').trim();
  }
}
