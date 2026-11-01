import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'artwork_downscaler.dart';
import 'content_uri_artwork_preparer.dart';
import 'now_playing_artwork_fetcher.dart';
import 'now_playing_artwork_preparer.dart';

part 'now_playing_artwork_provider.g.dart';

/// Subdirectory of the app cache that holds downscaled media-control art.
///
/// Must match `CarArtworkProvider.FOLDERS` (Android), which serves it.
const nowPlayingArtworkCacheFolder = 'now_playing_artwork';

/// Prepares local, downscaled artwork for the system media controls.
///
/// On Android the files are handed out as `content:` URIs, which media
/// hosts outside the app (Android Auto, Android Automotive, System UI) can
/// open; iOS reads the `file:` URI inside the app.
@Riverpod(keepAlive: true)
NowPlayingArtworkPreparer nowPlayingArtworkPreparer(Ref ref) {
  final files = buildArtworkPreparer(
    dio: ref.watch(dioProvider),
    cacheDir: ref.watch(cacheDirProvider),
    folder: nowPlayingArtworkCacheFolder,
    logger: ref.watch(namedLoggerProvider('NowPlayingArtwork')),
  );
  if (defaultTargetPlatform != TargetPlatform.android) return files;
  return ContentUriArtworkPreparer(
    inner: files,
    authority: artworkProviderAuthority(),
    folder: nowPlayingArtworkCacheFolder,
  );
}

/// A preparer caching downscaled artwork under `<cacheDir>/<folder>`.
///
/// Shared by the media-control artwork and the Android Auto row artwork,
/// which differ only in folder, size, and how many files they keep.
FileNowPlayingArtworkPreparer buildArtworkPreparer({
  required Dio dio,
  required String cacheDir,
  required String folder,
  required Logger logger,
  int maxEdgePixels = nowPlayingArtworkMaxEdgePixels,
  int entryLimit = nowPlayingArtworkCacheEntryLimit,
}) {
  return FileNowPlayingArtworkPreparer(
    cacheDirectory: Directory('$cacheDir/$folder'),
    fetchBytes: NowPlayingArtworkFetcher(dio: dio).fetch,
    downscale: downscaleArtworkToPng,
    logger: logger,
    maxEdgePixels: maxEdgePixels,
    entryLimit: entryLimit,
  );
}
