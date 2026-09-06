import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';

import 'artwork_downscaler.dart';

/// Long-edge limit for the artwork handed to the system media controls.
///
/// The iOS lock screen renders the thumbnail well under this size, and
/// the Android plugin downscales again to its own configured size, so
/// nothing larger is ever needed. Podcast artwork is commonly 3000 px,
/// which is about 36 MB decoded; 512 px is about 1 MB.
const nowPlayingArtworkMaxEdgePixels = 512;

/// Fetches the encoded bytes for an artwork URL, or null when unavailable.
typedef ArtworkBytesFetcher = Future<Uint8List?> Function(String url);

/// Produces a local `file:` URI for a remote artwork URL.
///
/// audio_service passes a `file:` [Uri] straight to the platform on every
/// media item update, whereas a remote URL is downloaded asynchronously and
/// the follow-up update is dropped whenever another update lands first.
abstract interface class NowPlayingArtworkPreparer {
  /// Returns a `file:` URI ready for `MediaItem.artUri`, or null when the
  /// artwork could not be fetched or decoded.
  Future<Uri?> prepare(String artworkUrl);
}

/// Downloads artwork once, downscales it, and caches the result as a PNG
/// named by the URL hash under [cacheDirectory].
class FileNowPlayingArtworkPreparer implements NowPlayingArtworkPreparer {
  FileNowPlayingArtworkPreparer({
    required this._cacheDirectory,
    required this._fetchBytes,
    required this._downscale,
    required this._logger,
    this._maxEdgePixels = nowPlayingArtworkMaxEdgePixels,
  });

  final Directory _cacheDirectory;
  final ArtworkBytesFetcher _fetchBytes;
  final ArtworkDownscaler _downscale;
  final Logger _logger;
  final int _maxEdgePixels;

  /// Rapid re-syncs of the same episode must share a single download.
  final Map<String, Future<Uri?>> _inFlight = {};

  @override
  Future<Uri?> prepare(String artworkUrl) {
    final pending = _inFlight[artworkUrl];
    if (pending != null) return pending;
    final future = _prepareGuarded(artworkUrl);
    _inFlight[artworkUrl] = future;
    return future.whenComplete(() => _inFlight.remove(artworkUrl));
  }

  Future<Uri?> _prepareGuarded(String artworkUrl) async {
    try {
      return await _prepareOrNull(artworkUrl);
    } on Exception catch (e, stack) {
      // Artwork is decorative; playback metadata must not fail because
      // of it, so the caller falls back to the remote URL instead.
      _logger.w(
        '[NowPlayingArtwork] Failed to prepare $artworkUrl',
        error: e,
        stackTrace: stack,
      );
      return null;
    }
  }

  Future<Uri?> _prepareOrNull(String artworkUrl) async {
    final target = _fileFor(artworkUrl);
    if (await target.exists()) return target.uri;
    final encoded = await _fetchBytes(artworkUrl);
    if (encoded == null) return null;
    final scaled = await _downscale(encoded, _maxEdgePixels);
    if (scaled == null) return null;
    await _writeAtomically(target, scaled);
    return target.uri;
  }

  File _fileFor(String artworkUrl) {
    final hash = md5.convert(utf8.encode(artworkUrl)).toString();
    return File('${_cacheDirectory.path}/$hash.png');
  }

  /// Writes through a temporary name so a crash mid-write cannot leave a
  /// truncated PNG that would be served as a cache hit forever after.
  Future<void> _writeAtomically(File target, Uint8List bytes) async {
    await _cacheDirectory.create(recursive: true);
    final temp = File('${target.path}.part');
    await temp.writeAsBytes(bytes, flush: true);
    await temp.rename(target.path);
  }
}
