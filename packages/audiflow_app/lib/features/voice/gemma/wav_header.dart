import 'dart:typed_data';

/// Builds the canonical 44-byte RIFF/WAVE header for the linear-PCM body
/// `flutter_gemma` consumes (16 kHz, mono, 16-bit signed little-endian).
///
/// The function prepends a header to [pcm] and returns the complete WAV
/// payload; it does not mutate [pcm]. Sample-rate / channel / bit-depth
/// defaults match the Gemma 4 audio-input contract; callers should not
/// override them unless the inference session changes shape.
///
/// Reference: WAVE PCM format,
/// http://soundfile.sapp.org/doc/WaveFormat/.
Uint8List wrapPcmAsWav(
  Uint8List pcm, {
  int sampleRate = 16000,
  int numChannels = 1,
  int bitsPerSample = 16,
}) {
  const headerSize = 44;
  final byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
  final blockAlign = numChannels * (bitsPerSample ~/ 8);
  final dataSize = pcm.lengthInBytes;
  final fileSize = headerSize - 8 + dataSize;

  final buffer = Uint8List(headerSize + dataSize);
  final view = ByteData.view(buffer.buffer);

  // RIFF chunk descriptor.
  buffer.setRange(0, 4, _ascii('RIFF'));
  view.setUint32(4, fileSize, Endian.little);
  buffer.setRange(8, 12, _ascii('WAVE'));

  // fmt sub-chunk (PCM).
  buffer.setRange(12, 16, _ascii('fmt '));
  view.setUint32(16, 16, Endian.little); // Sub-chunk size for PCM.
  view.setUint16(20, 1, Endian.little); // Audio format = PCM.
  view.setUint16(22, numChannels, Endian.little);
  view.setUint32(24, sampleRate, Endian.little);
  view.setUint32(28, byteRate, Endian.little);
  view.setUint16(32, blockAlign, Endian.little);
  view.setUint16(34, bitsPerSample, Endian.little);

  // data sub-chunk.
  buffer.setRange(36, 40, _ascii('data'));
  view.setUint32(40, dataSize, Endian.little);
  buffer.setRange(headerSize, headerSize + dataSize, pcm);

  return buffer;
}

List<int> _ascii(String s) => s.codeUnits;
