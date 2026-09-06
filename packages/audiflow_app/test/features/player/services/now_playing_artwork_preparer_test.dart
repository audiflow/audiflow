import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audiflow_app/features/player/services/now_playing_artwork_preparer.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

const _url = 'https://example.com/art.jpg';
final _encoded = Uint8List.fromList([1, 2, 3]);
final _scaled = Uint8List.fromList([9, 8, 7]);

/// Records the fetch and downscale calls the preparer makes so tests
/// can assert on caching behavior without touching the network.
class _Recorder {
  final List<String> fetched = [];
  final List<int> downscaledTo = [];
  Uint8List? fetchResult = _encoded;
  Uint8List? downscaleResult = _scaled;
  Completer<Uint8List?>? fetchGate;
  Exception? fetchError;

  Future<Uint8List?> fetch(String url) async {
    fetched.add(url);
    final error = fetchError;
    if (error != null) throw error;
    final gate = fetchGate;
    if (gate != null) return gate.future;
    return fetchResult;
  }

  Future<Uint8List?> downscale(Uint8List bytes, int maxEdgePixels) async {
    downscaledTo.add(maxEdgePixels);
    return downscaleResult;
  }
}

void main() {
  late Directory tempDirectory;
  late _Recorder recorder;
  late FileNowPlayingArtworkPreparer preparer;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'now_playing_artwork_',
    );
    recorder = _Recorder();
    preparer = FileNowPlayingArtworkPreparer(
      cacheDirectory: Directory('${tempDirectory.path}/nested'),
      fetchBytes: recorder.fetch,
      downscale: recorder.downscale,
      logger: Logger(level: Level.off),
      maxEdgePixels: 100,
    );
  });

  tearDown(() => tempDirectory.delete(recursive: true));

  group('FileNowPlayingArtworkPreparer', () {
    test('downloads, downscales, and writes a file URI', () async {
      final uri = await preparer.prepare(_url);

      check(uri).isNotNull();
      check(uri!.scheme).equals('file');
      check(uri.path).endsWith('.png');
      check(File.fromUri(uri).readAsBytesSync()).deepEquals(_scaled);
      check(recorder.fetched).deepEquals([_url]);
      check(recorder.downscaledTo).deepEquals([100]);
    });

    test('reuses the prepared file on the next call', () async {
      final first = await preparer.prepare(_url);
      final second = await preparer.prepare(_url);

      check(second).equals(first);
      check(recorder.fetched.length).equals(1);
    });

    test('uses distinct files for distinct URLs', () async {
      final firstUri = await preparer.prepare(_url);
      final otherUri = await preparer.prepare('https://example.com/other.jpg');

      check(firstUri).not((it) => it.equals(otherUri));
    });

    test('shares one in-flight download between concurrent calls', () async {
      recorder.fetchGate = Completer();

      final first = preparer.prepare(_url);
      final second = preparer.prepare(_url);
      recorder.fetchGate!.complete(_encoded);

      check(await first).equals(await second);
      check(recorder.fetched.length).equals(1);
    });

    test('returns null when the download yields nothing', () async {
      recorder.fetchResult = null;

      check(await preparer.prepare(_url)).isNull();
      check(recorder.downscaledTo).isEmpty();
    });

    test('returns null when the bytes cannot be decoded', () async {
      recorder.downscaleResult = null;

      check(await preparer.prepare(_url)).isNull();
      check(Directory('${tempDirectory.path}/nested').existsSync()).isFalse();
    });

    test('returns null instead of throwing when the fetch fails', () async {
      recorder.fetchError = const SocketException('offline');

      check(await preparer.prepare(_url)).isNull();
    });

    test('retries after a failed attempt', () async {
      recorder.fetchResult = null;
      await preparer.prepare(_url);
      recorder.fetchResult = _encoded;

      check(await preparer.prepare(_url)).isNotNull();
      check(recorder.fetched.length).equals(2);
    });
  });
}
