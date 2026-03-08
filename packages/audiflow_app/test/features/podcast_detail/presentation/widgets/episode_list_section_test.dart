import 'package:audiflow_app/features/podcast_detail/presentation/widgets/episode_list_section.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart' show SortOrder;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  group('SortHeader', () {
    testWidgets('shows the label text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          SortHeader(
            label: '10 episodes',
            sortOrder: SortOrder.descending,
            onToggleSortOrder: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('10 episodes'), findsOneWidget);
    });

    testWidgets('shows arrow_downward for descending order', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          SortHeader(
            label: '5 episodes',
            sortOrder: SortOrder.descending,
            onToggleSortOrder: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('shows arrow_upward for ascending order', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          SortHeader(
            label: '5 episodes',
            sortOrder: SortOrder.ascending,
            onToggleSortOrder: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('shows Newest first for descending order', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          SortHeader(
            label: '5 episodes',
            sortOrder: SortOrder.descending,
            onToggleSortOrder: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Newest first'), findsOneWidget);
    });

    testWidgets('shows Oldest first for ascending order', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          SortHeader(
            label: '5 episodes',
            sortOrder: SortOrder.ascending,
            onToggleSortOrder: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Oldest first'), findsOneWidget);
    });

    testWidgets('tapping sort toggle calls onToggleSortOrder', (tester) async {
      var toggleCalled = false;
      await tester.pumpWidget(
        buildTestWidget(
          SortHeader(
            label: '5 episodes',
            sortOrder: SortOrder.descending,
            onToggleSortOrder: () => toggleCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Newest first'));
      expect(toggleCalled, isTrue);
    });
  });
}
