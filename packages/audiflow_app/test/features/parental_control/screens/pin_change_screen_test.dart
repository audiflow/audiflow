import 'package:audiflow_app/features/parental_control/presentation/screens/pin_change_screen.dart';
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

Widget _wrap(Widget child, {List<dynamic> overrides = const []}) {
  final router = GoRouter(
    initialLocation: '/pin-change',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('home')),
        routes: [GoRoute(path: 'pin-change', builder: (_, _) => child)],
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
  Future<bool> verifyPin(String pin) async => false;

  @override
  Future<void> setPin(String pin) async => _setPinCalls.add(pin);

  @override
  Future<void> setupPin(String pin) async {
    throw StateError('PIN change must never call setupPin');
  }

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
  group('PinChangeScreen', () {
    testWidgets('shows new-PIN fields directly, no current-PIN step', (
      tester,
    ) async {
      final fakeRepo = _FakeRepo();
      await tester.pumpWidget(
        _wrap(
          const PinChangeScreen(),
          overrides: [
            parentalControlRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        ),
      );
      await tester.pump();

      // New + confirm fields only; no current-PIN field or Verify button.
      check(find.byType(TextField).evaluate().length).equals(2);
      check(find.widgetWithText(ElevatedButton, 'Verify').evaluate()).isEmpty();
    });

    testWidgets('Save disabled until new PINs match with 4-8 digits', (
      tester,
    ) async {
      final fakeRepo = _FakeRepo();
      await tester.pumpWidget(
        _wrap(
          const PinChangeScreen(),
          overrides: [
            parentalControlRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        ),
      );
      await tester.pump();

      final save = find.widgetWithText(ElevatedButton, 'Save');
      check(tester.widget<ElevatedButton>(save).onPressed).isNull();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '5678');
      await tester.enterText(fields.at(1), '9999');
      await tester.pump();
      check(tester.widget<ElevatedButton>(save).onPressed).isNull();

      await tester.enterText(fields.at(1), '5678');
      await tester.pump();
      check(tester.widget<ElevatedButton>(save).onPressed).isNotNull();
    });

    testWidgets('Save calls setPin and pops', (tester) async {
      final fakeRepo = _FakeRepo();
      await tester.pumpWidget(
        _wrap(
          const PinChangeScreen(),
          overrides: [
            parentalControlRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        ),
      );
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '8765');
      await tester.enterText(fields.at(1), '8765');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      check(fakeRepo.setPinCalls).deepEquals(['8765']);
      // After pop we should see the home scaffold.
      check(find.text('home').evaluate()).isNotEmpty();
    });
  });
}
