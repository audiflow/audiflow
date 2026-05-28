import 'package:audiflow_app/features/parental_control/data/gate_guard_impl.dart';
import 'package:audiflow_app/features/parental_control/domain/gate_guard.dart';
import 'package:audiflow_app/features/parental_control/providers/gate_guard_provider.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('gateGuardProvider', () {
    test('returns a GateGuardImpl singleton', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final first = container.read(gateGuardProvider);
      final second = container.read(gateGuardProvider);

      check(first).isA<GateGuardImpl>();
      // keepAlive: true means the same instance is returned on subsequent reads.
      check(identical(first, second)).isTrue();
    });

    test('exposes GateGuard interface', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final guard = container.read(gateGuardProvider);
      check(guard).isA<GateGuard>();
    });
  });
}
