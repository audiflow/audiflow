import 'package:package_info_plus/package_info_plus.dart';

import 'now_playing_artwork_preparer.dart';

/// Authority of `CarArtworkProvider`: `<applicationId>.carartwork`, as
/// declared in AndroidManifest.xml.
Future<String> artworkProviderAuthority() async {
  final packageInfo = await PackageInfo.fromPlatform();
  return '${packageInfo.packageName}.carartwork';
}

/// The `content:` URI under which `CarArtworkProvider` (Android) serves
/// [file], a prepared artwork file in the cache subdirectory [folder].
Uri artworkContentUri({
  required String authority,
  required String folder,
  required Uri file,
}) {
  return Uri(
    scheme: 'content',
    host: authority,
    pathSegments: [folder, file.pathSegments.last],
  );
}

/// Hands out prepared artwork as `content:` URIs instead of `file:` URIs.
///
/// Media hosts outside the app (Android Auto, Android Automotive's media
/// center, System UI) load the session's artwork by URI and cannot open a
/// file in the app's private cache, so a `file:` URI leaves them without
/// artwork. audio_service still decodes the bitmap itself through the same
/// provider.
class ContentUriArtworkPreparer implements NowPlayingArtworkPreparer {
  ContentUriArtworkPreparer({
    required this._inner,
    required this._authority,
    required this._folder,
  });

  final NowPlayingArtworkPreparer _inner;

  /// See [artworkProviderAuthority]; a future because the package name is
  /// only known asynchronously.
  final Future<String> _authority;

  /// Cache subdirectory [_inner] writes to.
  final String _folder;

  @override
  Future<Uri?> prepare(String artworkUrl) async {
    final file = await _inner.prepare(artworkUrl);
    if (file == null) return null;
    return artworkContentUri(
      authority: await _authority,
      folder: _folder,
      file: file,
    );
  }
}
