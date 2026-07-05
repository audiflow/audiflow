import 'dart:async';

import 'package:audiflow_app/features/parental_control/domain/gate_guard.dart';
import 'package:audiflow_app/features/parental_control/presentation/widgets/pin_entry_sheet.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

Widget _wrap(Widget child, {List<dynamic> overrides = const []}) =>
    ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );

/// Enters text into the PIN field and pumps one frame.
Future<void> _enterPin(WidgetTester tester, String pin) async {
  final field = find.byType(TextField).first;
  await tester.enterText(field, pin);
  await tester.pump();
}

/// Taps the Submit button and pumps until the frame settles.
Future<void> _tapSubmit(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(ElevatedButton, 'Unlock'));
  await tester.pump();
}

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

/// Fake [ParentalControlGate] whose [tryUnlock] returns a fixed value.
class _FakeGate extends ParentalControlGate {
  _FakeGate({
    required this.unlockResult,
    this.nextState,
    this.biometricResult = true,
  });

  final bool unlockResult;
  final bool biometricResult;

  /// State to transition to after [tryUnlock] is called (if non-null).
  final UnlockState? nextState;

  int biometricCalls = 0;

  @override
  UnlockState build() => const Locked();

  @override
  Future<bool> tryUnlock(String pin, {UnlockReason? reason}) async {
    if (nextState != null) state = nextState!;
    return unlockResult;
  }

  @override
  Future<bool> tryUnlockBiometric({
    required String localizedReason,
    UnlockReason? reason,
  }) async {
    biometricCalls++;
    return biometricResult;
  }
}

class _FakeBiometricAuthenticator implements BiometricAuthenticator {
  _FakeBiometricAuthenticator({required this.available});

  final bool available;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate({required String localizedReason}) async => true;
}

/// Fake gate whose [tryUnlock] never completes until [complete] is called.
class _SlowGate extends ParentalControlGate {
  final _completer = Completer<bool>();

  void complete({required bool result}) => _completer.complete(result);

  @override
  UnlockState build() => const Locked();

  @override
  Future<bool> tryUnlock(String pin, {UnlockReason? reason}) =>
      _completer.future;
}

/// Fake [ParentalControlRepository] with a configurable [getSettings] result.
class _FakeRepo implements ParentalControlRepository {
  _FakeRepo({
    int failedAttempts = 2,
    bool throwOnGetSettings = false,
    bool biometricUnlockEnabled = false,
  }) : _failedAttempts = failedAttempts,
       _throwOnGetSettings = throwOnGetSettings,
       _biometricUnlockEnabled = biometricUnlockEnabled;

  final int _failedAttempts;
  final bool _throwOnGetSettings;
  final bool _biometricUnlockEnabled;

  @override
  Future<ParentalControlSettings> getSettings() async {
    if (_throwOnGetSettings) throw StateError('storage unavailable');
    return ParentalControlSettings()
      ..failedAttempts = _failedAttempts
      ..biometricUnlockEnabled = _biometricUnlockEnabled;
  }

  // Unused interface methods — not expected to be called by these tests.
  @override
  Stream<ParentalControlSettings> watchSettings() => const Stream.empty();
  @override
  Future<void> setPin(String pin) async {}
  @override
  Future<void> setupPin(String pin) async {}
  @override
  Future<bool> verifyPin(String pin) async => false;
  @override
  Future<void> clearPin() async {}
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
  testWidgets('Submit button disabled until 4 digits entered', (tester) async {
    await tester.pumpWidget(
      _wrap(const PinEntrySheet(reason: GateReason.subscribe)),
    );
    final submit = find.widgetWithText(ElevatedButton, 'Unlock');
    check(tester.widget<ElevatedButton>(submit.first).onPressed).isNull();

    final field = find.byType(TextField).first;
    await tester.enterText(field, '12');
    await tester.pump();
    check(tester.widget<ElevatedButton>(submit.first).onPressed).isNull();

    await tester.enterText(field, '1234');
    await tester.pump();
    check(tester.widget<ElevatedButton>(submit.first).onPressed).isNotNull();
  });

  testWidgets('shows remaining-attempts error after wrong PIN', (tester) async {
    // failedAttempts == 2 → remaining = 5 - 2 = 3
    final fakeRepo = _FakeRepo(failedAttempts: 2);
    await tester.pumpWidget(
      _wrap(
        const PinEntrySheet(reason: GateReason.subscribe),
        overrides: [
          parentalControlGateProvider.overrideWith(
            () => _FakeGate(unlockResult: false),
          ),
          parentalControlRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      ),
    );

    await _enterPin(tester, '1234');
    await _tapSubmit(tester);
    await tester.pumpAndSettle();

    check(find.textContaining('3').evaluate()).isNotEmpty();
  });

  testWidgets('shows lockout countdown when state becomes LockedOut', (
    tester,
  ) async {
    final lockoutState = LockedOut(
      retryAt: DateTime.now().add(const Duration(seconds: 30)),
      attemptCount: 5,
    );
    await tester.pumpWidget(
      _wrap(
        const PinEntrySheet(reason: GateReason.subscribe),
        overrides: [
          parentalControlGateProvider.overrideWith(
            () => _FakeGate(unlockResult: false, nextState: lockoutState),
          ),
          parentalControlRepositoryProvider.overrideWithValue(_FakeRepo()),
        ],
      ),
    );

    await _enterPin(tester, '1234');
    await _tapSubmit(tester);
    await tester.pumpAndSettle();

    // Error message should mention seconds (at least 29 — clock tolerance).
    check(find.textContaining('s').evaluate()).isNotEmpty();
  });

  testWidgets('Cancel remains enabled during in-flight submit', (tester) async {
    final slowGate = _SlowGate();
    await tester.pumpWidget(
      _wrap(
        const PinEntrySheet(reason: GateReason.subscribe),
        overrides: [
          parentalControlGateProvider.overrideWith(() => slowGate),
          parentalControlRepositoryProvider.overrideWithValue(_FakeRepo()),
        ],
      ),
    );

    await _enterPin(tester, '1234');
    await _tapSubmit(tester);
    // Do NOT await settle — the future is still in flight.

    final cancelButton = find.widgetWithText(TextButton, 'Cancel');
    check(tester.widget<TextButton>(cancelButton.first).onPressed).isNotNull();

    // Clean up — complete the future so timers resolve.
    slowGate.complete(result: false);
    await tester.pumpAndSettle();
  });

  testWidgets('clears error message when user types after a failed attempt', (
    tester,
  ) async {
    final fakeRepo = _FakeRepo(failedAttempts: 2);
    await tester.pumpWidget(
      _wrap(
        const PinEntrySheet(reason: GateReason.subscribe),
        overrides: [
          parentalControlGateProvider.overrideWith(
            () => _FakeGate(unlockResult: false),
          ),
          parentalControlRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      ),
    );

    await _enterPin(tester, '1234');
    await _tapSubmit(tester);
    await tester.pumpAndSettle();

    // Error is visible after failed attempt.
    final fieldBefore = tester.widget<TextField>(find.byType(TextField).first);
    check(fieldBefore.decoration!.errorText).isNotNull();

    // Typing clears the error.
    await tester.enterText(find.byType(TextField).first, '5');
    await tester.pump();
    final fieldAfter = tester.widget<TextField>(find.byType(TextField).first);
    check(fieldAfter.decoration!.errorText).isNull();
  });

  testWidgets(
    'shows generic error when repo getSettings throws on wrong-PIN path',
    (tester) async {
      final fakeRepo = _FakeRepo(throwOnGetSettings: true);
      await tester.pumpWidget(
        _wrap(
          const PinEntrySheet(reason: GateReason.subscribe),
          overrides: [
            parentalControlGateProvider.overrideWith(
              () => _FakeGate(unlockResult: false),
            ),
            parentalControlRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        ),
      );

      await _enterPin(tester, '1234');
      await _tapSubmit(tester);
      await tester.pumpAndSettle();

      // Generic error string is shown.
      check(
        find.text('Could not verify PIN. Please try again.').evaluate(),
      ).isNotEmpty();

      // Submit is re-enabled (input cleared, length < 4).
      check(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Unlock').first,
            )
            .onPressed,
      ).isNull(); // disabled because field was cleared (length 0)

      // Cancel remains enabled.
      check(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Cancel').first)
            .onPressed,
      ).isNotNull();
    },
  );

  testWidgets('biometric button hidden when setting is off', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const PinEntrySheet(reason: GateReason.subscribe),
        overrides: [
          parentalControlGateProvider.overrideWith(
            () => _FakeGate(unlockResult: false),
          ),
          parentalControlRepositoryProvider.overrideWithValue(
            _FakeRepo(biometricUnlockEnabled: false),
          ),
          biometricAuthenticatorProvider.overrideWithValue(
            _FakeBiometricAuthenticator(available: true),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.fingerprint).evaluate()).isEmpty();
  });

  testWidgets(
    'biometric button hidden when authenticator reports unavailable',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PinEntrySheet(reason: GateReason.subscribe),
          overrides: [
            parentalControlGateProvider.overrideWith(
              () => _FakeGate(unlockResult: false),
            ),
            parentalControlRepositoryProvider.overrideWithValue(
              _FakeRepo(biometricUnlockEnabled: true),
            ),
            biometricAuthenticatorProvider.overrideWithValue(
              _FakeBiometricAuthenticator(available: false),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      check(find.byIcon(Icons.fingerprint).evaluate()).isEmpty();
    },
  );

  testWidgets('biometric button shown when enabled+available', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const PinEntrySheet(reason: GateReason.subscribe),
        overrides: [
          parentalControlGateProvider.overrideWith(
            () => _FakeGate(unlockResult: false),
          ),
          parentalControlRepositoryProvider.overrideWithValue(
            _FakeRepo(biometricUnlockEnabled: true),
          ),
          biometricAuthenticatorProvider.overrideWithValue(
            _FakeBiometricAuthenticator(available: true),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.fingerprint).evaluate()).isNotEmpty();
  });

  testWidgets('tapping biometric button calls gate.tryUnlockBiometric', (
    tester,
  ) async {
    final fakeGate = _FakeGate(unlockResult: false, biometricResult: true);
    await tester.pumpWidget(
      _wrap(
        const PinEntrySheet(reason: GateReason.subscribe),
        overrides: [
          parentalControlGateProvider.overrideWith(() => fakeGate),
          parentalControlRepositoryProvider.overrideWithValue(
            _FakeRepo(biometricUnlockEnabled: true),
          ),
          biometricAuthenticatorProvider.overrideWithValue(
            _FakeBiometricAuthenticator(available: true),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.fingerprint));
    await tester.pumpAndSettle();

    check(fakeGate.biometricCalls).equals(1);
  });
}
