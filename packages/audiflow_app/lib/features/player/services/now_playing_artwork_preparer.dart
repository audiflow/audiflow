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

/// Maximum number of prepared artwork files kept on disk.
///
/// One file lands per distinct artwork URL played, so without a bound the
/// directory would grow for the life of the install. Recently played
/// artwork stays cached; anything older is prepared again on demand.
const nowPlayingArtworkCacheEntryLimit = 32;

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
    this._entryLimit = nowPlayingArtworkCacheEntryLimit,
  });

  final Directory _cacheDirectory;
  final ArtworkBytesFetcher _fetchBytes;
  final ArtworkDownscaler _downscale;
  final Logger _logger;
  final int _maxEdgePixels;
  final int _entryLimit;

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
    await _pruneToLimit(keep: target);
    return target.uri;
  }

  /// Deletes the oldest entries until at most [_entryLimit] remain.
  ///
  /// Never fails the caller: the artwork this call prepared is already on
  /// disk, and a full cache directory is better than no lock-screen art.
  Future<void> _pruneToLimit({required File keep}) async {
    try {
      final entries = await _cachedFiles(keep: keep);
      if (entries.length < _entryLimit) return;
      final excess = entries.length - _entryLimit + 1;
      for (final entry in (await _oldestFirst(entries)).take(excess)) {
        await entry.delete();
      }
    } on Exception catch (e) {
      _logger.d('[NowPlayingArtwork] Cache prune skipped: $e');
    }
  }

  /// Prepared PNGs other than [keep]; partial writes are named `.png.part`
  /// and so are excluded by the suffix test.
  Future<List<File>> _cachedFiles({required File keep}) => _cacheDirectory
      .list()
      .where(
        (entity) =>
            entity is File &&
            entity.path.endsWith('.png') &&
            entity.path != keep.path,
      )
      .cast<File>()
      .toList();

  Future<List<File>> _oldestFirst(List<File> files) async {
    final stamped = <({File file, DateTime modified})>[];
    for (final file in files) {
      stamped.add((file: file, modified: (await file.stat()).modified));
    }
    stamped.sort((first, second) => first.modified.compareTo(second.modified));
    return [for (final entry in stamped) entry.file];
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
