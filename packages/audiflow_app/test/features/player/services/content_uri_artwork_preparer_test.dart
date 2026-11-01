import 'package:audiflow_app/features/player/services/content_uri_artwork_preparer.dart';
import 'package:audiflow_app/features/player/services/now_playing_artwork_preparer.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

class _FixedPreparer implements NowPlayingArtworkPreparer {
  _FixedPreparer(this.result);

  final Uri? result;

  @override
  Future<Uri?> prepare(String artworkUrl) async => result;
}

void main() {
  const authority = 'com.example.carartwork';

  test('maps the prepared file to a content URI by folder and name', () async {
    final preparer = ContentUriArtworkPreparer(
      inner: _FixedPreparer(Uri.file('/cache/now_playing_artwork/0a1b.png')),
      authority: Future.value(authority),
      folder: 'now_playing_artwork',
    );

    check(await preparer.prepare('https://example.com/a.jpg')).equals(
      Uri(
        scheme: 'content',
        host: authority,
        pathSegments: ['now_playing_artwork', '0a1b.png'],
      ),
    );
  });

  test('returns null when the artwork cannot be prepared', () async {
    final preparer = ContentUriArtworkPreparer(
      inner: _FixedPreparer(null),
      authority: Future.value(authority),
      folder: 'now_playing_artwork',
    );

    check(await preparer.prepare('https://example.com/a.jpg')).isNull();
  });

  test('artworkContentUri names the folder before the file', () {
    check(
      artworkContentUri(
        authority: authority,
        folder: 'car_artwork',
        file: Uri.file('/cache/car_artwork/ff00.png'),
      ),
    ).equals(
      Uri(
        scheme: 'content',
        host: authority,
        pathSegments: ['car_artwork', 'ff00.png'],
      ),
    );
  });
}
