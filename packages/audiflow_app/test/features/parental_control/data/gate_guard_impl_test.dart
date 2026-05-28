import 'package:audiflow_app/features/parental_control/data/gate_guard_impl.dart';
import 'package:audiflow_app/features/parental_control/domain/gate_guard.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

MaterialApp _app(Widget child) => MaterialApp(
  localizationsDelegates: [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  group('GateGuardImpl.requireUnlock', () {
    testWidgets('returns true immediately when restricted mode is off', (
      tester,
    ) async {
      late bool result;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [isRestrictedModeOnProvider.overrideWith((ref) => false)],
          child: _app(
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  final guard = GateGuardImpl(
                    container: ProviderScope.containerOf(context),
                  );
                  result = await guard.requireUnlock(
                    context,
                    reason: GateReason.subscribe,
                  );
                },
                child: const Text('Go'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Go'));
      await tester.pump();
      check(result).isTrue();
    });

    testWidgets(
      'returns false when restricted mode is on and sheet is cancelled',
      (tester) async {
        late bool result;
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              isRestrictedModeOnProvider.overrideWith((ref) => true),
              parentalControlGateProvider.overrideWith(
                () => _StubGate(unlockResult: false),
              ),
            ],
            child: _app(
              Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async {
                    final guard = GateGuardImpl(
                      container: ProviderScope.containerOf(context),
                    );
                    result = await guard.requireUnlock(
                      context,
                      reason: GateReason.subscribe,
                    );
                  },
                  child: const Text('Go'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Go'));
        await tester.pumpAndSettle();
        // Sheet is open — dismiss via Cancel.
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        check(result).isFalse();
      },
    );
  });
}

/// Stub [ParentalControlGate] that returns a fixed result from [tryUnlock]
/// without touching Isar or the repository.
class _StubGate extends ParentalControlGate {
  _StubGate({required this.unlockResult});
  final bool unlockResult;

  @override
  UnlockState build() => const Locked();

  @override
  Future<bool> tryUnlock(String pin, {UnlockReason? reason}) async =>
      unlockResult;
}
