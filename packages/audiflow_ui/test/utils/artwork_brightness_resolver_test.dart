import 'dart:ui' as ui;

import 'package:audiflow_ui/src/utils/artwork_brightness_resolver.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Creates a 1x1 image filled with [color].
Future<ImageProvider> _solidImageProvider(Color color) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(const Rect.fromLTWH(0, 0, 1, 1), Paint()..color = color);
  final picture = recorder.endRecording();
  final image = await picture.toImage(1, 1);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return MemoryImage(byteData!.buffer.asUint8List());
}

void main() {
  group('ArtworkBrightnessResolver', () {
    testWidgets('returns Brightness.dark for dark image', (tester) async {
      // tester.runAsync is required for operations that interact with the
      // Flutter image pipeline, which does not resolve without pumping.
      final result = await tester.runAsync(() async {
        final provider = await _solidImageProvider(const Color(0xFF1A1A2E));
        return ArtworkBrightnessResolver.resolve(provider);
      });
      check(result).equals(Brightness.dark);
    });

    testWidgets('returns Brightness.light for light image', (tester) async {
      final result = await tester.runAsync(() async {
        final provider = await _solidImageProvider(const Color(0xFFFFF8E1));
        return ArtworkBrightnessResolver.resolve(provider);
      });
      check(result).equals(Brightness.light);
    });

    testWidgets('returns Brightness.dark as fallback on error', (tester) async {
      // Suppress the image-loading error that Flutter's test binding reports
      // when a NetworkImage fails — our code handles this gracefully.
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (_) {};
      addTearDown(() => FlutterError.onError = originalOnError);

      // An invalid provider that will fail to resolve
      const provider = NetworkImage('https://invalid.test/no-image.png');
      final result = await tester.runAsync(
        () => ArtworkBrightnessResolver.resolve(provider),
      );
      check(result).equals(Brightness.dark);
    });
  });
}
