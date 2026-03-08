import 'package:audiflow_app/features/podcast_detail/presentation/widgets/inline_group_card.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart' show SmartPlaylistGroup;
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

  Future<AppLocalizations> getL10n(WidgetTester tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    return l10n;
  }

  group('InlineGroupCard', () {
    testWidgets('shows group display name', (tester) async {
      final group = SmartPlaylistGroup(
        id: 'group-1',
        displayName: 'Season 1',
        episodeIds: const [1, 2, 3],
      );

      await tester.pumpWidget(
        buildTestWidget(InlineGroupCard(group: group, onTap: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.text('Season 1'), findsOneWidget);
    });

    testWidgets('shows episode count', (tester) async {
      final group = SmartPlaylistGroup(
        id: 'group-1',
        displayName: 'Season 1',
        episodeIds: const [1, 2, 3],
      );

      await tester.pumpWidget(
        buildTestWidget(InlineGroupCard(group: group, onTap: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.text('3 episodes'), findsOneWidget);
    });

    testWidgets('shows chevron right icon', (tester) async {
      final group = SmartPlaylistGroup(
        id: 'group-1',
        displayName: 'Season 1',
        episodeIds: const [1, 2],
      );

      await tester.pumpWidget(
        buildTestWidget(InlineGroupCard(group: group, onTap: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('tapping the card calls onTap callback', (tester) async {
      var tapped = false;
      final group = SmartPlaylistGroup(
        id: 'group-1',
        displayName: 'Season 1',
        episodeIds: const [1],
      );

      await tester.pumpWidget(
        buildTestWidget(
          InlineGroupCard(group: group, onTap: () => tapped = true),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('shows placeholder when no thumbnail URL', (tester) async {
      final group = SmartPlaylistGroup(
        id: 'group-1',
        displayName: 'Season 1',
        episodeIds: const [1],
      );

      await tester.pumpWidget(
        buildTestWidget(InlineGroupCard(group: group, onTap: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
    });
  });

  group('formatDateRange', () {
    test('returns null when earliest is null', () {
      expect(formatDateRange(null, DateTime(2024)), isNull);
    });

    test('returns null when latest is null', () {
      expect(formatDateRange(DateTime(2024), null), isNull);
    });

    test('returns null when both are null', () {
      expect(formatDateRange(null, null), isNull);
    });

    test('returns single date when earliest equals latest', () {
      final date = DateTime(2024, 3, 15);
      final result = formatDateRange(date, date);
      expect(result, isNotNull);
      // Should be a single formatted date, not a range.
      expect(result!.contains('\u301c'), isFalse);
    });

    test('returns range when earliest and latest differ', () {
      final earliest = DateTime(2024, 1, 1);
      final latest = DateTime(2024, 6, 15);
      final result = formatDateRange(earliest, latest);
      expect(result, isNotNull);
      // Should contain the wave dash separator.
      expect(result!.contains('\u301c'), isTrue);
    });
  });

  group('formatGroupDuration', () {
    testWidgets('returns null when totalMs is null', (tester) async {
      final l10n = await getL10n(tester);
      expect(formatGroupDuration(null, l10n), isNull);
    });

    testWidgets('returns null when totalMs is 0', (tester) async {
      final l10n = await getL10n(tester);
      expect(formatGroupDuration(0, l10n), isNull);
    });

    testWidgets('returns minutes only for durations under 1 hour', (
      tester,
    ) async {
      final l10n = await getL10n(tester);
      // 45 minutes = 2700000 ms
      final result = formatGroupDuration(2700000, l10n);
      expect(result, '45m');
    });

    testWidgets('returns hours and minutes for durations 1h+', (tester) async {
      final l10n = await getL10n(tester);
      // 1 hour 30 minutes = 5400000 ms
      final result = formatGroupDuration(5400000, l10n);
      expect(result, '1h30m');
    });
  });
}
