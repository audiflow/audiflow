import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Resolves the perceived brightness of an artwork image.
///
/// Decodes the image at a small size and samples pixels from the top
/// edge to determine whether the overlay area is dark or light.
class ArtworkBrightnessResolver {
  ArtworkBrightnessResolver._();

  static const double _luminanceThreshold = 0.5;
  static const int _decodeSize = 24;

  /// Resolves brightness from an [ImageProvider].
  ///
  /// Returns [Brightness.dark] if the top edge of the image is dark,
  /// or as a fallback when extraction fails.
  static Future<Brightness> resolve(ImageProvider provider) async {
    try {
      final smallProvider = ResizeImage(
        provider,
        width: _decodeSize,
        height: _decodeSize,
      );

      final image = await _resolveImage(smallProvider);
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawStraightRgba,
      );
      if (byteData == null) return Brightness.dark;

      final luminance = _topEdgeLuminance(byteData, image.width, image.height);
      return luminance < _luminanceThreshold
          ? Brightness.dark
          : Brightness.light;
    } catch (_) {
      // Catch all errors (including FlutterError/Error from the image
      // pipeline) to guarantee the fallback is always returned.
      return Brightness.dark;
    }
  }

  /// Average luminance of the top 25% rows of the image.
  static double _topEdgeLuminance(ByteData bytes, int width, int height) {
    final rowCount = (height * 0.25).ceil().clamp(1, height);
    final pixelCount = width * rowCount;
    var totalLuminance = 0.0;

    for (var y = 0; y < rowCount; y++) {
      for (var x = 0; x < width; x++) {
        final offset = (y * width + x) * 4;
        final r = bytes.getUint8(offset) / 255.0;
        final g = bytes.getUint8(offset + 1) / 255.0;
        final b = bytes.getUint8(offset + 2) / 255.0;
        // Relative luminance (ITU-R BT.709)
        totalLuminance += 0.2126 * r + 0.7152 * g + 0.0722 * b;
      }
    }

    return totalLuminance / pixelCount;
  }

  static Future<ui.Image> _resolveImage(ImageProvider provider) {
    final completer = Completer<ui.Image>();
    final stream = provider.resolve(ImageConfiguration.empty);
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        completer.complete(info.image);
        stream.removeListener(listener);
      },
      onError: (error, _) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
    return completer.future;
  }
}
