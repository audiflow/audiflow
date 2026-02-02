import 'dart:io';

import 'package:audiflow_cli/src/commands/pattern_list_command.dart';
import 'package:audiflow_cli/src/patterns/pattern_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PatternRegistry registry;

  setUp(() {
    final jsonFile = File('test/fixtures/smart_playlist_patterns.json');
    registry = PatternRegistry.fromJson(jsonFile.readAsStringSync());
  });

  group('PatternListCommand', () {
    test('lists all patterns with id and URL', () {
      final output = StringBuffer();
      final command = PatternListCommand(sink: output, registry: registry);

      final exitCode = command.run();

      expect(exitCode, 0);
      expect(output.toString(), contains('coten_radio'));
      expect(output.toString(), contains('anchor'));
    });
  });
}
