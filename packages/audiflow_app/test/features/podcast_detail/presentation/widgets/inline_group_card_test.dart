import 'package:audiflow_app/features/podcast_detail/presentation/widgets/inline_group_card.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart'
    show
        Episode,
        EpisodeWithProgress,
        PlaybackHistory,
        SmartPlaylistEpisodeData,
        SmartPlaylistGroup;
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
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

    testWidgets('hides thumbnail when thumbnailUrl is null', (tester) async {
      final group = SmartPlaylistGroup(
        id: 'group-1',
        displayName: 'Season 1',
        episodeIds: const [1],
      );

      await tester.pumpWidget(
        buildTestWidget(InlineGroupCard(group: group, onTap: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.folder_outlined), findsNothing);
    });
  });

  group('InlineGroupCard series row', () {
    final group = SmartPlaylistGroup(
      id: 'group-1',
      displayName: 'Season 1',
      episodeIds: const [1, 2, 3, 4],
      totalDurationMs: 90 * 60000,
    );

    Future<void> pump(WidgetTester tester, SeriesPlayback? playback) async {
      await tester.pumpWidget(
        buildTestWidget(
          InlineGroupCard(group: group, playback: playback, onTap: () {}),
        ),
      );
      await tester.pumpAndSettle();
    }

    double? lineFraction(WidgetTester tester) => tester
        .widget<BottomEdgeProgress>(find.byType(BottomEdgeProgress))
        .fraction;

    testWidgets('meta line joins the count and total duration', (tester) async {
      await pump(tester, null);
      check(find.text('4 episodes · 1h30m').evaluate()).length.equals(1);
    });

    testWidgets('unplayed series: status text, no line', (tester) async {
      await pump(
        tester,
        const SeriesPlayback(played: 0, total: 4, fraction: 0),
      );
      final status = tester.widget<Text>(find.text('Unplayed'));
      check(status.style?.color).equals(AppColors.light.inkTertiary);
      check(lineFraction(tester)).isNull();
    });

    testWidgets('started series: count in accent and a partial line', (
      tester,
    ) async {
      await pump(
        tester,
        const SeriesPlayback(played: 2, total: 4, fraction: 0.6),
      );
      final status = tester.widget<Text>(find.text('2/4 played'));
      check(status.style?.color).equals(AppColors.light.accent);
      check(lineFraction(tester)).equals(0.6);
    });

    testWidgets('finished series: played and a full line', (tester) async {
      await pump(
        tester,
        const SeriesPlayback(played: 4, total: 4, fraction: 1),
      );
      check(find.text('Played').evaluate()).length.equals(1);
      check(lineFraction(tester)).equals(1);
    });
  });

  group('SeriesPlayback.of', () {
    SmartPlaylistEpisodeData data(int id, {int? position, bool done = false}) {
      final episode = Episode()
        ..id = id
        ..podcastId = 1
        ..guid = 'g$id'
        ..title = 'Episode $id'
        ..audioUrl = 'https://example.com/$id.mp3';
      final history = position == null && !done
          ? null
          : (PlaybackHistory()
              ..episodeId = id
              ..positionMs = position ?? 0
              ..durationMs = 100
              ..completedAt = done ? DateTime(2026) : null);
      return SmartPlaylistEpisodeData(
        episode: episode,
        progress: EpisodeWithProgress(episode: episode, history: history),
      );
    }

    test('counts played episodes and averages progress', () {
      final map = {
        1: data(1, done: true),
        2: data(2, position: 50),
        3: data(3),
        4: data(4),
      };
      final playback = SeriesPlayback.of([1, 2, 3, 4], map);
      check(playback.played).equals(1);
      check(playback.total).equals(4);
      check(playback.fraction).equals((1 + 0.5) / 4);
    });

    test('nothing started gives zero', () {
      final playback = SeriesPlayback.of([3, 4], {3: data(3), 4: data(4)});
      check(playback.played).equals(0);
      check(playback.fraction).equals(0);
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
