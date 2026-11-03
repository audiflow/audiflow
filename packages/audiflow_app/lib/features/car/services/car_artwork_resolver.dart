import 'dart:async';
import 'dart:collection';

import '../../player/services/content_uri_artwork_preparer.dart';
import '../../player/services/now_playing_artwork_preparer.dart';

/// Subdirectory of the app cache holding artwork for Android Auto rows.
///
/// Must match `CarArtworkProvider.FOLDERS` (Android), which serves it.
const carArtworkCacheFolder = 'car_artwork';

/// Long edge of row artwork. Android Auto draws browse rows well under
/// this on any head unit.
const carArtworkMaxEdgePixels = 320;

/// Prepared files kept: about the rows of a few full lists.
const carArtworkCacheEntryLimit = 300;

/// Turns a remote artwork URL into a URI Android Auto can load.
abstract interface class CarArtworkResolver {
  /// The URI for [artworkUrl], or null when the artwork is unavailable.
  ///
  /// A [background] request waits behind every other: a list on screen waits
  /// at most a couple of seconds for its images, and must not spend them
  /// behind up to 100 rows of a queue nobody has opened.
  Future<Uri?> resolve(String artworkUrl, {bool background = false});
}

/// Serves artwork through `CarArtworkProvider`.
///
/// A `content:` URI gives the head unit a downscaled image and does not
/// depend on how it treats remote URLs, so the artwork is downloaded and
/// downscaled into [carArtworkCacheFolder] first, and the provider serves
/// those files by name. The provider never touches the network itself.
class ContentProviderArtworkResolver implements CarArtworkResolver {
  ContentProviderArtworkResolver({
    required this._preparer,
    required this._authority,
    this._maxConcurrent = 4,
  });

  final NowPlayingArtworkPreparer _preparer;

  /// `<applicationId>.carartwork`, as declared in AndroidManifest.xml.
  final String _authority;

  /// Downloads and decodes run at once. A list asks for up to 100 images,
  /// and each download buffers up to 8 MB before it is decoded.
  final int _maxConcurrent;

  int _running = 0;
  final Queue<Completer<void>> _waiting = Queue();
  final Queue<Completer<void>> _waitingInBackground = Queue();

  @override
  Future<Uri?> resolve(String artworkUrl, {bool background = false}) async {
    await _acquire(background ? _waitingInBackground : _waiting);
    try {
      final file = await _preparer.prepare(artworkUrl);
      if (file == null) return null;
      return artworkContentUri(
        authority: _authority,
        folder: carArtworkCacheFolder,
        file: file,
      );
    } finally {
      _release();
    }
  }

  Future<void> _acquire(Queue<Completer<void>> line) async {
    if (_running < _maxConcurrent) {
      _running++;
      return;
    }
    final turn = Completer<void>();
    line.add(turn);
    // The releasing call hands its slot over, so _running is unchanged.
    await turn.future;
  }

  void _release() {
    final line = _waiting.isNotEmpty ? _waiting : _waitingInBackground;
    if (line.isNotEmpty) {
      line.removeFirst().complete();
      return;
    }
    _running--;
  }
}
