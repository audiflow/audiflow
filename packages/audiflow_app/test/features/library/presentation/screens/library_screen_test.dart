import 'dart:async';

import 'package:audiflow_app/features/library/presentation/controllers/library_controller.dart';
import 'package:audiflow_app/features/library/presentation/screens/library_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

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
      final container = ProviderContainer(
        overrides: [
          librarySubscriptionsProvider.overrideWith(
            (ref) => Stream.error(Exception('Test error')),
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
}
