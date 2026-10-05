import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

/// Magic bytes followed by junk no decoder accepts, so a passing test proves
/// the bytes were never decoded.
Uint8List _undecodable(List<int> magic) =>
    Uint8List.fromList([...magic, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05]);

Future<Uint8List> _png(int width, int height) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawColor(const ui.Color(0xFF3366CC), ui.BlendMode.src);
  final image = await recorder.endRecording().toImage(width, height);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

void main() {
  group('PassthroughArtworkEncoder', () {
    const encoder = PassthroughArtworkEncoder();

    final cases = <String, List<int>>{
      'jpg': [0xFF, 0xD8, 0xFF, 0xE0],
      'png': [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
      'gif': 'GIF89a'.codeUnits,
    };
    for (final MapEntry(key: extension, value: magic) in cases.entries) {
      test('keeps $extension bytes as-is with a .$extension name', () async {
        final bytes = _undecodable(magic);

        final artwork = await encoder.encode(bytes);

        check(artwork.bytes).deepEquals(bytes);
        check(artwork.extension).equals(extension);
      });
    }

    test('rejects formats iOS attachments do not accept', () async {
      final webp = _undecodable([
        ...'RIFF'.codeUnits,
        ...[0x00, 0x00, 0x00, 0x00],
        ...'WEBP'.codeUnits,
      ]);

      await check(
        encoder.encode(webp),
      ).throws<UnsupportedArtworkFormatException>();
    });

    test('rejects bytes too short to identify', () async {
      await check(
        encoder.encode(Uint8List.fromList([0xFF, 0xD8])),
      ).throws<UnsupportedArtworkFormatException>();
    });
  });

  group('DownscalingArtworkEncoder', () {
    testWidgets('re-encodes as a PNG thumbnail', (tester) async {
      await tester.runAsync(() async {
        const encoder = DownscalingArtworkEncoder(width: 32);

        final artwork = await encoder.encode(await _png(128, 64));

        check(artwork.extension).equals('png');
        final codec = await ui.instantiateImageCodec(artwork.bytes);
        final image = (await codec.getNextFrame()).image;
        check(image.width).equals(32);
        check(image.height).equals(16);
        image.dispose();
      });
    });
  });
}
