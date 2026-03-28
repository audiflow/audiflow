import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

/// Resolves the perceived brightness of an artwork image.
///
/// Uses [PaletteGenerator] to extract the dominant color, then
/// checks luminance against a threshold to classify as dark or light.
class ArtworkBrightnessResolver {
  ArtworkBrightnessResolver._();

  static const double _luminanceThreshold = 0.5;

  // Small target size for fast analysis — full resolution is unnecessary
  static const ui.Size _analysisSize = ui.Size(50, 50);

  /// Resolves brightness from an [ImageProvider].
  ///
  /// Returns [Brightness.dark] if the dominant color's luminance
  /// is below the threshold, or as a fallback when extraction fails.
  static Future<Brightness> resolve(ImageProvider provider) async {
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        provider,
        size: _analysisSize,
        maximumColorCount: 4, // Keep palette quantization cheap
      );
      final dominantColor = palette.dominantColor?.color;
      if (dominantColor == null) return Brightness.dark;

      return dominantColor.computeLuminance() < _luminanceThreshold
          ? Brightness.dark
          : Brightness.light;
    } on Exception {
      return Brightness.dark;
    }
  }
}
