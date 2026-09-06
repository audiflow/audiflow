import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:audiflow_app/features/player/services/artwork_downscaler.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders a solid image of the given size and returns its PNG bytes.
Future<Uint8List> _pngOfSize(int width, int height) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    ui.Paint()..color = const ui.Color(0xFF3366CC),
  );
  final image = await recorder.endRecording().toImage(width, height);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

Future<(int, int)> _decodedSize(Uint8List png) async {
  final codec = await ui.instantiateImageCodec(png);
  final frame = await codec.getNextFrame();
  final size = (frame.image.width, frame.image.height);
  frame.image.dispose();
  codec.dispose();
  return size;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('downscaleArtworkToPng', () {
    test('shrinks the long edge to the limit and keeps aspect ratio', () async {
      final source = await _pngOfSize(64, 32);

      final result = await downscaleArtworkToPng(source, 16);

      check(result).isNotNull();
      check(await _decodedSize(result!)).equals((16, 8));
    });

    test('limits the height when the image is taller than wide', () async {
      final source = await _pngOfSize(20, 40);

      final result = await downscaleArtworkToPng(source, 10);

      check(await _decodedSize(result!)).equals((5, 10));
    });

    test('never upscales images already within the limit', () async {
      final source = await _pngOfSize(8, 8);

      final result = await downscaleArtworkToPng(source, 16);

      check(await _decodedSize(result!)).equals((8, 8));
    });

    test('keeps a banner-shaped short edge at one pixel', () async {
      final source = await _pngOfSize(300, 1);

      final result = await downscaleArtworkToPng(source, 16);

      check(await _decodedSize(result!)).equals((16, 1));
    });

    test('returns null for bytes that are not an image', () async {
      final result = await downscaleArtworkToPng(
        Uint8List.fromList([1, 2, 3, 4]),
        16,
      );

      check(result).isNull();
    });
  });
}
