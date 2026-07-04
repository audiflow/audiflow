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
  _FakeRepo({required this.correctPin});

  final String correctPin;
  final _setPinCalls = <String>[];

  List<String> get setPinCalls => List.unmodifiable(_setPinCalls);

  @override
  Future<bool> verifyPin(String pin) async => pin == correctPin;

  @override
  Future<void> setPin(String pin) async => _setPinCalls.add(pin);

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
    testWidgets('new-PIN fields hidden until current PIN verified', (
      tester,
    ) async {
      final fakeRepo = _FakeRepo(correctPin: '1234');
      await tester.pumpWidget(
        _wrap(
          const PinChangeScreen(),
          overrides: [
            parentalControlRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        ),
      );
      await tester.pump();

      // Only the current-PIN field is visible; new-PIN fields are hidden.
      check(find.byType(TextField).evaluate().length).equals(1);
    });

    testWidgets('wrong current PIN shows error, new-PIN fields stay hidden', (
      tester,
    ) async {
      final fakeRepo = _FakeRepo(correctPin: '1234');
      await tester.pumpWidget(
        _wrap(
          const PinChangeScreen(),
          overrides: [
            parentalControlRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, '9999');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Verify'));
      await tester.pumpAndSettle();

      // Error visible, still only one text field.
      check(find.byType(TextField).evaluate().length).equals(1);
      final field = tester.widget<TextField>(find.byType(TextField).first);
      check(field.decoration!.errorText).isNotNull();
    });

    testWidgets('correct current PIN reveals new-PIN fields', (tester) async {
      final fakeRepo = _FakeRepo(correctPin: '1234');
      await tester.pumpWidget(
        _wrap(
          const PinChangeScreen(),
          overrides: [
            parentalControlRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, '1234');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Verify'));
      await tester.pumpAndSettle();

      // Three fields now visible: current (disabled) + new + confirm.
      check(find.byType(TextField).evaluate().length).equals(3);
    });

    testWidgets('matching 4-8 digit new PINs enable Save button', (
      tester,
    ) async {
      final fakeRepo = _FakeRepo(correctPin: '1234');
      await tester.pumpWidget(
        _wrap(
          const PinChangeScreen(),
          overrides: [
            parentalControlRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        ),
      );
      await tester.pump();

      // Verify current PIN.
      await tester.enterText(find.byType(TextField).first, '1234');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Verify'));
      await tester.pumpAndSettle();

      // Save should be disabled before entering new PINs.
      check(
        tester
            .widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Save'))
            .onPressed,
      ).isNull();

      // Enter matching new PINs.
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(1), '5678');
      await tester.enterText(fields.at(2), '5678');
      await tester.pump();

      check(
        tester
            .widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Save'))
            .onPressed,
      ).isNotNull();
    });

    testWidgets('Save calls setPin and pops', (tester) async {
      final fakeRepo = _FakeRepo(correctPin: '1234');
      await tester.pumpWidget(
        _wrap(
          const PinChangeScreen(),
          overrides: [
            parentalControlRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        ),
      );
      await tester.pump();

      // Verify current PIN.
      await tester.enterText(find.byType(TextField).first, '1234');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Verify'));
      await tester.pumpAndSettle();

      // Enter matching new PINs.
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(1), '8765');
      await tester.enterText(fields.at(2), '8765');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      check(fakeRepo.setPinCalls).deepEquals(['8765']);
      // After pop we should see the home scaffold.
      check(find.text('home').evaluate()).isNotEmpty();
    });
  });
}
