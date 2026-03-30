import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VoiceDebugInfoNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is default VoiceDebugInfo', () {
      final state = container.read(voiceDebugInfoProvider);
      check(state.parserSource).equals(VoiceParserSource.none);
      check(state.lastCommand).isNull();
    });

    test('setParserSource updates parserSource', () {
      container
          .read(voiceDebugInfoProvider.notifier)
          .setParserSource(VoiceParserSource.simplePattern);

      final state = container.read(voiceDebugInfoProvider);
      check(state.parserSource).equals(VoiceParserSource.simplePattern);
    });

    test('setLastCommand updates lastCommand', () {
      final command = VoiceCommand(
        intent: VoiceIntent.pause,
        parameters: const {},
        confidence: 0.95,
        rawTranscription: 'pause',
      );
      container.read(voiceDebugInfoProvider.notifier).setLastCommand(command);

      final state = container.read(voiceDebugInfoProvider);
      check(state.lastCommand).isNotNull();
      check(state.lastCommand!.intent).equals(VoiceIntent.pause);
    });

    test('reset restores default state', () {
      container
          .read(voiceDebugInfoProvider.notifier)
          .setParserSource(VoiceParserSource.onDeviceAi);

      final command = VoiceCommand(
        intent: VoiceIntent.play,
        parameters: const {},
        confidence: 0.9,
        rawTranscription: 'play',
      );
      container.read(voiceDebugInfoProvider.notifier).setLastCommand(command);

      container.read(voiceDebugInfoProvider.notifier).reset();

      final state = container.read(voiceDebugInfoProvider);
      check(state.parserSource).equals(VoiceParserSource.none);
      check(state.lastCommand).isNull();
    });

    test('setParserSource preserves lastCommand', () {
      final command = VoiceCommand(
        intent: VoiceIntent.play,
        parameters: const {},
        confidence: 0.9,
        rawTranscription: 'play',
      );
      final notifier = container.read(voiceDebugInfoProvider.notifier);
      notifier.setLastCommand(command);
      notifier.setParserSource(VoiceParserSource.platformNlu);

      final state = container.read(voiceDebugInfoProvider);
      check(state.parserSource).equals(VoiceParserSource.platformNlu);
      check(state.lastCommand).isNotNull();
    });
  });
}
