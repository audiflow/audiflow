import 'package:audiflow_app/features/parental_control/domain/gate_guard.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('gateReasonToUnlock', () {
    test('maps every GateReason to the correct UnlockReason', () {
      // Exhaustiveness: GateReason covers all UnlockReason values except
      // `unspecified`, so length should be exactly one less.
      check(GateReason.values.length).equals(UnlockReason.values.length - 1);

      const expected = {
        GateReason.subscribe: UnlockReason.subscribe,
        GateReason.unsubscribe: UnlockReason.unsubscribe,
        GateReason.opmlImport: UnlockReason.opmlImport,
        GateReason.deepLink: UnlockReason.deepLink,
        GateReason.parentalSettings: UnlockReason.parentalSettings,
        GateReason.developerSettings: UnlockReason.developerSettings,
      };

      for (final entry in expected.entries) {
        check(gateReasonToUnlock(entry.key)).equals(entry.value);
      }
    });
  });
}
