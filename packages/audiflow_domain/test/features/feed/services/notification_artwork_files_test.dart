import 'dart:async';
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
        downloadTimeout: const Duration(milliseconds: 50),
      );

      await check(files.fileFor(_url, 1)).throws<DioException>();
      check(adapter.cancelled).isTrue();
    });
  });
}
