import 'package:audiflow_app/features/podcast_detail/presentation/widgets/inline_group_card.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart'
    show
        AudioPlayerController,
        Episode,
        EpisodeWithProgress,
        PlaybackHistory,
        PlaybackProgress,
        PlaybackState,
        SmartPlaylistEpisodeData,
        SmartPlaylistGroup,
        audioPlayerControllerProvider,
        playbackProgressProvider;
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Player extends AudioPlayerController {
  _Player(this._initial);
  final PlaybackState _initial;

  @override
  PlaybackState build() => _initial;

  void emit(PlaybackState next) => state = next;
}

class _LiveProgress extends Notifier<PlaybackProgress?> {
  @override
  PlaybackProgress? build() => null;

  void emit(PlaybackProgress? next) => state = next;
}

final _liveProgress = NotifierProvider<_LiveProgress, PlaybackProgress?>(
  _LiveProgress.new,
);

SmartPlaylistEpisodeData _data(int id, {int? position, bool done = false}) {
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

    Color lineFill(WidgetTester tester) =>
        tester.widget<ColoredBox>(find.byKey(ProgressLine.fillKey)).color;

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
      check(lineFill(tester)).equals(AppColors.light.accent);
    });

    testWidgets('finished series: played and a full line', (tester) async {
      await pump(
        tester,
        const SeriesPlayback(played: 4, total: 4, fraction: 1),
      );
      check(find.text('Played').evaluate()).length.equals(1);
      check(lineFraction(tester)).equals(1);
      check(lineFill(tester)).equals(AppColors.light.inkTertiary);
    });
  });

  group('InlineGroupCard live line', () {
    const url2 = 'https://example.com/2.mp3';
    final series = SmartPlaylistGroup(
      id: 'playing',
      displayName: 'Playing series',
      episodeIds: const [1, 2, 3, 4],
    );
    final otherSeries = SmartPlaylistGroup(
      id: 'other',
      displayName: 'Other series',
      episodeIds: const [5, 6],
    );
    final map = {
      1: _data(1, done: true),
      2: _data(2, position: 50),
      3: _data(3),
      4: _data(4),
      5: _data(5, position: 50),
      6: _data(6),
    };
    final saved = SeriesPlayback.of(series.episodeIds, map);
    final otherSaved = SeriesPlayback.of(otherSeries.episodeIds, map);

    Widget rows(ProviderContainer container, SeriesPlayback playback) =>
        UncontrolledProviderScope(
          container: container,
          child: buildTestWidget(
            Column(
              children: [
                InlineGroupCard(
                  group: series,
                  playback: playback,
                  onTap: () {},
                ),
                InlineGroupCard(
                  group: otherSeries,
                  playback: otherSaved,
                  onTap: () {},
                ),
              ],
            ),
          ),
        );

    PlaybackProgress at(int percent) => PlaybackProgress(
      position: Duration(seconds: percent),
      duration: const Duration(seconds: 100),
      bufferedPosition: Duration.zero,
    );

    Future<ProviderContainer> pumpRows(
      WidgetTester tester, {
      required PlaybackState state,
      SeriesPlayback? playback,
    }) async {
      final container = ProviderContainer(
        overrides: [
          audioPlayerControllerProvider.overrideWith(() => _Player(state)),
          playbackProgressProvider.overrideWith(
            (ref) => ref.watch(_liveProgress),
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(rows(container, playback ?? saved));
      return container;
    }

    Future<AppLocalizations> getL10nFor(WidgetTester tester) async =>
        AppLocalizations.of(tester.element(find.text('Playing series')));

    double? lineOf(WidgetTester tester, String name) => tester
        .widget<BottomEdgeProgress>(
          find.ancestor(
            of: find.text(name),
            matching: find.byType(BottomEdgeProgress),
          ),
        )
        .fraction;

    void tick(ProviderContainer container, int percent) =>
        container.read(_liveProgress.notifier).emit(at(percent));

    _Player player(ProviderContainer container) =>
        container.read(audioPlayerControllerProvider.notifier) as _Player;

    testWidgets('advances with the position of its playing episode', (
      tester,
    ) async {
      final container = await pumpRows(
        tester,
        state: const PlaybackState.playing(episodeUrl: url2),
      );
      tick(container, 80);
      await tester.pump();

      check(
        lineOf(tester, 'Playing series'),
      ).equals(saved.fractionWith(url2, 0.8));
      check(lineOf(tester, 'Playing series')!).isGreaterThan(saved.fraction);
    });

    testWidgets('a row of another series is not rebuilt by a tick', (
      tester,
    ) async {
      final container = await pumpRows(
        tester,
        state: const PlaybackState.playing(episodeUrl: url2),
      );
      Widget otherLine() => tester.widget(
        find.ancestor(
          of: find.text('Other series'),
          matching: find.byType(BottomEdgeProgress),
        ),
      );
      final before = otherLine();

      tick(container, 80);
      await tester.pump();

      check(identical(otherLine(), before)).isTrue();
      check(lineOf(tester, 'Other series')).equals(otherSaved.fraction);
    });

    testWidgets('holds its place through a buffer and a pause', (tester) async {
      final container = await pumpRows(
        tester,
        state: const PlaybackState.playing(episodeUrl: url2),
      );
      tick(container, 80);
      await tester.pump();
      final held = lineOf(tester, 'Playing series');

      player(container).emit(const PlaybackState.loading(episodeUrl: url2));
      container.read(_liveProgress.notifier).emit(null);
      await tester.pump();
      check(lineOf(tester, 'Playing series')).equals(held);

      player(container).emit(const PlaybackState.paused(episodeUrl: url2));
      await tester.pump();
      check(lineOf(tester, 'Playing series')).equals(held);
    });

    testWidgets('does not jump back when saved history refreshes', (
      tester,
    ) async {
      final container = await pumpRows(
        tester,
        state: const PlaybackState.playing(episodeUrl: url2),
      );
      tick(container, 80);
      await tester.pump();
      final held = lineOf(tester, 'Playing series');

      final refreshed = SeriesPlayback.of(series.episodeIds, {
        ...map,
        2: _data(2, position: 70),
      });
      await tester.pumpWidget(rows(container, refreshed));

      check(lineOf(tester, 'Playing series')).equals(held);
    });

    testWidgets('ignores a first reading of zero after loading', (
      tester,
    ) async {
      final container = await pumpRows(
        tester,
        state: const PlaybackState.playing(episodeUrl: url2),
      );
      tick(container, 0);
      await tester.pump();

      check(lineOf(tester, 'Playing series')).equals(saved.fraction);
    });

    testWidgets('starting and stopping does not remount the row', (
      tester,
    ) async {
      final container = await pumpRows(
        tester,
        state: const PlaybackState.paused(
          episodeUrl: 'https://example.com/unrelated.mp3',
        ),
      );
      final title = tester.element(find.text('Playing series'));

      player(container).emit(const PlaybackState.playing(episodeUrl: url2));
      await tester.pump();
      check(
        identical(tester.element(find.text('Playing series')), title),
      ).isTrue();

      player(container).emit(const PlaybackState.idle());
      await tester.pump();
      check(
        identical(tester.element(find.text('Playing series')), title),
      ).isTrue();
    });

    testWidgets('an unplayed series reads as started once it is playing', (
      tester,
    ) async {
      final unplayed = SeriesPlayback.of(const [3, 4], map);
      await pumpRows(
        tester,
        state: const PlaybackState.playing(
          episodeUrl: 'https://example.com/3.mp3',
        ),
        playback: unplayed,
      );
      final l10n = await getL10nFor(tester);

      check(find.text(l10n.seriesStatusUnplayed).evaluate().length).equals(0);
    });

    testWidgets('replaying a finished episode leaves the line alone', (
      tester,
    ) async {
      final container = await pumpRows(
        tester,
        state: const PlaybackState.playing(
          episodeUrl: 'https://example.com/1.mp3',
        ),
      );
      tick(container, 10);
      await tester.pump();

      check(lineOf(tester, 'Playing series')).equals(saved.fraction);
    });
  });

  group('SeriesPlayback.of', () {
    SmartPlaylistEpisodeData data(int id, {int? position, bool done = false}) =>
        _data(id, position: position, done: done);

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
