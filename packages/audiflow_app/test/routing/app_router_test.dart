import 'package:audiflow_app/features/library/presentation/screens/library_screen.dart';
import 'package:audiflow_app/features/podcast_detail/presentation/screens/podcast_detail_screen.dart';
import 'package:audiflow_app/features/search/presentation/screens/search_screen.dart';
import 'package:audiflow_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_app/routing/app_router.dart';
import 'package:audiflow_app/routing/scaffold_with_nav_bar.dart';
import 'package:audiflow_domain/audiflow_domain.dart'
    hide podcastSearchServiceProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/search_mocks.dart';

void main() {
  group('AppRouter', () {
    late GoRouter router;

    setUp(() {
      router = createAppRouter();
    });

    tearDown(() {
      router.dispose();
    });

    Widget buildTestApp() {
      return ProviderScope(
        overrides: [
          voiceCommandOrchestratorProvider.overrideWith(
            () => _MockVoiceCommandOrchestrator(),
          ),
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

    group('Tab Navigation', () {
      testWidgets('default tab is Search', (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        expect(find.byType(SearchScreen), findsOneWidget);
        expect(find.byType(LibraryScreen), findsNothing);
        expect(find.byType(SettingsScreen), findsNothing);
      });

      testWidgets('displays bottom navigation bar with three destinations', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(NavigationDestination), findsNWidgets(4));
        expect(find.text('Search'), findsOneWidget);
        expect(find.text('Library'), findsOneWidget);
        expect(find.text('Queue'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);
      });

      testWidgets('navigation to Library tab works correctly', (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Library'));
        await tester.pumpAndSettle();

        expect(find.byType(LibraryScreen), findsOneWidget);
      });

      testWidgets('navigation to Settings tab works correctly', (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        expect(find.byType(SettingsScreen), findsOneWidget);
      });

      testWidgets('each tab maintains its own navigation stack', (
        tester,
      ) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Navigate to podcast detail within Search tab (with extra data)
        final podcast = Podcast(
          id: '123',
          name: 'Test Podcast',
          artistName: 'Test Artist',
        );
        router.push('/search/podcast/123', extra: podcast);
        await tester.pumpAndSettle();

        expect(find.byType(PodcastDetailScreen), findsOneWidget);
        expect(find.text('Test Podcast'), findsOneWidget);

        // Switch to Library tab
        await tester.tap(find.text('Library'));
        await tester.pumpAndSettle();

        expect(find.byType(LibraryScreen), findsOneWidget);

        // Switch back to Search tab - should still be on detail page
        await tester.tap(find.text('Search'));
        await tester.pumpAndSettle();

        expect(find.byType(PodcastDetailScreen), findsOneWidget);
      });

      testWidgets('tapping current tab returns to root', (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Navigate to podcast detail within Search tab (with extra data)
        final podcast = Podcast(
          id: '123',
          name: 'Test Podcast',
          artistName: 'Test Artist',
        );
        router.push('/search/podcast/123', extra: podcast);
        await tester.pumpAndSettle();

        expect(find.byType(PodcastDetailScreen), findsOneWidget);

        // Tap Search tab again to return to root
        await tester.tap(find.text('Search'));
        await tester.pumpAndSettle();

        expect(find.byType(SearchScreen), findsOneWidget);
        expect(find.byType(PodcastDetailScreen), findsNothing);
      });
    });

    group('Route Matching', () {
      testWidgets('search route navigates to SearchScreen', (tester) async {
        await tester.pumpWidget(buildTestApp());

        router.go('/search');
        await tester.pumpAndSettle();

        expect(find.byType(SearchScreen), findsOneWidget);
      });

      testWidgets('library route navigates to LibraryScreen', (tester) async {
        await tester.pumpWidget(buildTestApp());

        router.go('/library');
        await tester.pumpAndSettle();

        expect(find.byType(LibraryScreen), findsOneWidget);
      });

      testWidgets('settings route navigates to SettingsScreen', (tester) async {
        await tester.pumpWidget(buildTestApp());

        router.go('/settings');
        await tester.pumpAndSettle();

        expect(find.byType(SettingsScreen), findsOneWidget);
      });

      testWidgets('podcast detail route shows not found without extra', (
        tester,
      ) async {
        await tester.pumpWidget(buildTestApp());

        router.go('/search/podcast/456');
        await tester.pumpAndSettle();

        // Without extra data, should show not found screen
        expect(find.text('Podcast Not Found'), findsOneWidget);
        expect(find.text('Podcast data not available'), findsOneWidget);
      });

      testWidgets('podcast detail route shows podcast with extra data', (
        tester,
      ) async {
        await tester.pumpWidget(buildTestApp());

        final podcast = Podcast(
          id: '456',
          name: 'Another Podcast',
          artistName: 'Another Artist',
        );
        router.push('/search/podcast/456', extra: podcast);
        await tester.pumpAndSettle();

        expect(find.byType(PodcastDetailScreen), findsOneWidget);
        expect(find.text('Another Podcast'), findsOneWidget);
      });

      test('router configuration includes all routes', () {
        final config = router.routeInformationParser.configuration;

        expect(config.findMatch(Uri.parse('/search')), isNotNull);
        expect(config.findMatch(Uri.parse('/library')), isNotNull);
        expect(config.findMatch(Uri.parse('/settings')), isNotNull);
        expect(config.findMatch(Uri.parse('/search/podcast/123')), isNotNull);
      });
    });

    group('ScaffoldWithNavBar', () {
      testWidgets('wraps content with navigation shell', (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        expect(find.byType(ScaffoldWithNavBar), findsOneWidget);
      });
    });
  });
}

/// Mock orchestrator that returns idle state.
class _MockVoiceCommandOrchestrator extends VoiceCommandOrchestrator {
  @override
  VoiceRecognitionState build() => const VoiceRecognitionState.idle();
}
