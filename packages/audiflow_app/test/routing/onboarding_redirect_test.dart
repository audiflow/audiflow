import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_app/routing/app_router.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/search_mocks.dart';

/// Builds a [ProviderContainer] suitable for router tests.
///
/// Overrides parental-control providers so the redirect does not access Isar.
ProviderContainer _buildRouterContainer() {
  return ProviderContainer(
    overrides: [
      isRestrictedModeOnProvider.overrideWithValue(false),
      isUnlockedProvider.overrideWithValue(true),
    ],
  );
}

void main() {
  group('AppRouter onboarding redirect', () {
    Future<(GoRouter, Widget)> buildRouterApp({required bool completed}) async {
      // Consent is accepted here so these tests exercise the onboarding
      // redirect in isolation; the consent gate is covered separately.
      SharedPreferences.setMockInitialValues(
        completed
            ? <String, Object>{
                SettingsKeys.privacyConsentAccepted: true,
                'onboarding.carousel_completed_v1': true,
              }
            : <String, Object>{SettingsKeys.privacyConsentAccepted: true},
      );
      final prefs = await SharedPreferences.getInstance();
      final router = createAppRouter(
        prefs: prefs,
        container: _buildRouterContainer(),
      );
      addTearDown(router.dispose);
      final app = ProviderScope(
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
      return (router, app);
    }

    testWidgets('redirects to /onboarding when flag absent', (tester) async {
      final (router, app) = await buildRouterApp(completed: false);
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      expect(
        router.routerDelegate.currentConfiguration.fullPath,
        AppRoutes.onboarding,
      );
    });

    testWidgets('does not redirect when flag is true', (tester) async {
      final (router, app) = await buildRouterApp(completed: true);
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      expect(
        router.routerDelegate.currentConfiguration.fullPath,
        AppRoutes.search,
      );
    });

    testWidgets(
      'navigating to /onboarding after completion redirects to /search',
      (tester) async {
        final (router, app) = await buildRouterApp(completed: true);
        await tester.pumpWidget(app);
        await tester.pumpAndSettle();

        router.go(AppRoutes.onboarding);
        await tester.pumpAndSettle();

        expect(
          router.routerDelegate.currentConfiguration.fullPath,
          AppRoutes.search,
        );
      },
    );
  });
}
