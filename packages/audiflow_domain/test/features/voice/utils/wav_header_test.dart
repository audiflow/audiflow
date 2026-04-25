import 'dart:typed_data';

import 'package:audiflow_domain/src/features/voice/utils/wav_header.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('wrapPcmAsWav', () {
    test('emits canonical 44-byte header before payload', () {
      final pcm = Uint8List.fromList(List<int>.filled(8, 0));
      final wav = wrapPcmAsWav(pcm);
      check(wav.length).equals(44 + 8);
      check(String.fromCharCodes(wav.sublist(0, 4))).equals('RIFF');
      check(String.fromCharCodes(wav.sublist(8, 12))).equals('WAVE');
      check(String.fromCharCodes(wav.sublist(12, 16))).equals('fmt ');
      check(String.fromCharCodes(wav.sublist(36, 40))).equals('data');
    });

    test('encodes 16 kHz mono 16-bit defaults', () {
      final wav = wrapPcmAsWav(Uint8List(0));
      final view = ByteData.view(wav.buffer);
      check(view.getUint16(20, Endian.little)).equals(1); // PCM format.
      check(view.getUint16(22, Endian.little)).equals(1); // Mono.
      check(view.getUint32(24, Endian.little)).equals(16000); // Sample rate.
      check(view.getUint32(28, Endian.little)).equals(32000); // Byte rate.
      check(view.getUint16(32, Endian.little)).equals(2); // Block align.
      check(view.getUint16(34, Endian.little)).equals(16); // Bits/sample.
    });

    test('records data and file sizes from payload length', () {
      final pcm = Uint8List.fromList(List<int>.filled(100, 0));
      final wav = wrapPcmAsWav(pcm);
      final view = ByteData.view(wav.buffer);
      check(view.getUint32(40, Endian.little)).equals(100); // data size.
      check(view.getUint32(4, Endian.little)).equals(36 + 100); // RIFF size.
    });

    test('appends payload bytes verbatim after header', () {
      final pcm = Uint8List.fromList([1, 2, 3, 4]);
      final wav = wrapPcmAsWav(pcm);
      check(wav.sublist(44).toList()).deepEquals([1, 2, 3, 4]);
    });

    test('does not mutate the source buffer', () {
      final pcm = Uint8List.fromList([1, 2, 3]);
      wrapPcmAsWav(pcm);
      check(pcm.toList()).deepEquals([1, 2, 3]);
    });
  });
}
