import 'package:audiflow_app/features/library/presentation/controllers/library_controller.dart';
import 'package:audiflow_app/features/library/presentation/screens/subscriptions_list_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
  group('SubscriptionsListScreen sort menu', () {
    late ProviderContainer container;

    Widget buildTestWidget() {
      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SubscriptionsListScreen(),
        ),
      );
    }

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          sortedSubscriptionsProvider.overrideWith(
            (ref) async => [_sub(1, 'Alpha'), _sub(2, 'Beta')],
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    testWidgets('displays sort icon button in AppBar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.sort), findsOneWidget);
    });

    testWidgets('opens popup menu with three sort options', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      expect(find.text('Latest episode'), findsOneWidget);
      expect(find.text('Subscription date'), findsOneWidget);
      expect(find.text('Alphabetical'), findsOneWidget);
    });

    testWidgets('shows check icon on current sort order', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      // Default is latestEpisode, so check icon appears on that item
      final latestItem = find.ancestor(
        of: find.text('Latest episode'),
        matching: find.byType(PopupMenuItem<PodcastSortOrder>),
      );
      expect(latestItem, findsOneWidget);
      // The check icon should be present in the menu
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
