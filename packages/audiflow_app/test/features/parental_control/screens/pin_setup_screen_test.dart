import 'package:audiflow_app/features/parental_control/presentation/screens/pin_setup_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

/// Wraps [child] with routing so [context.pop()] works.
///
/// The router starts at `/` and immediately pushes `/pin-setup` so that
/// there is always something to pop back to.
Widget _wrap(Widget child, {List<dynamic> overrides = const []}) {
  final router = GoRouter(
    initialLocation: '/pin-setup',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('home')),
        routes: [GoRoute(path: 'pin-setup', builder: (_, _) => child)],
      ),
    ],
  );
  return ProviderScope(
    overrides: overrides.cast(),
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeRepo implements ParentalControlRepository {
  final _setPinCalls = <String>[];

  List<String> get setPinCalls => List.unmodifiable(_setPinCalls);

  @override
  Future<void> setPin(String pin) async => _setPinCalls.add(pin);

  @override
  Future<bool> verifyPin(String pin) async => false;

  @override
  Future<void> clearPin() async {}

  @override
  Future<ParentalControlSettings> getSettings() async =>
      ParentalControlSettings();

  @override
  Stream<ParentalControlSettings> watchSettings() => const Stream.empty();

  @override
  Future<void> setRestrictedMode(bool enabled) async {}

  @override
  Future<void> setUnlockTimeout(Duration timeout) async {}

  @override
  Future<void> setBiometricUnlockEnabled(bool enabled) async {}

  @override
  Future<Duration?> registerFailedAttempt() async => null;

  @override
  Future<void> clearFailedAttempts() async {}

  @override
  Stream<bool> watchHideExplicit(int itunesId) => const Stream.empty();

  @override
  Future<bool> getHideExplicit(int itunesId) async => false;

  @override
  Future<void> setHideExplicit(int itunesId, bool hide) async {}

  @override
  Future<void> pruneFlagsFor(int itunesId) async {}
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PinSetupScreen', () {
    testWidgets('Submit disabled when first PIN has fewer than 4 digits', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const PinSetupScreen()));
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '123');
      await tester.enterText(fields.at(1), '123');
      await tester.pump();

      final submit = find.widgetWithText(ElevatedButton, 'Save');
      check(tester.widget<ElevatedButton>(submit).onPressed).isNull();
    });

    testWidgets('Submit disabled when PINs do not match', (tester) async {
      await tester.pumpWidget(_wrap(const PinSetupScreen()));
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '1234');
      await tester.enterText(fields.at(1), '5678');
      await tester.pump();

      final submit = find.widgetWithText(ElevatedButton, 'Save');
      check(tester.widget<ElevatedButton>(submit).onPressed).isNull();
    });

    testWidgets('Submit enabled when both PINs match and length is 4–8', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const PinSetupScreen()));
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '1234');
      await tester.enterText(fields.at(1), '1234');
      await tester.pump();

      final submit = find.widgetWithText(ElevatedButton, 'Save');
      check(tester.widget<ElevatedButton>(submit).onPressed).isNotNull();
    });

    testWidgets('Submit enabled for 8-digit matching PINs', (tester) async {
      await tester.pumpWidget(_wrap(const PinSetupScreen()));
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '12345678');
      await tester.enterText(fields.at(1), '12345678');
      await tester.pump();

      final submit = find.widgetWithText(ElevatedButton, 'Save');
      check(tester.widget<ElevatedButton>(submit).onPressed).isNotNull();
    });

    testWidgets('Tapping Submit calls setPin on the repository', (
      tester,
    ) async {
      final fakeRepo = _FakeRepo();
      await tester.pumpWidget(
        _wrap(
          const PinSetupScreen(),
          overrides: [
            parentalControlRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        ),
      );
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '4321');
      await tester.enterText(fields.at(1), '4321');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      check(fakeRepo.setPinCalls).deepEquals(['4321']);
    });
  });
}
