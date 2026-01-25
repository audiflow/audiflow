import 'package:audiflow_cli/src/commands/pattern_list_command.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PatternListCommand', () {
    test('lists all patterns with id and URL', () {
      final output = StringBuffer();
      final command = PatternListCommand(output);

      final exitCode = command.run();

      expect(exitCode, 0);
      expect(output.toString(), contains('coten_radio'));
      expect(output.toString(), contains('anchor'));
    });
  });
}
