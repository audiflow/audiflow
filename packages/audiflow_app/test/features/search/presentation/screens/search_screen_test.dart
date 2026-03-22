import 'package:audiflow_app/features/search/presentation/controllers/search_controller.dart';
import 'package:audiflow_app/features/search/presentation/controllers/search_state.dart';
import 'package:audiflow_app/features/search/presentation/screens/search_screen.dart';
import 'package:audiflow_app/features/search/presentation/widgets/podcast_search_result_tile.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_search/audiflow_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/search_mocks.dart';

void main() {
  group('SearchScreen', () {
    late MockPodcastSearchService mockService;

    setUp(() {
      mockService = MockPodcastSearchService();
    });

    Widget buildTestWidget({ProviderContainer? container}) {
      final effectiveContainer =
          container ??
          ProviderContainer(
            overrides: [
              podcastSearchServiceProvider.overrideWithValue(mockService),
            ],
          );

      return UncontrolledProviderScope(
        container: effectiveContainer,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SearchScreen(),
        ),
      );
    }

    testWidgets('renders text input field for search query', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders search icon prefix in text field', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final textField = tester.widget<TextField>(find.byType(TextField));
      final prefixIcon = textField.decoration?.prefixIcon;
      expect(prefixIcon, isNotNull);
      expect(prefixIcon, isA<Icon>());
      final iconWidget = prefixIcon! as Icon;
      expect(iconWidget.icon, equals(Icons.search));
      expect(prefixIcon, isNot(isA<IconButton>()));
    });

    testWidgets('keyboard submit action calls controller search method', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          podcastSearchServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container: container));

      await tester.enterText(find.byType(TextField), 'keyboard test');
      await tester.pump();

      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      final state = container.read(podcastSearchControllerProvider);
      expect(state, isA<SearchSuccess>());
    });

    testWidgets('keyboard is dismissed when search is initiated', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          podcastSearchServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container: container));

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pump();
      await tester.enterText(textField, 'dismiss test');
      await tester.pump();

      final editableText = find.byType(EditableText);
      final focusNode = tester.widget<EditableText>(editableText).focusNode;

      expect(focusNode.hasFocus, isTrue);

      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(focusNode.hasFocus, isFalse);
    });

    testWidgets('watches PodcastSearchController state', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(SearchScreen), findsOneWidget);
    });

    group('UI States', () {
      testWidgets('initial state renders empty view with message', (
        tester,
      ) async {
        final container = ProviderContainer(
          overrides: [
            podcastSearchServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(buildTestWidget(container: container));

        expect(find.byKey(const Key('search_initial_state')), findsOneWidget);
        expect(find.byIcon(Icons.search), findsAtLeastNWidgets(1));
      });

      testWidgets('loading state shows loading indicator', (tester) async {
        final container = ProviderContainer(
          overrides: [
            podcastSearchServiceProvider.overrideWithValue(
              SlowMockSearchService(),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(buildTestWidget(container: container));

        await tester.enterText(find.byType(TextField), 'test query');
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byKey(const Key('search_loading_state')), findsOneWidget);
      });

      testWidgets('results state renders correct item count', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final container = ProviderContainer(
          overrides: [
            podcastSearchServiceProvider.overrideWithValue(
              ResultsMockSearchService(count: 3),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(buildTestWidget(container: container));

        await tester.enterText(find.byType(TextField), 'test query');
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('search_results_list')), findsOneWidget);
        expect(find.byKey(const Key('search_result_tile_0')), findsOneWidget);
        expect(find.byKey(const Key('search_result_tile_1')), findsOneWidget);
        expect(find.byKey(const Key('search_result_tile_2')), findsOneWidget);
      });

      testWidgets('empty results state shows not-found UI', (tester) async {
        final container = ProviderContainer(
          overrides: [
            podcastSearchServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(buildTestWidget(container: container));

        await tester.enterText(find.byType(TextField), 'no results query');
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('search_empty_state')), findsOneWidget);
        expect(find.byIcon(Icons.search_off), findsOneWidget);
        expect(find.text('No podcasts found'), findsOneWidget);
      });

      testWidgets('error state shows message and retry button', (tester) async {
        final container = ProviderContainer(
          overrides: [
            podcastSearchServiceProvider.overrideWithValue(
              ErrorMockSearchService(),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(buildTestWidget(container: container));

        await tester.enterText(find.byType(TextField), 'error query');
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('search_error_state')), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('retry button tap triggers retry', (tester) async {
        final retryMock = RetryMockSearchService();
        final container = ProviderContainer(
          overrides: [
            podcastSearchServiceProvider.overrideWithValue(retryMock),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(buildTestWidget(container: container));

        await tester.enterText(find.byType(TextField), 'retry query');
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('search_error_state')), findsOneWidget);

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        final state = container.read(podcastSearchControllerProvider);
        expect(state, isA<SearchSuccess>());
        expect(retryMock.callCount, equals(2));
      });
    });

    group('SearchRefreshing state', () {
      testWidgets('shows dimmed previous results during refresh', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final trackingService = QueryTrackingMockSearchService();
        final container = ProviderContainer(
          overrides: [
            podcastSearchServiceProvider.overrideWithValue(trackingService),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(buildTestWidget(container: container));

        // First search: submit and complete with 2 results
        await tester.enterText(find.byType(TextField), 'first query');
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump();

        final firstResult = SearchResult(
          totalCount: 2,
          podcasts: [
            Podcast(id: '1', name: 'Podcast 1', artistName: 'Artist 1'),
            Podcast(id: '2', name: 'Podcast 2', artistName: 'Artist 2'),
          ],
          provider: 'mock',
          timestamp: DateTime.now(),
        );
        trackingService.complete(0, firstResult);
        await tester.pumpAndSettle();

        // Second search: submit but do not complete
        await tester.enterText(find.byType(TextField), 'second query');
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump();

        // Verify refreshing state UI
        final refreshingFinder = find.byKey(
          const Key('search_refreshing_state'),
        );
        expect(refreshingFinder, findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);

        // Scope Opacity check to the refreshing state subtree
        final opacityFinder = find.descendant(
          of: refreshingFinder,
          matching: find.byType(Opacity),
        );
        final opacityWidget = tester.widget<Opacity>(opacityFinder.first);
        expect(opacityWidget.opacity, equals(0.4));

        // Scope tile check to the refreshing state subtree
        // (AnimatedSwitcher may keep the outgoing child during transition)
        final tileFinder = find.descendant(
          of: refreshingFinder,
          matching: find.byType(PodcastSearchResultTile),
        );
        expect(tileFinder, findsNWidgets(2));

        // Clean up: complete the pending search
        trackingService.complete(1);
      });

      testWidgets('progress indicator has loading semantics', (tester) async {
        final trackingService = QueryTrackingMockSearchService();
        final container = ProviderContainer(
          overrides: [
            podcastSearchServiceProvider.overrideWithValue(trackingService),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(buildTestWidget(container: container));

        // First search: submit and complete
        await tester.enterText(find.byType(TextField), 'first');
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump();
        trackingService.complete(
          0,
          SearchResult(
            totalCount: 1,
            podcasts: [Podcast(id: '1', name: 'P1', artistName: 'A1')],
            provider: 'mock',
            timestamp: DateTime.now(),
          ),
        );
        await tester.pumpAndSettle();

        // Second search: trigger refreshing state
        await tester.enterText(find.byType(TextField), 'second');
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump();

        // Verify Semantics label on LinearProgressIndicator
        // Use .first because multiple Semantics ancestors may exist
        final semanticsFinder = find.ancestor(
          of: find.byType(LinearProgressIndicator),
          matching: find.byType(Semantics),
        );
        final semanticsWidget = tester.widget<Semantics>(semanticsFinder.first);
        expect(semanticsWidget.properties.label, isNotNull);
        expect(semanticsWidget.properties.label, isNotEmpty);

        // Clean up
        trackingService.complete(1);
      });
    });

    group('SearchError with lastResult', () {
      testWidgets('shows dimmed results with inline error banner', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final trackingService = QueryTrackingMockSearchService();
        final container = ProviderContainer(
          overrides: [
            podcastSearchServiceProvider.overrideWithValue(trackingService),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(buildTestWidget(container: container));

        // First search: succeed with 2 results
        await tester.enterText(find.byType(TextField), 'first query');
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump();

        trackingService.complete(
          0,
          SearchResult(
            totalCount: 2,
            podcasts: [
              Podcast(id: '1', name: 'Podcast 1', artistName: 'Artist 1'),
              Podcast(id: '2', name: 'Podcast 2', artistName: 'Artist 2'),
            ],
            provider: 'mock',
            timestamp: DateTime.now(),
          ),
        );
        await tester.pumpAndSettle();

        // Second search: fail with error
        await tester.enterText(find.byType(TextField), 'error query');
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump();

        trackingService.fail(
          1,
          SearchException.unavailable(
            providerId: 'mock',
            message: 'Network error',
          ),
        );
        await tester.pumpAndSettle();

        // Verify error-with-results state UI
        expect(
          find.byKey(const Key('search_error_with_results_state')),
          findsOneWidget,
        );
        expect(find.byType(MaterialBanner), findsOneWidget);

        final scopedOpacity = find.descendant(
          of: find.byKey(const Key('search_error_with_results_state')),
          matching: find.byType(Opacity),
        );
        final opacityWidget = tester.widget<Opacity>(scopedOpacity.first);
        expect(opacityWidget.opacity, equals(0.4));

        expect(find.byType(PodcastSearchResultTile), findsNWidgets(2));
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('shows full error state when no lastResult', (tester) async {
        final container = ProviderContainer(
          overrides: [
            podcastSearchServiceProvider.overrideWithValue(
              ErrorMockSearchService(),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(buildTestWidget(container: container));

        await tester.enterText(find.byType(TextField), 'error query');
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();

        // Full error state, no MaterialBanner
        expect(find.byKey(const Key('search_error_state')), findsOneWidget);
        expect(find.byType(MaterialBanner), findsNothing);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });
    });

    group('Debounce flow', () {
      testWidgets(
        'typing does not fire search immediately, fires after 500ms',
        (tester) async {
          final trackingService = QueryTrackingMockSearchService();
          final container = ProviderContainer(
            overrides: [
              podcastSearchServiceProvider.overrideWithValue(trackingService),
            ],
          );
          addTearDown(container.dispose);

          await tester.pumpWidget(buildTestWidget(container: container));

          // Type query via enterText (triggers onQueryChanged, not submit)
          await tester.enterText(find.byType(TextField), 'flutter');
          await tester.pump();

          // No search should fire immediately
          expect(trackingService.queries, isEmpty);

          // Advance past debounce (500ms)
          await tester.pump(const Duration(milliseconds: 500));

          // Now search should have fired
          expect(trackingService.queries.length, equals(1));
          expect(trackingService.queries.first, equals('flutter'));

          // Complete to avoid dangling future
          trackingService.complete(0);
          await tester.pumpAndSettle();
        },
      );

      testWidgets('continued typing resets debounce, only final query fires', (
        tester,
      ) async {
        final trackingService = QueryTrackingMockSearchService();
        final container = ProviderContainer(
          overrides: [
            podcastSearchServiceProvider.overrideWithValue(trackingService),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(buildTestWidget(container: container));

        // Type partial query
        await tester.enterText(find.byType(TextField), 'fl');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Continue typing
        await tester.enterText(find.byType(TextField), 'flutter');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Continue again
        await tester.enterText(find.byType(TextField), 'flutter podcast');
        await tester.pump();

        // No search yet
        expect(trackingService.queries, isEmpty);

        // Advance past debounce from last keystroke
        await tester.pump(const Duration(milliseconds: 500));

        // Only the final query fires
        expect(trackingService.queries.length, equals(1));
        expect(trackingService.queries.first, equals('flutter podcast'));

        // Complete to avoid dangling future
        trackingService.complete(0);
        await tester.pumpAndSettle();
      });
    });
  });
}
