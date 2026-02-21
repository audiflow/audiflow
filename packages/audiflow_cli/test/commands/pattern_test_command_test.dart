import 'package:audiflow_cli/src/commands/pattern_test_command.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PatternTestCommand', () {
    test('extracts title from pattern match', () {
      final output = StringBuffer();
      final command = PatternTestCommand(output);

      final exitCode = command.run(
        title: '【62-15】Test【COTEN RADIO リンカン編15】',
        titlePattern: r'【COTEN RADIO (ショート)?\s*(.+?)\s*\d+】',
        titleGroup: 2,
        seasonNumber: 62,
      );

      expect(exitCode, 0);
      expect(output.toString(), contains('リンカン編'));
      expect(output.toString(), contains('15'));
    });

    test('reports error when pattern does not match', () {
      final output = StringBuffer();
      final command = PatternTestCommand(output);

      final exitCode = command.run(
        title: '【特別編】Test',
        titlePattern: r'【COTEN RADIO (.+?)\d+】',
        titleGroup: 1,
        seasonNumber: 99,
      );

      expect(exitCode, 1);
      expect(output.toString().toLowerCase(), contains('error'));
    });

    test('uses fallback for null seasonNumber', () {
      final output = StringBuffer();
      final command = PatternTestCommand(output);

      final exitCode = command.run(
        title: '【番外編#135】Test',
        titlePattern: r'【COTEN RADIO (.+?)\d+】',
        titleGroup: 1,
        titleFallback: '番外編',
        seasonNumber: null,
        episodeNumber: 135,
      );

      expect(exitCode, 0);
      expect(output.toString(), contains('番外編'));
    });
  });
}
