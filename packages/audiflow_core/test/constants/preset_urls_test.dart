import 'package:audiflow_core/audiflow_core.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PresetUrls', () {
    test('presetDir points at the preset on the main branch', () {
      check(PresetUrls.presetDir('2e86c4b573b7')).equals(
        'https://github.com/audiflow/audiflow-preset/tree/main/presets/2e86c4b573b7',
      );
    });
  });
}
