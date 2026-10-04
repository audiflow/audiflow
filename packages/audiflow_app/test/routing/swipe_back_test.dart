import 'dart:async';

import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_app/routing/app_router.dart';
import 'package:audiflow_app/routing/material_route.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/search_mocks.dart';

void main() {
  group('materialRoute', () {
    testWidgets('builds a MaterialPage keyed by the route state', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/a',
        routes: [materialRoute(path: '/a', builder: (_, _) => const Text('a'))],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      final route = ModalRoute.of(tester.element(find.text('a')))!;
      check(route).isA<MaterialRouteTransitionMixin<void>>();
      check(route.settings).isA<MaterialPage<void>>();
      check(route.settings.name).equals('/a');
    });
  });

  group('AppRouter swipe-to-back', () {
    late GoRouter router;
    late SharedPreferences prefs;
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        SettingsKeys.privacyConsentAccepted: true,
        'onboarding.carousel_completed_v1': true,
      });
      prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          isRestrictedModeOnProvider.overrideWithValue(false),
          isUnlockedProvider.overrideWithValue(true),
          // Keep the redirect off Isar; a loading stream fails open.
          parentalControlSettingsStreamProvider.overrideWith(
            (ref) => const Stream.empty(),
          ),
        ],
      );
      router = createAppRouter(prefs: prefs, container: container);
    });

    tearDown(() {
      router.dispose();
      container.dispose();
    });

    Widget buildTestApp() {
      return ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appSettingsRepositoryProvider.overrideWithValue(
            FakeAppSettingsRepository(),
          ),
          isRestrictedModeOnProvider.overrideWithValue(false),
          isUnlockedProvider.overrideWithValue(true),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );
    }

    testWidgets('iOS edge swipe pops a pushed tab-branch screen', (
      tester,
    ) async {
      // Phone portrait: the default 800x600 surface is a tablet in
      // landscape, whose NavigationRail occupies the left edge.
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();
      router.go(AppRoutes.settings);
      await tester.pumpAndSettle();
      unawaited(router.push(AppRoutes.settingsPrivacy));
      await tester.pumpAndSettle();
      check(router.state.matchedLocation).equals(AppRoutes.settingsPrivacy);

      await tester.dragFrom(const Offset(5, 300), const Offset(300, 0));
      await tester.pumpAndSettle();

      check(router.state.matchedLocation).equals(AppRoutes.settings);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
  });
}
