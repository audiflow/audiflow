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
  late Directory cacheDirectory;
  late _Recorder recorder;
  late FileNowPlayingArtworkPreparer preparer;

  /// Builds a preparer over the same cache directory and fake fetcher,
  /// keeping at most [entryLimit] prepared files.
  FileNowPlayingArtworkPreparer buildPreparer({required int entryLimit}) =>
      FileNowPlayingArtworkPreparer(
        cacheDirectory: cacheDirectory,
        fetchBytes: recorder.fetch,
        downscale: recorder.downscale,
        logger: Logger(level: Level.off),
        maxEdgePixels: 100,
        entryLimit: entryLimit,
      );

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'now_playing_artwork_',
    );
    cacheDirectory = Directory('${tempDirectory.path}/nested');
    recorder = _Recorder();
    preparer = buildPreparer(entryLimit: nowPlayingArtworkCacheEntryLimit);
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

    test('deletes the oldest files once the limit is reached', () async {
      final bounded = buildPreparer(entryLimit: 2);
      final oldest = await bounded.prepare('https://example.com/1.jpg');
      File.fromUri(oldest!).setLastModifiedSync(DateTime(2020));
      final middle = await bounded.prepare('https://example.com/2.jpg');
      File.fromUri(middle!).setLastModifiedSync(DateTime(2021));

      final newest = await bounded.prepare('https://example.com/3.jpg');

      check(File.fromUri(oldest).existsSync()).isFalse();
      check(File.fromUri(middle).existsSync()).isTrue();
      check(File.fromUri(newest!).existsSync()).isTrue();
    });

    test('refreshes the timestamp of a reused file', () async {
      final uri = await preparer.prepare(_url);
      File.fromUri(uri!).setLastModifiedSync(DateTime(2020));

      await preparer.prepare(_url);

      check(
        File.fromUri(uri).lastModifiedSync().isAfter(DateTime(2021)),
      ).isTrue();
    });

    test('deletes temp files abandoned by an earlier run', () async {
      await cacheDirectory.create(recursive: true);
      final stale = File('${cacheDirectory.path}/abandoned.png.part')
        ..writeAsBytesSync([0]);
      stale.setLastModifiedSync(DateTime(2020));
      final fresh = File('${cacheDirectory.path}/inflight.png.part')
        ..writeAsBytesSync([0]);

      await preparer.prepare(_url);

      check(stale.existsSync()).isFalse();
      check(fresh.existsSync()).isTrue();
    });

    test('never deletes the artwork it just prepared', () async {
      final bounded = buildPreparer(entryLimit: 1);
      final first = await bounded.prepare('https://example.com/1.jpg');
      File.fromUri(first!).setLastModifiedSync(DateTime(2020));

      final second = await bounded.prepare('https://example.com/2.jpg');

      check(File.fromUri(first).existsSync()).isFalse();
      check(File.fromUri(second!).existsSync()).isTrue();
    });

    test('spares entries still inside the eviction grace period', () async {
      final bounded = buildPreparer(entryLimit: 1);
      final recent = await bounded.prepare('https://example.com/1.jpg');

      final newest = await bounded.prepare('https://example.com/2.jpg');

      // A prepare racing another must not delete the file that one is
      // about to publish, even with the cache over its limit.
      check(File.fromUri(recent!).existsSync()).isTrue();
      check(File.fromUri(newest!).existsSync()).isTrue();
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
