import 'package:audiflow_app/features/parental_control/domain/gate_guard.dart';
import 'package:audiflow_app/features/parental_control/presentation/screens/parental_control_settings_screen.dart';
import 'package:audiflow_app/features/parental_control/providers/gate_guard_provider.dart';
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
  // Mirror the real route paths so that AppRoutes.parentalControlPinSetup /
  // AppRoutes.parentalControlPinChange absolute pushes resolve correctly.
  final router = GoRouter(
    initialLocation: '/settings/parental-control',
    routes: [
      GoRoute(
        path: '/settings',
        builder: (_, _) => const Scaffold(body: Text('settings')),
        routes: [
          GoRoute(
            path: 'parental-control',
            builder: (_, _) => child,
            routes: [
              GoRoute(
                path: 'pin-setup',
                builder: (_, _) =>
                    const Scaffold(body: Text('pin-setup screen')),
              ),
              GoRoute(
                path: 'pin-change',
                builder: (_, _) =>
                    const Scaffold(body: Text('pin-change screen')),
              ),
            ],
          ),
        ],
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
  _FakeRepo({ParentalControlSettings? settings, this.throwOnWrite = false})
    : _settings = settings ?? ParentalControlSettings();

  final ParentalControlSettings _settings;
  final bool throwOnWrite;

  @override
  Stream<ParentalControlSettings> watchSettings() => Stream.value(_settings);

  @override
  Future<ParentalControlSettings> getSettings() async => _settings;

  @override
  Future<void> setRestrictedMode(bool enabled) async {
    if (throwOnWrite) throw Exception('write failed');
  }

  @override
  Future<void> setUnlockTimeout(Duration timeout) async {
    if (throwOnWrite) throw Exception('write failed');
  }

  @override
  Future<bool> verifyPin(String pin) async => false;

  @override
  Future<void> setPin(String pin) async {}

  @override
  Future<void> clearPin() async {}

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

class _FakeGateGuard implements GateGuard {
  _FakeGateGuard({required this.allows});

  final bool allows;

  @override
  Future<bool> requireUnlock(
    BuildContext context, {
    required GateReason reason,
  }) async => allows;
}

// ---------------------------------------------------------------------------
// Helpers to build overrides
// ---------------------------------------------------------------------------

List<dynamic> _overrides({
  required _FakeRepo repo,
  required _FakeGateGuard guard,
}) => [
  parentalControlRepositoryProvider.overrideWithValue(repo),
  parentalControlSettingsStreamProvider.overrideWith(
    (ref) => repo.watchSettings(),
  ),
  gateGuardProvider.overrideWithValue(guard),
];

ParentalControlSettings _settingsWithPin({
  bool restrictedMode = false,
  int unlockTimeoutMs = 300000,
}) => ParentalControlSettings()
  ..pinHashBase64 = 'dummy'
  ..restrictedModeEnabled = restrictedMode
  ..unlockTimeoutMs = unlockTimeoutMs;

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ParentalControlSettingsScreen', () {
    testWidgets('shows PIN setup tile when no PIN is set', (tester) async {
      final repo = _FakeRepo();
      final guard = _FakeGateGuard(allows: true);
      await tester.pumpWidget(
        _wrap(
          const ParentalControlSettingsScreen(),
          overrides: _overrides(repo: repo, guard: guard),
        ),
      );
      await tester.pumpAndSettle();

      check(find.byType(SwitchListTile).evaluate()).isEmpty();
      check(find.byType(DropdownButton<int>).evaluate()).isEmpty();
    });

    testWidgets('shows toggle and dropdown when PIN is set', (tester) async {
      final repo = _FakeRepo(settings: _settingsWithPin());
      final guard = _FakeGateGuard(allows: true);
      await tester.pumpWidget(
        _wrap(
          const ParentalControlSettingsScreen(),
          overrides: _overrides(repo: repo, guard: guard),
        ),
      );
      await tester.pumpAndSettle();

      check(find.byType(SwitchListTile).evaluate()).isNotEmpty();
      check(find.byType(DropdownButton<int>).evaluate()).isNotEmpty();
    });

    testWidgets('toggle denied when gate returns false', (tester) async {
      final repo = _FakeRepo(settings: _settingsWithPin());
      final guard = _FakeGateGuard(allows: false);
      await tester.pumpWidget(
        _wrap(
          const ParentalControlSettingsScreen(),
          overrides: _overrides(repo: repo, guard: guard),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the switch — gate denies, so no write and no error snackbar.
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      check(find.byType(SnackBar).evaluate()).isEmpty();
    });

    testWidgets('toggle proceeds when gate returns true', (tester) async {
      final repo = _FakeRepo(settings: _settingsWithPin());
      final guard = _FakeGateGuard(allows: true);
      await tester.pumpWidget(
        _wrap(
          const ParentalControlSettingsScreen(),
          overrides: _overrides(repo: repo, guard: guard),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      // No snackbar — write succeeded.
      check(find.byType(SnackBar).evaluate()).isEmpty();
    });

    testWidgets('toggle shows snackbar on write failure', (tester) async {
      final repo = _FakeRepo(settings: _settingsWithPin(), throwOnWrite: true);
      final guard = _FakeGateGuard(allows: true);
      await tester.pumpWidget(
        _wrap(
          const ParentalControlSettingsScreen(),
          overrides: _overrides(repo: repo, guard: guard),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      check(find.byType(SnackBar).evaluate()).isNotEmpty();
    });

    testWidgets('dropdown denied when gate returns false', (tester) async {
      final repo = _FakeRepo(settings: _settingsWithPin());
      final guard = _FakeGateGuard(allows: false);
      await tester.pumpWidget(
        _wrap(
          const ParentalControlSettingsScreen(),
          overrides: _overrides(repo: repo, guard: guard),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();
      // Gate denied — dropdown should not open / no snackbar.
      check(find.byType(SnackBar).evaluate()).isEmpty();
    });

    testWidgets('dropdown shows snackbar on write failure', (tester) async {
      final repo = _FakeRepo(
        settings: _settingsWithPin(unlockTimeoutMs: 60000),
        throwOnWrite: true,
      );
      final guard = _FakeGateGuard(allows: true);
      await tester.pumpWidget(
        _wrap(
          const ParentalControlSettingsScreen(),
          overrides: _overrides(repo: repo, guard: guard),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();
      // Select the 5 min item (value 300000).
      await tester.tap(
        find
            .descendant(
              of: find.byType(DropdownMenuItem<int>),
              matching: find.text('5 min'),
            )
            .last,
      );
      await tester.pumpAndSettle();

      check(find.byType(SnackBar).evaluate()).isNotEmpty();
    });

    testWidgets('change-PIN tile denied when gate returns false', (
      tester,
    ) async {
      final repo = _FakeRepo(settings: _settingsWithPin());
      final guard = _FakeGateGuard(allows: false);
      await tester.pumpWidget(
        _wrap(
          const ParentalControlSettingsScreen(),
          overrides: _overrides(repo: repo, guard: guard),
        ),
      );
      await tester.pumpAndSettle();

      // The change-PIN tile is the ListTile with chevron_right that is NOT the
      // timeout tile (which has a DropdownButton as trailing).
      final changePinTile = find.ancestor(
        of: find.byIcon(Icons.chevron_right),
        matching: find.byType(ListTile),
      );
      await tester.tap(changePinTile);
      await tester.pumpAndSettle();

      // Gate denied — should not have navigated.
      check(find.text('pin-change screen').evaluate()).isEmpty();
    });

    testWidgets('change-PIN tile navigates when gate returns true', (
      tester,
    ) async {
      final repo = _FakeRepo(settings: _settingsWithPin());
      final guard = _FakeGateGuard(allows: true);
      await tester.pumpWidget(
        _wrap(
          const ParentalControlSettingsScreen(),
          overrides: _overrides(repo: repo, guard: guard),
        ),
      );
      await tester.pumpAndSettle();

      final changePinTile = find.ancestor(
        of: find.byIcon(Icons.chevron_right),
        matching: find.byType(ListTile),
      );
      await tester.tap(changePinTile);
      await tester.pumpAndSettle();

      check(find.text('pin-change screen').evaluate()).isNotEmpty();
    });

    testWidgets('stream error shows unavailable message', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParentalControlSettingsScreen(),
          overrides: [
            parentalControlSettingsStreamProvider.overrideWith(
              (ref) => Stream.error(Exception('db error')),
            ),
            gateGuardProvider.overrideWithValue(_FakeGateGuard(allows: true)),
          ],
        ),
      );
      await tester.pumpAndSettle();

      check(
        find.textContaining('unavailable', findRichText: true).evaluate(),
      ).isNotEmpty();
    });

    testWidgets('biometric toggle hidden when platform unsupported', (
      tester,
    ) async {
      final repo = _FakeRepo(settings: _settingsWithPin());
      final guard = _FakeGateGuard(allows: true);
      await tester.pumpWidget(
        _wrap(
          const ParentalControlSettingsScreen(),
          overrides: [
            ..._overrides(repo: repo, guard: guard),
            biometricAuthenticatorProvider.overrideWithValue(
              _FakeBiometricAuthenticator(available: false),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Only the restricted-mode SwitchListTile renders; biometric is hidden.
      check(
        find.byType(SwitchListTile).evaluate(),
      ).has((e) => e.length, 'count').equals(1);
    });

    testWidgets('biometric toggle visible when platform supports it', (
      tester,
    ) async {
      final repo = _FakeRepo(settings: _settingsWithPin());
      final guard = _FakeGateGuard(allows: true);
      await tester.pumpWidget(
        _wrap(
          const ParentalControlSettingsScreen(),
          overrides: [
            ..._overrides(repo: repo, guard: guard),
            biometricAuthenticatorProvider.overrideWithValue(
              _FakeBiometricAuthenticator(available: true),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Restricted-mode + biometric toggles both render.
      check(
        find.byType(SwitchListTile).evaluate(),
      ).has((e) => e.length, 'count').equals(2);
    });
  });
}

class _FakeBiometricAuthenticator implements BiometricAuthenticator {
  _FakeBiometricAuthenticator({required this.available});

  final bool available;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate({required String localizedReason}) async => true;
}
