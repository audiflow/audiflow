import 'package:audiflow_app/features/search/presentation/controllers/search_controller.dart';
import 'package:audiflow_app/features/search/presentation/controllers/search_state.dart';
import 'package:audiflow_app/features/search/presentation/screens/search_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
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
  });
}
