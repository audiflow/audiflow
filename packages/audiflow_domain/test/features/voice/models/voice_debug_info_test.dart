import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VoiceDebugInfo', () {
    test('default values', () {
      const info = VoiceDebugInfo();
      check(info.parserSource).equals(VoiceParserSource.none);
      check(info.lastCommand).isNull();
    });

    test('copyWith parserSource', () {
      const info = VoiceDebugInfo();
      final updated = info.copyWith(
        parserSource: VoiceParserSource.simplePattern,
      );
      check(updated.parserSource).equals(VoiceParserSource.simplePattern);
      check(info.parserSource).equals(VoiceParserSource.none);
    });

    test('copyWith lastCommand', () {
      const info = VoiceDebugInfo();
      final command = VoiceCommand(
        intent: VoiceIntent.play,
        parameters: const {'podcastName': 'news'},
        confidence: 0.9,
        rawTranscription: 'play the news',
      );
      final updated = info.copyWith(lastCommand: command);
      check(updated.lastCommand).isNotNull();
      check(updated.lastCommand!.intent).equals(VoiceIntent.play);
      check(updated.lastCommand!.confidence).equals(0.9);
    });

    test('equality', () {
      const a = VoiceDebugInfo();
      const b = VoiceDebugInfo();
      check(a).equals(b);
    });
  });

  group('VoiceParserSource', () {
    test('has expected values', () {
      check(VoiceParserSource.values.length).equals(4);
      check(VoiceParserSource.values).contains(VoiceParserSource.none);
      check(VoiceParserSource.values).contains(VoiceParserSource.simplePattern);
      check(VoiceParserSource.values).contains(VoiceParserSource.platformNlu);
      check(VoiceParserSource.values).contains(VoiceParserSource.onDeviceAi);
    });
  });
}
