import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildVoiceTools', () {
    test('omits changeSettings when settingsSnapshot is null', () {
      final tools = buildVoiceTools();
      check(tools).length.equals(13);
      check(
        tools.map((t) => t.name),
      ).not((it) => it.contains('changeSettings'));
    });

    test('includes changeSettings with empty enum on empty snapshot', () {
      final tools = buildVoiceTools(settingsSnapshot: const []);
      check(tools).length.equals(14);
      final changeSettings = tools.singleWhere(
        (t) => t.name == 'changeSettings',
      );
      final keyProp =
          (changeSettings.parameters['properties']! as Map)['key'] as Map;
      check(keyProp['enum']).isA<List<Object?>>().isEmpty();
    });

    test('snapshot entries with non-string key are skipped silently', () {
      final tools = buildVoiceTools(
        settingsSnapshot: const [
          {'key': 'speed'},
          {'key': 42}, // non-string -- skipped
          {'key': 'theme'},
          {'notAKey': 'stranger'}, // missing -- skipped
        ],
      );
      final changeSettings = tools.singleWhere(
        (t) => t.name == 'changeSettings',
      );
      final keys =
          (changeSettings.parameters['properties']! as Map)['key']!
              as Map<String, Object?>;
      check(keys['enum']).isA<List<Object?>>().deepEquals(['speed', 'theme']);
    });

    test(
      'changeSettings key enum stays in sync between top level and candidates',
      () {
        final tools = buildVoiceTools(
          settingsSnapshot: const [
            {'key': 'speed'},
            {'key': 'theme'},
          ],
        );
        final changeSettings = tools.singleWhere(
          (t) => t.name == 'changeSettings',
        );
        final props = changeSettings.parameters['properties']! as Map;
        final topLevelEnum = (props['key']! as Map)['enum'];
        final candidates = props['candidates']! as Map;
        final itemsProps = (candidates['items']! as Map)['properties']! as Map;
        final candidateEnum = (itemsProps['key']! as Map)['enum'];
        check(candidateEnum).equals(topLevelEnum);
      },
    );

    test('every tool name maps back to a VoiceIntent', () {
      final tools = buildVoiceTools(
        settingsSnapshot: const [
          {'key': 'speed'},
        ],
      );
      final intentNames = VoiceIntent.values.map((i) => i.name).toSet();
      for (final tool in tools) {
        check(intentNames).contains(tool.name);
      }
      // Inverse: every non-unknown VoiceIntent has exactly one tool.
      final toolNames = tools.map((t) => t.name).toSet();
      for (final intent in VoiceIntent.values) {
        if (intent == VoiceIntent.unknown) {
          check(toolNames).not((it) => it.contains(intent.name));
        } else {
          check(toolNames).contains(intent.name);
        }
      }
    });

    test(
      'returned tool list and changeSettings parameters are unmodifiable',
      () {
        final tools = buildVoiceTools(
          settingsSnapshot: const [
            {'key': 'speed'},
          ],
        );
        final changeSettings = tools.singleWhere(
          (t) => t.name == 'changeSettings',
        );
        check(
          () => changeSettings.parameters['injected'] = 'nope',
        ).throws<UnsupportedError>();
      },
    );
  });
}
