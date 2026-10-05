import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _BytesAdapter implements HttpClientAdapter {
  _BytesAdapter(this.bytes);

  final Uint8List bytes;
  int requests = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests++;
    return ResponseBody.fromBytes(bytes, 200);
  }

  @override
  void close({bool force = false}) {}
}

/// Never answers; completes only when the request is cancelled.
class _HangingAdapter implements HttpClientAdapter {
  bool cancelled = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await cancelFuture;
    cancelled = true;
    throw DioException.requestCancelled(
      requestOptions: options,
      reason: 'cancelled',
    );
  }

  @override
  void close({bool force = false}) {}
}

Future<Uint8List> _png(int width, int height) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawColor(const ui.Color(0xFF3366CC), ui.BlendMode.src);
  final image = await recorder.endRecording().toImage(width, height);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

Future<ui.Size> _decodedSize(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final image = (await codec.getNextFrame()).image;
  final size = ui.Size(image.width.toDouble(), image.height.toDouble());
  image.dispose();
  return size;
}

Future<Directory> _tempDirectory() async {
  final directory = await Directory.systemTemp.createTemp('artwork');
  addTearDown(() => directory.delete(recursive: true));
  return directory;
}

const _url = 'https://example.com/a.jpg';

// Real 1x1 images (PNG from zlib, JPEG from sips with metadata stripped), so
// passthrough is exercised with content iOS would actually receive.
final _validPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGMwTjsDAAI1AWaKkkQyAAAAAElFTkSuQmCC',
);
final _validJpeg = base64Decode(
  '/9j/4AAQSkZJRgABAQAASABIAAD/wAARCAABAAEDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9sAQwACAgICAgIDAgIDBQMDAwUGBQUFBQYIBgYGBgYICggICAgICAoKCgoKCgoKDAwMDAwMDg4ODg4PDw8PDw8PDw8P/9sAQwECAgIEBAQHBAQHEAsJCxAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQ/90ABAAB/9oADAMBAAIRAxEAPwDweiiiv7wP53P/2Q==',
);

/// Records what it is given and labels the output with a fixed extension.
class _RecordingEncoder implements NotificationArtworkEncoder {
  final inputs = <Uint8List>[];

  @override
  Future<EncodedArtwork> encode(Uint8List bytes) async {
    inputs.add(bytes);
    return EncodedArtwork(bytes: bytes, extension: 'jpg');
  }
}

void main() {
  testWidgets('writes a downscaled thumbnail per notification, fetching once', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final directory = await _tempDirectory();
      final adapter = _BytesAdapter(await _png(1024, 1024));
      final files = NotificationArtworkFiles(
        dio: Dio()..httpClientAdapter = adapter,
        directory: () async => directory,
        encoder: const DownscalingArtworkEncoder(),
      );

      final first = await files.fileFor(_url, 1);
      final second = await files.fileFor(_url, 2);

      check(first).not((it) => it.equals(second));
      check(adapter.requests).equals(1);
      final size = await _decodedSize(await File(first).readAsBytes());
      check(size).equals(const ui.Size(256, 256));
      check(File(second).existsSync()).isTrue();
    });
  });

  testWidgets('removes thumbnails left by earlier runs', (tester) async {
    await tester.runAsync(() async {
      final directory = await _tempDirectory();
      final stale = File('${directory.path}/99.png')..writeAsStringSync('x');
      final files = NotificationArtworkFiles(
        dio: Dio()..httpClientAdapter = _BytesAdapter(await _png(64, 64)),
        directory: () async => directory,
        encoder: const DownscalingArtworkEncoder(),
      );

      await files.fileFor(_url, 1);

      check(stale.existsSync()).isFalse();
    });
  });

  testWidgets('rejects artwork larger than the byte limit', (tester) async {
    await tester.runAsync(() async {
      final directory = await _tempDirectory();
      final files = NotificationArtworkFiles(
        dio: Dio()..httpClientAdapter = _BytesAdapter(Uint8List(2048)),
        directory: () async => directory,
        encoder: const DownscalingArtworkEncoder(),
        maxBytes: 1024,
      );

      await check(files.fileFor(_url, 1)).throws<StateError>();
    });
  });

  testWidgets('cancels a download that outlives its deadline', (tester) async {
    await tester.runAsync(() async {
      final directory = await _tempDirectory();
      final adapter = _HangingAdapter();
      final files = NotificationArtworkFiles(
        dio: Dio()..httpClientAdapter = adapter,
        directory: () async => directory,
        encoder: const DownscalingArtworkEncoder(),
        downloadTimeout: const Duration(milliseconds: 50),
      );

      await check(files.fileFor(_url, 1)).throws<DioException>();
      check(adapter.cancelled).isTrue();
    });
  });

  test('names files with the extension chosen by the encoder', () async {
    final directory = await _tempDirectory();
    final original = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0x01, 0x02]);
    final encoder = _RecordingEncoder();
    final files = NotificationArtworkFiles(
      dio: Dio()..httpClientAdapter = _BytesAdapter(original),
      directory: () async => directory,
      encoder: encoder,
    );

    final first = await files.fileFor(_url, 1);
    final second = await files.fileFor(_url, 2);

    check(first).equals('${directory.path}/1.jpg');
    check(second).equals('${directory.path}/2.jpg');
    check(encoder.inputs).length.equals(1);
    check(await File(first).readAsBytes()).deepEquals(original);
  });

  test('passthrough writes the original bytes without decoding', () async {
    final directory = await _tempDirectory();
    // A PNG signature followed by junk: decoding it would throw.
    final original = Uint8List.fromList([
      ...[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
      ...[0x00, 0x01, 0x02],
    ]);
    final files = NotificationArtworkFiles(
      dio: Dio()..httpClientAdapter = _BytesAdapter(original),
      directory: () async => directory,
      encoder: const PassthroughArtworkEncoder(),
    );

    final path = await files.fileFor(_url, 7);

    check(path).equals('${directory.path}/7.png');
    check(await File(path).readAsBytes()).deepEquals(original);
  });

  test('writes no file for an unrecognised format', () async {
    final directory = await _tempDirectory();
    final files = NotificationArtworkFiles(
      dio: Dio()..httpClientAdapter = _BytesAdapter(Uint8List(64)),
      directory: () async => directory,
      encoder: const PassthroughArtworkEncoder(),
    );

    await check(
      files.fileFor(_url, 1),
    ).throws<UnsupportedArtworkFormatException>();
    check(directory.listSync()).isEmpty();
  });

  for (final (extension, image) in [('png', _validPng), ('jpg', _validJpeg)]) {
    testWidgets('passthrough attaches a valid $extension byte-for-byte', (
      tester,
    ) async {
      await tester.runAsync(() async {
        // Guards the fixture itself: it must be a decodable image.
        check(await _decodedSize(image)).equals(const ui.Size(1, 1));
        final directory = await _tempDirectory();
        final files = NotificationArtworkFiles(
          dio: Dio()..httpClientAdapter = _BytesAdapter(image),
          directory: () async => directory,
          encoder: const PassthroughArtworkEncoder(),
        );

        final path = await files.fileFor(_url, 3);

        check(path).equals('${directory.path}/3.$extension');
        check(await File(path).readAsBytes()).deepEquals(image);
      });
    });
  }
}
