import 'package:audiflow_app/features/monitoring/services/sentry_diagnostics.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isDiagnosticFlavor', () {
    // Paused for every flavor: the info-level messages were using up the
    // Sentry quota on dev and stg as well.
    test('disables diagnostics for dev and stg while paused', () {
      check(isDiagnosticFlavor('dev')).isFalse();
      check(isDiagnosticFlavor('stg')).isFalse();
    });

    test('disables diagnostics for prod', () {
      check(isDiagnosticFlavor('prod')).isFalse();
    });

    test('disables diagnostics when the flavor is unknown', () {
      check(isDiagnosticFlavor(null)).isFalse();
      check(isDiagnosticFlavor('')).isFalse();
    });
  });
}
