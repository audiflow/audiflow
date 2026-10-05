import 'dart:typed_data';
import 'dart:ui' as ui;

/// Image bytes ready to be written as a notification attachment, plus the
/// file extension that names their format.
class EncodedArtwork {
  const EncodedArtwork({required this.bytes, required this.extension});

  final Uint8List bytes;

  /// Without the leading dot, e.g. `png`.
  final String extension;
}

/// Turns downloaded artwork into the file a notification attaches.
///
/// Platforms differ in what they need and in what can run in the background,
/// so the app layer picks the strategy.
abstract interface class NotificationArtworkEncoder {
  Future<EncodedArtwork> encode(Uint8List bytes);
}

/// Thrown when artwork bytes are not in a format the attachment accepts.
class UnsupportedArtworkFormatException implements Exception {
  const UnsupportedArtworkFormatException();

  @override
  String toString() => 'UnsupportedArtworkFormatException: unrecognised image';
}

/// Decodes at a fixed width and re-encodes as PNG.
///
/// For Android: podcast artwork is often 3000x3000 (~36 MB decoded) and
/// Android decodes large icons without sampling.
///
/// Not usable for iOS background refresh: iOS disables the GPU for a
/// backgrounded engine, and Impeller defers image decode/encode until the GPU
/// returns, so the futures do not complete while in the background.
class DownscalingArtworkEncoder implements NotificationArtworkEncoder {
  const DownscalingArtworkEncoder({this.width = defaultWidth});

  static const defaultWidth = 256;

  final int width;

  @override
  Future<EncodedArtwork> encode(Uint8List bytes) async => EncodedArtwork(
    bytes: await downscaleToPng(bytes, width),
    extension: 'png',
  );
}

/// Keeps the downloaded bytes untouched and only names their format.
///
/// For iOS: avoids dart:ui entirely (see [DownscalingArtworkEncoder]), and
/// iOS scales attachments itself. `UNNotificationAttachment` infers the type
/// from the file extension and accepts JPEG, PNG and GIF images, so anything
/// else is rejected rather than attached under a wrong name.
class PassthroughArtworkEncoder implements NotificationArtworkEncoder {
  const PassthroughArtworkEncoder();

  @override
  Future<EncodedArtwork> encode(Uint8List bytes) async {
    final extension = sniffAttachmentExtension(bytes);
    if (extension == null) throw const UnsupportedArtworkFormatException();
    return EncodedArtwork(bytes: bytes, extension: extension);
  }
}

const _signatures = <String, List<int>>{
  'jpg': [0xFF, 0xD8, 0xFF],
  'png': [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
  'gif': [0x47, 0x49, 0x46, 0x38], // "GIF8" covers GIF87a and GIF89a.
};

/// File extension for JPEG, PNG or GIF [bytes], identified by their magic
/// number; null for any other or too-short content.
String? sniffAttachmentExtension(Uint8List bytes) {
  for (final MapEntry(key: extension, value: signature)
      in _signatures.entries) {
    if (_startsWith(bytes, signature)) return extension;
  }
  return null;
}

bool _startsWith(Uint8List bytes, List<int> prefix) {
  if (bytes.length < prefix.length) return false;
  for (var i = 0; i < prefix.length; i++) {
    if (bytes[i] != prefix[i]) return false;
  }
  return true;
}

/// Decodes [bytes] at [width] (aspect ratio kept) and re-encodes as PNG.
Future<Uint8List> downscaleToPng(Uint8List bytes, int width) async {
  final codec = await ui.instantiateImageCodec(bytes, targetWidth: width);
  final frame = await codec.getNextFrame();
  codec.dispose();
  final image = frame.image;
  try {
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    if (png == null) throw StateError('PNG encoding failed');
    return png.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}
