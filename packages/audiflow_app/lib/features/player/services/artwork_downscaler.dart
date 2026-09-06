import 'dart:typed_data';
import 'dart:ui' as ui;

/// Decodes [encoded] and re-encodes it as PNG with its long edge limited
/// to [maxEdgePixels]; see [downscaleArtworkToPng].
typedef ArtworkDownscaler =
    Future<Uint8List?> Function(Uint8List encoded, int maxEdgePixels);

/// Decodes an image and re-encodes it as a PNG whose long edge is at most
/// [maxEdgePixels]. Returns null when the bytes are not a decodable image.
///
/// The decode happens at the reduced size, so the full-resolution bitmap
/// never exists in memory. Images already within the limit keep their size.
Future<Uint8List?> downscaleArtworkToPng(
  Uint8List encoded,
  int maxEdgePixels,
) async {
  final ui.Codec codec;
  try {
    final buffer = await ui.ImmutableBuffer.fromUint8List(encoded);
    codec = await ui.instantiateImageCodecWithSize(
      buffer,
      getTargetSize: (width, height) =>
          _fitWithin(width, height, maxEdgePixels),
    );
  } on Exception {
    return null;
  }
  return _encodeFirstFrame(codec);
}

ui.TargetImageSize _fitWithin(int width, int height, int maxEdgePixels) {
  final longEdge = width < height ? height : width;
  if (longEdge <= maxEdgePixels) {
    return ui.TargetImageSize(width: width, height: height);
  }
  final scale = maxEdgePixels / longEdge;
  return ui.TargetImageSize(
    width: (width * scale).round(),
    height: (height * scale).round(),
  );
}

Future<Uint8List?> _encodeFirstFrame(ui.Codec codec) async {
  try {
    final frame = await codec.getNextFrame();
    try {
      final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } finally {
      frame.image.dispose();
    }
  } finally {
    codec.dispose();
  }
}
