import 'package:audiflow_app/features/search/presentation/controllers/search_controller.dart';
import 'package:audiflow_app/features/search/presentation/controllers/search_state.dart';
import 'package:audiflow_app/features/search/presentation/screens/search_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_app/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/search_mocks.dart';

void main() {
  group('Search Integration Tests', () {
    group('Task 5.1: Navigation to podcast detail', () {
      testWidgets('tapping search result navigates to podcast detail screen', (
        tester,
      ) async {
        String? navigatedPodcastId;
        final mockService = ResultsMockSearchService(count: 3);
        final container = ProviderContainer(
          overrides: [
            podcastSearchServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        final router = GoRouter(
          initialLocation: AppRoutes.search,
          routes: [
            GoRoute(
              path: AppRoutes.search,
              builder: (context, state) => const SearchScreen(),
            ),
            GoRoute(
              path: '${AppRoutes.podcastDetail}/:id',
              builder: (context, state) {
                navigatedPodcastId = state.pathParameters['id'];
                return Scaffold(
                  body: Text('Podcast Detail: $navigatedPodcastId'),
                );
              },
            ),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: router,
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), 'test query');
        await tester.pump();
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('search_result_tile_0')), findsOneWidget);

        await tester.tap(find.byKey(const Key('search_result_tile_0')));
        await tester.pumpAndSettle();

        expect(navigatedPodcastId, equals('podcast_0'));
        expect(find.text('Podcast Detail: podcast_0'), findsOneWidget);
      });

      testWidgets('extracts correct podcast identifier from tapped result', (
        tester,
      ) async {
        final mockService = CustomIdMockSearchService(
          ids: ['itunes_12345', 'itunes_67890', 'itunes_11111'],
        );
        String? navigatedPodcastId;
        final container = ProviderContainer(
          overrides: [
            podcastSearchServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        final router = GoRouter(
          initialLocation: AppRoutes.search,
          routes: [
            GoRoute(
              path: AppRoutes.search,
              builder: (context, state) => const SearchScreen(),
            ),
            GoRoute(
              path: '${AppRoutes.podcastDetail}/:id',
              builder: (context, state) {
                navigatedPodcastId = state.pathParameters['id'];
                return Scaffold(body: Text('Detail: $navigatedPodcastId'));
              },
            ),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: router,
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), 'test');
        await tester.pump();
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('search_result_tile_1')));
        await tester.pumpAndSettle();

        expect(navigatedPodcastId, equals('itunes_67890'));
      });
    });

    group('Task 5.2: Keyboard dismissal behavior', () {
      testWidgets('keyboard is dismissed before search request begins', (
        tester,
      ) async {
        final slowMock = SlowMockSearchService();
        final container = ProviderContainer(
          overrides: [podcastSearchServiceProvider.overrideWithValue(slowMock)],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const SearchScreen(),
            ),
          ),
        );

        final textField = find.byType(TextField);
        await tester.tap(textField);
        await tester.pump();
        await tester.enterText(textField, 'test query');
        await tester.pump();

        final editableText = find.byType(EditableText);
        final focusNode = tester.widget<EditableText>(editableText).focusNode;
        expect(focusNode.hasFocus, isTrue);

        await tester.tap(find.byType(IconButton));
        await tester.pump();

        expect(focusNode.hasFocus, isFalse);

        final state = container.read(podcastSearchControllerProvider);
        expect(state, isA<SearchLoading>());
      });

      testWidgets('keyboard hides on Enter key submission', (tester) async {
        final mockService = MockPodcastSearchService();
        final container = ProviderContainer(
          overrides: [
            podcastSearchServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const SearchScreen(),
            ),
          ),
        );

        final textField = find.byType(TextField);
        await tester.tap(textField);
        await tester.pump();
        await tester.enterText(textField, 'keyboard test');
        await tester.pump();

        final editableText = find.byType(EditableText);
        final focusNode = tester.widget<EditableText>(editableText).focusNode;
        expect(focusNode.hasFocus, isTrue);

        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump();

        expect(focusNode.hasFocus, isFalse);
      });
    });

    group('Task 5.3: End-to-end search flow scenario tests', () {
      testWidgets(
        'complete flow: enter query, submit, receive results, tap result',
        (tester) async {
          final mockService = ResultsMockSearchService(count: 5);
          String? navigatedPodcastId;
          final container = ProviderContainer(
            overrides: [
              podcastSearchServiceProvider.overrideWithValue(mockService),
            ],
          );
          addTearDown(container.dispose);

          final router = GoRouter(
            initialLocation: AppRoutes.search,
            routes: [
              GoRoute(
                path: AppRoutes.search,
                builder: (context, state) => const SearchScreen(),
              ),
              GoRoute(
                path: '${AppRoutes.podcastDetail}/:id',
                builder: (context, state) {
                  navigatedPodcastId = state.pathParameters['id'];
                  return Scaffold(
                    body: Center(
                      child: Text('Podcast Detail: $navigatedPodcastId'),
                    ),
                  );
                },
              ),
            ],
          );

          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp.router(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                routerConfig: router,
              ),
            ),
          );

          expect(find.byKey(const Key('search_initial_state')), findsOneWidget);
          expect(find.byType(TextField), findsOneWidget);
          expect(find.byType(IconButton), findsOneWidget);

          await tester.enterText(find.byType(TextField), 'technology podcasts');
          await tester.pump();

          await tester.tap(find.byType(IconButton));
          await tester.pump();

          await tester.pumpAndSettle();

          expect(find.byKey(const Key('search_results_list')), findsOneWidget);
          expect(find.byKey(const Key('search_result_tile_0')), findsOneWidget);

          for (int i = 0; 5 > i; i++) {
            expect(find.byKey(Key('search_result_tile_$i')), findsOneWidget);
          }

          await tester.tap(find.byKey(const Key('search_result_tile_2')));
          await tester.pumpAndSettle();

          expect(navigatedPodcastId, equals('podcast_2'));
          expect(find.text('Podcast Detail: podcast_2'), findsOneWidget);
        },
      );

      testWidgets(
        'error flow: enter query, submit, receive error, tap retry, receive results',
        (tester) async {
          final retryMock = RetryMockSearchService();
          final container = ProviderContainer(
            overrides: [
              podcastSearchServiceProvider.overrideWithValue(retryMock),
            ],
          );
          addTearDown(container.dispose);

          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const SearchScreen(),
              ),
            ),
          );

          await tester.enterText(find.byType(TextField), 'test query');
          await tester.pump();
          await tester.tap(find.byType(IconButton));
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('search_error_state')), findsOneWidget);
          expect(find.byIcon(Icons.error_outline), findsOneWidget);
          expect(find.text('Retry'), findsOneWidget);
          expect(retryMock.callCount, equals(1));

          await tester.tap(find.text('Retry'));
          await tester.pumpAndSettle();

          final state = container.read(podcastSearchControllerProvider);
          expect(state, isA<SearchSuccess>());
          expect(retryMock.callCount, equals(2));

          expect(find.byKey(const Key('search_empty_state')), findsOneWidget);
        },
      );

      testWidgets(
        'empty results flow: enter query, submit, receive empty response',
        (tester) async {
          final mockService = MockPodcastSearchService();
          final container = ProviderContainer(
            overrides: [
              podcastSearchServiceProvider.overrideWithValue(mockService),
            ],
          );
          addTearDown(container.dispose);

          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const SearchScreen(),
              ),
            ),
          );

          expect(find.byKey(const Key('search_initial_state')), findsOneWidget);

          await tester.enterText(find.byType(TextField), 'xyznonexistent123');
          await tester.pump();
          await tester.tap(find.byType(IconButton));
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('search_empty_state')), findsOneWidget);
          expect(find.byIcon(Icons.search_off), findsOneWidget);
          expect(find.text('No podcasts found'), findsOneWidget);
          expect(find.text('Try a different search term'), findsOneWidget);
        },
      );

      testWidgets('keyboard dismissal in full flow', (tester) async {
        final mockService = ResultsMockSearchService(count: 3);
        final container = ProviderContainer(
          overrides: [
            podcastSearchServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const SearchScreen(),
            ),
          ),
        );

        final textField = find.byType(TextField);
        await tester.tap(textField);
        await tester.pump();
        await tester.enterText(textField, 'test');
        await tester.pump();

        final editableText = find.byType(EditableText);
        final focusNode = tester.widget<EditableText>(editableText).focusNode;

        expect(focusNode.hasFocus, isTrue);

        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        expect(focusNode.hasFocus, isFalse);

        expect(find.byKey(const Key('search_results_list')), findsOneWidget);
      });

      testWidgets('duplicate submission prevention during loading', (
        tester,
      ) async {
        final slowMock = SlowMockSearchService();
        final container = ProviderContainer(
          overrides: [podcastSearchServiceProvider.overrideWithValue(slowMock)],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const SearchScreen(),
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), 'test query');
        await tester.pump();
        await tester.tap(find.byType(IconButton));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        final iconButton = tester.widget<IconButton>(find.byType(IconButton));
        expect(iconButton.onPressed, isNull);
      });
    });
  });
}
