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
  });

  final NowPlayingArtworkPreparer _preparer;

  /// `<applicationId>.carartwork`, as declared in AndroidManifest.xml.
  final String _authority;

  @override
  Future<Uri?> resolve(String artworkUrl) async {
    final file = await _preparer.prepare(artworkUrl);
    if (file == null) return null;
    return Uri(
      scheme: 'content',
      host: _authority,
      pathSegments: [file.pathSegments.last],
    );
  }
}
