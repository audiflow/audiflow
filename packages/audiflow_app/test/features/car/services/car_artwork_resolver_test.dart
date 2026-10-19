import 'dart:async';

import 'package:audiflow_app/features/car/services/car_artwork_resolver.dart';
import 'package:audiflow_app/features/player/services/now_playing_artwork_preparer.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

/// Holds every prepare until [finish] is called for its URL.
class _HeldPreparer implements NowPlayingArtworkPreparer {
  final pending = <String, Completer<Uri?>>{};
  int running = 0;
  int maxRunning = 0;

  void finish(String url, Uri? file) => pending.remove(url)!.complete(file);

  @override
  Future<Uri?> prepare(String artworkUrl) async {
    running++;
    if (maxRunning < running) maxRunning = running;
    final completer = Completer<Uri?>();
    pending[artworkUrl] = completer;
    try {
      return await completer.future;
    } finally {
      running--;
    }
  }
}

void main() {
  const authority = 'com.example.carartwork';
  late _HeldPreparer preparer;
  late ContentProviderArtworkResolver resolver;

  setUp(() {
    preparer = _HeldPreparer();
    resolver = ContentProviderArtworkResolver(
      preparer: preparer,
      authority: authority,
      maxConcurrent: 2,
    );
  });

  test('maps the prepared file to a content URI by file name', () async {
    const url = 'https://example.com/a.jpg';
    final pendingUri = resolver.resolve(url);
    await pumpEventQueue();
    final file = Uri.file('/cache/car_artwork/0123abcd.png');
    preparer.finish(url, file);

    check(await pendingUri).equals(
      Uri(scheme: 'content', host: authority, pathSegments: ['0123abcd.png']),
    );
  });

  test('returns null when the artwork cannot be prepared', () async {
    const url = 'https://example.com/missing.jpg';
    final pendingUri = resolver.resolve(url);
    await pumpEventQueue();
    preparer.finish(url, null);

    check(await pendingUri).isNull();
  });

  test('prepares at most maxConcurrent images at once', () async {
    final urls = [for (var i = 0; i < 5; i++) 'https://example.com/$i.jpg'];
    final results = [for (final url in urls) resolver.resolve(url)];
    await pumpEventQueue();
    check(preparer.running).equals(2);

    for (final url in urls) {
      await pumpEventQueue();
      preparer.finish(url, Uri.file('/cache/$url'));
    }
    await Future.wait(results);

    check(preparer.maxRunning).equals(2);
  });
}
