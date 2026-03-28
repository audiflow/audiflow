import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

/// Resolves the perceived brightness of an artwork image.
///
/// Uses [PaletteGenerator] to extract the dominant color, then
/// checks luminance against a threshold to classify as dark or light.
class ArtworkBrightnessResolver {
  ArtworkBrightnessResolver._();

  static const double _luminanceThreshold = 0.5;

  /// Resolves brightness from an [ImageProvider].
  ///
  /// Returns [Brightness.dark] if the dominant color's luminance
  /// is below the threshold, or as a fallback when extraction fails.
  static Future<Brightness> resolve(ImageProvider provider) async {
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        provider,
        maximumColorCount: 4,
      );
      final dominantColor =
          palette.dominantColor?.color ?? palette.colors.firstOrNull;
      if (dominantColor == null) return Brightness.dark;

      return dominantColor.computeLuminance() < _luminanceThreshold
          ? Brightness.dark
          : Brightness.light;
    } on Exception {
      return Brightness.dark;
    }
  }
}
