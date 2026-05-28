import 'dart:async';

import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_app/routing/app_router.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/search_mocks.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildApp(GoRouter router, SharedPreferences prefs) {
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      appSettingsRepositoryProvider.overrideWithValue(
        FakeAppSettingsRepository(),
      ),
    ],
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('parental-control redirect — fail-open during stream loading', () {
    /// When [parentalControlSettingsStreamProvider] is still loading (no data
    /// yet), the router redirect must NOT send the user to /library.
    ///
    /// The router reads the raw stream provider and uses `maybeWhen(orElse: ()
    /// => false)`, so a loading state is treated as "not restricted" and the
    /// user stays on the requested route.
    testWidgets('loading settings stream does not redirect to library', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        SettingsKeys.privacyConsentAccepted: true,
        'onboarding.carousel_completed_v1': true,
      });
      final prefs = await SharedPreferences.getInstance();

      // Override with a stream that never emits — simulates cold-launch load.
      final container = ProviderContainer(
        overrides: [
          // Gate provider: gate is locked (worst case for cold launch).
          isUnlockedProvider.overrideWithValue(false),
          // Settings stream: never emits data — still loading.
          parentalControlSettingsStreamProvider.overrideWith(
            (ref) => const Stream.empty(),
          ),
          // isRestrictedModeOn must also be overridden because the
          // _ParentalControlRefreshNotifier listens to it.
          isRestrictedModeOnProvider.overrideWithValue(false),
        ],
      );
      addTearDown(container.dispose);

      final router = createAppRouter(prefs: prefs, container: container);
      addTearDown(router.dispose);

      await tester.pumpWidget(_buildApp(router, prefs));
      await tester.pumpAndSettle();

      // The router must not have redirected to /library.
      // The current location should be /search (the default initial tab).
      check(router.state.matchedLocation).equals(AppRoutes.search);
    });

    testWidgets('restricted+locked redirects restricted path to library', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        SettingsKeys.privacyConsentAccepted: true,
        'onboarding.carousel_completed_v1': true,
      });
      final prefs = await SharedPreferences.getInstance();

      final s = ParentalControlSettings()..restrictedModeEnabled = true;
      // Use a sync StreamController so the event is delivered synchronously
      // when add() is called — no microtask delay.
      final settingsController =
          StreamController<ParentalControlSettings>.broadcast(sync: true);

      final container = ProviderContainer(
        overrides: [
          isUnlockedProvider.overrideWithValue(false),
          parentalControlSettingsStreamProvider.overrideWith(
            (ref) => settingsController.stream,
          ),
          isRestrictedModeOnProvider.overrideWithValue(true),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(settingsController.close);

      // Mount the provider (starts listening), then emit synchronously so the
      // AsyncValue is in data state before createAppRouter runs its redirect.
      container.read(parentalControlSettingsStreamProvider);
      settingsController.add(s);

      // Default tab (0) starts on /search, which is in _kRestrictedPaths.
      final router = createAppRouter(prefs: prefs, container: container);
      addTearDown(router.dispose);

      await tester.pumpWidget(_buildApp(router, prefs));
      await tester.pumpAndSettle();

      // /search is a restricted path; restricted+locked should redirect to /library.
      check(router.state.matchedLocation).equals(AppRoutes.library);
    });

    testWidgets('restricted+unlocked does NOT redirect', (tester) async {
      SharedPreferences.setMockInitialValues({
        SettingsKeys.privacyConsentAccepted: true,
        'onboarding.carousel_completed_v1': true,
      });
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          isUnlockedProvider.overrideWithValue(true),
          parentalControlSettingsStreamProvider.overrideWith((ref) {
            final s = ParentalControlSettings()..restrictedModeEnabled = true;
            return Stream.value(s);
          }),
          isRestrictedModeOnProvider.overrideWithValue(true),
        ],
      );
      addTearDown(container.dispose);

      final router = createAppRouter(prefs: prefs, container: container);
      addTearDown(router.dispose);

      await tester.pumpWidget(_buildApp(router, prefs));
      await tester.pumpAndSettle();

      // Unlocked — no redirect even when restricted.
      check(router.state.matchedLocation).equals(AppRoutes.search);
    });
  });
}
