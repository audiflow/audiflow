import 'package:audiflow_app/features/parental_control/domain/gate_guard.dart';
import 'package:audiflow_app/features/parental_control/providers/gate_guard_provider.dart';
import 'package:audiflow_app/features/settings/presentation/controllers/opml_import_controller.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _DenyingGateGuard implements GateGuard {
  @override
  Future<bool> requireUnlock(
    BuildContext context, {
    required GateReason reason,
  }) async => false;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('OpmlImportController.pickAndParse', () {
    testWidgets('returns false and stays idle when gate denies', (
      tester,
    ) async {
      late ProviderContainer container;
      late bool result;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            subscriptionRepositoryProvider.overrideWithValue(
              FakeSubscriptionRepository(),
            ),
            gateGuardProvider.overrideWithValue(_DenyingGateGuard()),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                container = ProviderScope.containerOf(context);
                return TextButton(
                  onPressed: () async {
                    result = await container
                        .read(opmlImportControllerProvider.notifier)
                        .pickAndParse(context);
                  },
                  child: const Text('tap'),
                );
              },
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.tap(find.text('tap'));
      await tester.pumpAndSettle();

      check(result).isFalse();
      check(container.read(opmlImportControllerProvider)).isA<OpmlPickIdle>();
    });
  });
}
