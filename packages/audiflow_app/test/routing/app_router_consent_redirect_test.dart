import 'package:audiflow_app/features/consent/presentation/screens/consent_screen.dart';
import 'package:audiflow_app/features/onboarding/presentation/screens/onboarding_carousel_screen.dart';
import 'package:audiflow_app/features/search/presentation/screens/search_screen.dart';
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

const _onboardingKey = 'onboarding.carousel_completed_v1';

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

void main() {
  group('AppRouter consent redirect', () {
    testWidgets('pre-consent first-launch lands on ConsentScreen', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final router = createAppRouter(
        prefs: prefs,
        container: _buildRouterContainer(),
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(_buildApp(router, prefs));
      await tester.pumpAndSettle();

      expect(find.byType(ConsentScreen), findsOneWidget);
      expect(find.byType(OnboardingCarouselScreen), findsNothing);
      expect(find.byType(SearchScreen), findsNothing);
    });

    testWidgets('consent accepted but onboarding pending lands on Onboarding', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        SettingsKeys.privacyConsentAccepted: true,
      });
      final prefs = await SharedPreferences.getInstance();
      final router = createAppRouter(
        prefs: prefs,
        container: _buildRouterContainer(),
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(_buildApp(router, prefs));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingCarouselScreen), findsOneWidget);
      expect(find.byType(ConsentScreen), findsNothing);
    });

    testWidgets('fully onboarded user bypasses consent and onboarding', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        SettingsKeys.privacyConsentAccepted: true,
        _onboardingKey: true,
      });
      final prefs = await SharedPreferences.getInstance();
      final router = createAppRouter(
        prefs: prefs,
        container: _buildRouterContainer(),
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(_buildApp(router, prefs));
      await tester.pumpAndSettle();

      expect(find.byType(SearchScreen), findsOneWidget);
      expect(find.byType(ConsentScreen), findsNothing);
      expect(find.byType(OnboardingCarouselScreen), findsNothing);
    });

    testWidgets(
      'direct navigation to /onboarding without consent redirects to /consent',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final router = createAppRouter(
          prefs: prefs,
          container: _buildRouterContainer(),
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(_buildApp(router, prefs));
        router.go(AppRoutes.onboarding);
        await tester.pumpAndSettle();

        expect(find.byType(ConsentScreen), findsOneWidget);
      },
    );

    testWidgets(
      'direct navigation to /consent after acceptance forwards to onboarding',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          SettingsKeys.privacyConsentAccepted: true,
        });
        final prefs = await SharedPreferences.getInstance();
        final router = createAppRouter(
          prefs: prefs,
          container: _buildRouterContainer(),
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(_buildApp(router, prefs));
        router.go(AppRoutes.consent);
        await tester.pumpAndSettle();

        expect(find.byType(OnboardingCarouselScreen), findsOneWidget);
      },
    );
  });
}
