import 'dart:async';
import 'dart:collection';

import '../../player/services/now_playing_artwork_preparer.dart';

/// Subdirectory of the app cache holding artwork for Android Auto rows.
///
/// Must match `CarArtworkProvider.FOLDER` (Android), which serves it.
const carArtworkCacheFolder = 'car_artwork';

/// Long edge of row artwork. Android Auto draws browse rows well under
/// this on any head unit.
const carArtworkMaxEdgePixels = 320;

/// Prepared files kept: about the rows of a few full lists.
const carArtworkCacheEntryLimit = 300;

/// Turns a remote artwork URL into a URI Android Auto can load.
abstract interface class CarArtworkResolver {
  /// The URI for [artworkUrl], or null when the artwork is unavailable.
  Future<Uri?> resolve(String artworkUrl);
}

/// Serves artwork through `CarArtworkProvider`.
///
/// Android Auto loads row artwork only from `content:` URIs (it cannot
/// fetch remote URLs), so the artwork is downloaded and downscaled into
/// [carArtworkCacheFolder] first, and the provider serves those files by
/// name. The provider never touches the network itself.
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

  @override
  Future<Uri?> resolve(String artworkUrl) async {
    await _acquire();
    try {
      final file = await _preparer.prepare(artworkUrl);
      if (file == null) return null;
      return Uri(
        scheme: 'content',
        host: _authority,
        pathSegments: [file.pathSegments.last],
      );
    } finally {
      _release();
    }
  }

  Future<void> _acquire() async {
    if (_running < _maxConcurrent) {
      _running++;
      return;
    }
    final turn = Completer<void>();
    _waiting.add(turn);
    // The releasing call hands its slot over, so _running is unchanged.
    await turn.future;
  }

  void _release() {
    if (_waiting.isNotEmpty) {
      _waiting.removeFirst().complete();
      return;
    }
    _running--;
  }
}
