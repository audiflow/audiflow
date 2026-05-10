import 'dart:async';

import 'package:audiflow_app/features/library/presentation/controllers/library_controller.dart';
import 'package:audiflow_app/features/library/presentation/screens/library_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

Subscription _sub(int id, String title) {
  return Subscription()
    ..id = id
    ..itunesId = 'itunes_$id'
    ..feedUrl = 'https://example.com/$id'
    ..title = title
    ..artistName = 'Artist'
    ..subscribedAt = DateTime(2026, 1, id);
}

void main() {
  group('LibraryScreen', () {
    Widget buildTestWidget(ProviderContainer container) {
      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LibraryScreen(),
        ),
      );
    }

    testWidgets('renders loading state initially', (tester) async {
      // Use a stream controller that never emits to keep in loading state
      final controller = StreamController<List<Subscription>>();
      addTearDown(controller.close);

      final container = ProviderContainer(
        overrides: [
          librarySubscriptionsProvider.overrideWith((ref) => controller.stream),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container));

      expect(find.byType(LibraryScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays AppBar with Library title', (tester) async {
      final container = ProviderContainer(
        overrides: [
          librarySubscriptionsProvider.overrideWith(
            (ref) => Stream.value(<Subscription>[]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final titleWidget = appBar.title as Text;
      expect(titleWidget.data, equals('Library'));
    });

    testWidgets('displays empty state icon when no subscriptions', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          librarySubscriptionsProvider.overrideWith(
            (ref) => Stream.value(<Subscription>[]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container));
      await tester.pumpAndSettle();

      expect(find.byIcon(Symbols.library_music), findsOneWidget);
    });

    testWidgets('displays empty state text when no subscriptions', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          librarySubscriptionsProvider.overrideWith(
            (ref) => Stream.value(<Subscription>[]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container));
      await tester.pumpAndSettle();

      expect(find.text('No subscriptions yet'), findsOneWidget);
      expect(
        find.text('Search for podcasts and subscribe to see them here'),
        findsOneWidget,
      );
    });

    testWidgets('displays error state with retry button on error', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          librarySubscriptionsProvider.overrideWith(
            (ref) => Stream.error(Exception('Test error')),
          ),
          sortedSubscriptionsProvider.overrideWith(
            (ref) async => throw Exception('Test error'),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container));
      await tester.pumpAndSettle();

      expect(find.text('Failed to load subscriptions'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  group('LibraryScreen sort menu', () {
    late ProviderContainer container;

    Widget buildTestWidget() {
      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LibraryScreen(),
        ),
      );
    }

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final fixtures = [_sub(1, 'Alpha'), _sub(2, 'Beta')];

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          librarySubscriptionsProvider.overrideWith(
            (ref) => Stream.value(fixtures),
          ),
          sortedSubscriptionsProvider.overrideWith((ref) async => fixtures),
        ],
      );
    });

    tearDown(() => container.dispose());

    testWidgets('displays sort icon button under Your Podcasts header', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.sort), findsOneWidget);
    });

    testWidgets('opens popup menu with three sort options', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Default (latestEpisode) label is shown inline before menu opens.
      expect(find.text('Latest episode'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      // After opening, the inline label and the corresponding menu item
      // both show "Latest episode", so it appears twice.
      expect(find.text('Latest episode'), findsNWidgets(2));
      expect(find.text('Subscription date'), findsOneWidget);
      expect(find.text('Alphabetical'), findsOneWidget);
    });

    testWidgets('shows check icon on current sort order', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      final latestItem = find.ancestor(
        of: find.text('Latest episode'),
        matching: find.byType(PopupMenuItem<PodcastSortOrder>),
      );
      expect(latestItem, findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
