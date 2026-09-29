import 'package:audiflow_app/features/monitoring/services/sentry_diagnostics.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isDiagnosticFlavor', () {
    test('enables diagnostics for dev and stg', () {
      check(isDiagnosticFlavor('dev')).isTrue();
      check(isDiagnosticFlavor('stg')).isTrue();
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
