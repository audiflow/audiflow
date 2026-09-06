import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'artwork_downscaler.dart';
import 'now_playing_artwork_fetcher.dart';
import 'now_playing_artwork_preparer.dart';

part 'now_playing_artwork_provider.g.dart';

/// Subdirectory of the app cache that holds downscaled media-control art.
const nowPlayingArtworkCacheFolder = 'now_playing_artwork';

/// Prepares local, downscaled artwork files for the system media controls.
@Riverpod(keepAlive: true)
NowPlayingArtworkPreparer nowPlayingArtworkPreparer(Ref ref) {
  final fetcher = NowPlayingArtworkFetcher(dio: ref.watch(dioProvider));
  return FileNowPlayingArtworkPreparer(
    cacheDirectory: Directory(
      '${ref.watch(cacheDirProvider)}/$nowPlayingArtworkCacheFolder',
    ),
    fetchBytes: fetcher.fetch,
    downscale: downscaleArtworkToPng,
    logger: ref.watch(namedLoggerProvider('NowPlayingArtwork')),
  );
}
