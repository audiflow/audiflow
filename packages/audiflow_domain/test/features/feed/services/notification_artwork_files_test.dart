import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:audiflow_domain/audiflow_domain.dart';
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

void main() {
  testWidgets('writes a downscaled thumbnail per notification, fetching once', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final directory = await Directory.systemTemp.createTemp('artwork');
      addTearDown(() => directory.delete(recursive: true));
      final adapter = _BytesAdapter(await _png(1024, 1024));
      final files = NotificationArtworkFiles(
        dio: Dio()..httpClientAdapter = adapter,
        directory: directory,
      );

      final first = await files.fileFor('https://example.com/a.jpg', 1);
      final second = await files.fileFor('https://example.com/a.jpg', 2);

      expect(first, isNot(second));
      expect(adapter.requests, 1);
      final size = await _decodedSize(await File(first).readAsBytes());
      expect(size, const ui.Size(256, 256));
      expect(File(second).existsSync(), isTrue);
    });
  });
}
