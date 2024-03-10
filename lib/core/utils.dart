// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:audiflow/entities/app_settings.dart';
import 'package:audiflow/entities/downloadable.dart';
import 'package:audiflow/entities/episode.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Returns the storage directory for the current platform.
///
/// On iOS, the directory that the app has available to it for storing episodes
/// may change between updates, whereas on Android we are able to save the full
/// path. To ensure we can handle the directory name change on iOS without
/// breaking existing Android installations we have created the following three
/// functions to help with resolving the various paths correctly depending upon
/// platform.
Future<String> resolvePath(
  AppSettings settings,
  Downloadable download,
) async {
  return Platform.isAndroid
      ? join(download.directory, download.filename)
      : join(
          await getStorageDirectory(settings),
          download.directory,
          download.filename,
        );
}

Future<String> directoryToRecord(
  AppSettings settings,
  Episode episode,
) async {
  return Platform.isAndroid
      ? join(await getStorageDirectory(settings), safePath(episode.guid))
      : safePath(episode.guid);
}

Future<String> createDownloadDirectory(
  AppSettings settings,
  Episode episode,
) async {
  final path =
      join(await getStorageDirectory(settings), safePath(episode.guid));
  Directory(path).createSync(recursive: true);
  return path;
}

Future<bool> hasStoragePermission(AppSettings settings) async {
  if (Platform.isIOS || !settings.storeDownloadsSDCard) {
    return Future.value(true);
  } else {
    final permissionStatus = await Permission.storage.request();

    return Future.value(permissionStatus.isGranted);
  }
}

Future<String> getStorageDirectory(AppSettings settings) async {
  Directory directory;

  if (Platform.isIOS) {
    directory = await getApplicationDocumentsDirectory();
  } else if (settings.storeDownloadsSDCard) {
    directory = await _getSDCard();
  } else {
    directory = await getApplicationSupportDirectory();
  }

  return join(directory.path, 'AnyTime');
}

Future<bool> hasExternalStorage() async {
  try {
    await _getSDCard();

    return Future.value(true);
    // ignore: avoid_catches_without_on_clauses
  } catch (e) {
    return Future.value(false);
  }
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
String safePath(String s) {
  return s.replaceAll(RegExp(r'[^\w\s]+'), '').trim();
}

String safeFile(String s) {
  return s.replaceAll(RegExp(r'[^\w\s.]+'), '').trim();
}

Future<String> resolveUrl(String url, {bool forceHttps = false}) async {
  final client = HttpClient();
  var uri = Uri.parse(url);
  var request = await client.getUrl(uri);

  request.followRedirects = false;

  var response = await request.close();

  while (response.isRedirect) {
    await response.drain(0);
    final location = response.headers.value(HttpHeaders.locationHeader);
    if (location != null) {
      uri = uri.resolve(location);
      request = await client.getUrl(uri)
        // Set the body or headers as desired.
        ..followRedirects = false;
      response = await request.close();
    }
  }

  if (uri.scheme == 'http') {
    uri = uri.replace(scheme: 'https');
  }

  return uri.toString();
}

final descriptionRegExp1 =
    RegExp(r'(</p><br>|</p></br>|<p><br></p>|<p></br></p>)');
final descriptionRegExp2 = RegExp(r'(<p><br></p>|<p></br></p>)');

/// Remove HTML padding from the content. The padding may look fine within
/// the context of a browser, but can look out of place on a mobile screen.
String removeHtmlPadding(String? input) {
  return input
          ?.trim()
          .replaceAll(descriptionRegExp2, '')
          .replaceAll(descriptionRegExp1, '</p>') ??
      '';
}

Duration minDuration(Duration a, Duration b) {
  return a < b ? a : b;
}

Duration maxDuration(Duration a, Duration b) {
  return b < a ? a : b;
}

Duration? normalizedDuration({
  Duration? position,
  Duration? duration,
}) {
  return position == null || duration == null
      ? Duration.zero
      : maxDuration(Duration.zero, minDuration(position, duration));
}
