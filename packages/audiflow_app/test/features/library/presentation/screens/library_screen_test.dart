import 'dart:async';

import 'package:audiflow_app/features/library/presentation/controllers/continue_listening_controller.dart';
import 'package:audiflow_app/features/library/presentation/controllers/library_controller.dart';
import 'package:audiflow_app/features/library/presentation/screens/library_screen.dart';
import 'package:audiflow_app/features/station/presentation/controllers/station_list_controller.dart';
import 'package:audiflow_app/features/station/presentation/widgets/station_grid_tile.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:audiflow_app/features/library/presentation/widgets/subscription_list_tile.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

    testWidgets('shows a large Library title instead of an AppBar', (
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

      check(find.byType(AppBar).evaluate()).isEmpty();
      check(
        find.widgetWithText(LargeTitle, 'Library').evaluate(),
      ).length.equals(1);
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

  group('LibraryScreen TickerMode pause/resume', () {
    // Regression for #479: resuming a hidden LibraryScreen after
    // librarySubscriptionsProvider was invalidated re-entered Riverpod's
    // pause bookkeeping and tripped a debug assertion (riverpod < 3.3.2).
    testWidgets('survives invalidation while hidden', (tester) async {
      SharedPreferences.setMockInitialValues({
        'podcast_sort_order': PodcastSortOrder.subscribedAt.name,
      });
      final prefs = await SharedPreferences.getInstance();
      final fixtures = [_sub(1, 'Alpha'), _sub(2, 'Beta')];
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          librarySubscriptionsProvider.overrideWith(
            (ref) => Stream.value(fixtures),
          ),
          stationListProvider.overrideWith((ref) => Stream.value(<Station>[])),
        ],
      );
      addTearDown(container.dispose);
      final tickerEnabled = ValueNotifier(true);
      addTearDown(tickerEnabled.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ValueListenableBuilder<bool>(
              valueListenable: tickerEnabled,
              builder: (context, enabled, child) =>
                  TickerMode(enabled: enabled, child: child!),
              child: const LibraryScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      tickerEnabled.value = false;
      await tester.pump();
      container.invalidate(librarySubscriptionsProvider);
      await tester.pump();
      tickerEnabled.value = true;
      await tester.pumpAndSettle();

      check(tester.takeException()).isNull();
      check(find.text('Alpha').evaluate()).length.equals(1);
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

  group('LibraryScreen redesign sections', () {
    late SharedPreferences prefs;
    final fixtures = [_sub(1, 'Alpha'), _sub(2, 'Beta')];

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    EpisodeWithProgress inProgressEpisode({
      int podcastId = 1,
      String title = 'Halfway episode',
    }) {
      final episode = Episode()
        ..id = 10
        ..podcastId = podcastId
        ..guid = 'g10'
        ..title = title
        ..audioUrl = 'https://example.com/10.mp3';
      final history = PlaybackHistory()
        ..episodeId = 10
        ..positionMs = 30 * 60000
        ..durationMs = 48 * 60000;
      return EpisodeWithProgress(episode: episode, history: history);
    }

    Future<void> pump(
      WidgetTester tester, {
      List<EpisodeWithProgress> inProgress = const [],
      List<Station> stations = const [],
      double textScale = 1,
    }) async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          librarySubscriptionsProvider.overrideWith(
            (ref) => Stream.value(fixtures),
          ),
          sortedSubscriptionsProvider.overrideWith((ref) async => fixtures),
          newestEpisodeDateProvider.overrideWith(
            (ref, podcastId) => Stream.value(null),
          ),
          continueListeningEpisodesProvider.overrideWith(
            (ref) => Stream.value(inProgress),
          ),
          stationListProvider.overrideWith((ref) => Stream.value(stations)),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
            home: const LibraryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('podcasts header shows the subscription count', (tester) async {
      await pump(tester);
      // The count sits beside the title, leaving the right for the sort.
      check(
        find
            .descendant(
              of: find.widgetWithText(SectionHeader, 'Podcasts'),
              matching: find.text('2'),
            )
            .evaluate(),
      ).length.equals(1);
    });

    testWidgets('podcast rows run full width, not on an inset surface', (
      tester,
    ) async {
      await pump(tester);
      final row = tester.getRect(find.byType(SubscriptionListTile).first);
      check(row.left).equals(0);
      check(row.width).equals(800);
    });

    testWidgets('continue listening is hidden without in-progress episodes', (
      tester,
    ) async {
      await pump(tester);
      check(find.text('Continue listening').evaluate()).isEmpty();
    });

    testWidgets('continue listening shows a card with remaining time', (
      tester,
    ) async {
      await pump(tester, inProgress: [inProgressEpisode()]);
      check(find.text('Continue listening').evaluate()).length.equals(1);
      check(find.text('Halfway episode').evaluate()).length.equals(1);
      final line = tester.widget<BottomEdgeProgress>(
        find.ancestor(
          of: find.text('Halfway episode'),
          matching: find.byType(BottomEdgeProgress),
        ),
      );
      check(line.fraction).isNotNull().isCloseTo(30 / 48, 1e-9);
    });

    testWidgets('continue listening skips episodes of unsubscribed podcasts', (
      tester,
    ) async {
      await pump(tester, inProgress: [inProgressEpisode(podcastId: 99)]);
      check(find.text('Continue listening').evaluate()).isEmpty();
      check(find.text('Halfway episode').evaluate()).isEmpty();
    });

    for (final textScale in [0.85, 1.15]) {
      testWidgets('continue listening cards fit text at scale $textScale', (
        tester,
      ) async {
        final longTitle = List.filled(12, 'Long title').join(' ');
        await pump(
          tester,
          inProgress: [inProgressEpisode(title: longTitle)],
          textScale: textScale,
        );
        check(tester.takeException()).isNull();
        check(find.text(longTitle).evaluate()).length.equals(1);
      });
    }

    testWidgets('stations are laid out two per row', (tester) async {
      Station station(int id) => Station()
        ..id = id
        ..name = 'Station $id';
      await pump(tester, stations: [station(1), station(2), station(3)]);
      final tiles = find.byType(StationGridTile);
      check(tiles.evaluate()).length.equals(3);
      final first = tester.getTopLeft(tiles.at(0));
      final second = tester.getTopLeft(tiles.at(1));
      final third = tester.getTopLeft(tiles.at(2));
      check(second.dy).equals(first.dy);
      check(first.dx).isLessThan(second.dx);
      check(first.dy).isLessThan(third.dy);
    });

    Station playedStation(int id, {DateTime? lastPlayedAt}) => Station()
      ..id = id
      ..name = 'Station $id'
      ..sortOrder = id
      ..lastPlayedAt = lastPlayedAt;

    testWidgets('shows at most four stations, most recently played first', (
      tester,
    ) async {
      await pump(
        tester,
        stations: [
          for (var i = 1; i <= 5; i++) playedStation(i),
          playedStation(6, lastPlayedAt: DateTime(2026, 10)),
        ],
      );
      final tiles = find.byType(StationGridTile);
      check(tiles.evaluate()).length.equals(4);
      check(tester.widget<StationGridTile>(tiles.first).station.id).equals(6);
    });

    testWidgets('links to every station once there are more than four', (
      tester,
    ) async {
      await pump(
        tester,
        stations: [for (var i = 1; i <= 5; i++) playedStation(i)],
      );
      check(find.text('Show all').evaluate()).length.equals(1);
      check(
        find
            .descendant(
              of: find.widgetWithText(SectionHeader, 'Stations'),
              matching: find.text('5'),
            )
            .evaluate(),
      ).length.equals(1);
    });

    testWidgets('has no show-all link while every station fits', (
      tester,
    ) async {
      await pump(
        tester,
        stations: [for (var i = 1; i <= 4; i++) playedStation(i)],
      );
      check(find.textContaining('Show all').evaluate()).isEmpty();
    });

    testWidgets('the filter narrows podcasts by title or author', (
      tester,
    ) async {
      await pump(tester);
      await tester.enterText(find.byType(TextField), 'alp');
      await tester.pumpAndSettle();
      check(find.byType(SubscriptionListTile).evaluate()).length.equals(1);
      check(find.text('Alpha').evaluate()).length.equals(1);

      // Every fixture shares the author, so it matches both.
      await tester.enterText(find.byType(TextField), 'ARTIST');
      await tester.pumpAndSettle();
      check(find.byType(SubscriptionListTile).evaluate()).length.equals(2);
    });

    testWidgets('a filter matching nothing says so', (tester) async {
      await pump(tester);
      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();
      check(find.byType(SubscriptionListTile).evaluate()).isEmpty();
      check(find.text('No podcasts match').evaluate()).length.equals(1);
    });

    testWidgets('the header keeps the sort label whole at large text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pump(tester, textScale: 1.3);
      final label = tester.renderObject<RenderParagraph>(
        find.text('Latest episode'),
      );
      check(label.didExceedMaxLines).isFalse();
      check(tester.takeException()).isNull();
    });

    testWidgets('touching outside the filter drops its focus', (tester) async {
      await pump(tester);
      await tester.tap(find.byType(TextField));
      await tester.pump();
      final field = tester.widget<EditableText>(find.byType(EditableText));
      check(field.focusNode.hasFocus).isTrue();

      await tester.tapAt(tester.getCenter(find.text('Podcasts')));
      await tester.pump();
      check(field.focusNode.hasFocus).isFalse();
    });

    testWidgets('the filter survives the library emptying and refilling', (
      tester,
    ) async {
      final subscriptions = StreamController<List<Subscription>>.broadcast();
      addTearDown(subscriptions.close);
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          librarySubscriptionsProvider.overrideWith(
            (ref) => subscriptions.stream,
          ),
          sortedSubscriptionsProvider.overrideWith(
            (ref) => ref.watch(librarySubscriptionsProvider.future),
          ),
          newestEpisodeDateProvider.overrideWith(
            (ref, podcastId) => Stream.value(null),
          ),
          continueListeningEpisodesProvider.overrideWith(
            (ref) => Stream.value(const []),
          ),
          stationListProvider.overrideWith(
            (ref) => Stream.value(const <Station>[]),
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LibraryScreen(),
          ),
        ),
      );
      subscriptions.add(fixtures);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'alp');
      await tester.pumpAndSettle();

      // Emptied: the field leaves the tree with the podcast section.
      subscriptions.add(const []);
      await tester.pumpAndSettle();
      check(find.byType(TextField).evaluate()).isEmpty();

      subscriptions.add(fixtures);
      await tester.pumpAndSettle();
      final field = tester.widget<TextField>(find.byType(TextField));
      // The field shows the query that is actually applied.
      check(field.controller!.text).equals('alp');
      check(find.byType(SubscriptionListTile).evaluate()).length.equals(1);
    });

    testWidgets('the filter stays pill-shaped in every state', (tester) async {
      await pump(tester);
      final decoration = tester
          .widget<TextField>(find.byType(TextField))
          .decoration!;
      for (final border in [
        decoration.border,
        decoration.enabledBorder,
        decoration.focusedBorder,
      ]) {
        check(
          (border! as OutlineInputBorder).borderRadius,
        ).equals(AppBorders.pill);
      }
    });
  });
}
