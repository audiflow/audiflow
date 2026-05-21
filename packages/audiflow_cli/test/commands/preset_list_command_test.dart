import 'dart:io';

import 'package:audiflow_cli/src/commands/preset_list_command.dart';
import 'package:audiflow_cli/src/presets/preset_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PresetRegistry registry;

  setUp(() {
    final jsonFile = File('test/fixtures/smart_playlist_presets.json');
    registry = PresetRegistry.fromJson(jsonFile.readAsStringSync());
  });

  group('PresetListCommand', () {
    test('lists all patterns with id and URL', () {
      final output = StringBuffer();
      final command = PresetListCommand(sink: output, registry: registry);

      final exitCode = command.run();

      expect(exitCode, 0);
      expect(output.toString(), contains('coten_radio'));
      expect(output.toString(), contains('anchor'));
    });
  });
}
