import 'package:audiflow_app/features/podcast_detail/presentation/controllers/podcast_detail_controller.dart';
import 'package:audiflow_app/features/podcast_detail/presentation/screens/episode_detail_screen.dart';
import 'package:audiflow_app/features/podcast_detail/presentation/widgets/episode_description_card.dart';
import 'package:audiflow_app/features/podcast_detail/presentation/widgets/episode_detail_actions.dart';
import 'package:audiflow_app/features/podcast_detail/presentation/widgets/episode_playback_record.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_app/l10n/app_localizations_en.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Use l10n keys instead of hardcoded English strings so tests survive
  // copy changes without silent breakage.
  final l10n = AppLocalizationsEn();
  const testAudioUrl = 'https://example.com/episode.mp3';
  const testPodcastTitle = 'Test Podcast';

  final testEpisode = PodcastItem(
    parsedAt: DateTime(2026),
    sourceUrl: 'https://example.com/feed.xml',
    title: 'Test Episode Title',
    description: 'Test description',
    enclosureUrl: testAudioUrl,
    guid: 'test-guid-123',
    link: 'https://example.com/episode',
    duration: const Duration(minutes: 30),
    publishDate: DateTime(2026, 3, 15),
  );

  final testEpisodeWithProgress = EpisodeWithProgress(
    episode: Episode()
      ..id = 1
      ..podcastId = 100
      ..guid = 'test-guid-123'
      ..title = 'Test Episode Title'
      ..audioUrl = testAudioUrl
      ..durationMs = 1800000,
  );

  final testCompletedProgress = EpisodeWithProgress(
    episode: Episode()
      ..id = 1
      ..podcastId = 100
      ..guid = 'test-guid-123'
      ..title = 'Test Episode Title'
      ..audioUrl = testAudioUrl
      ..durationMs = 1800000,
    history: PlaybackHistory()
      ..id = 1
      ..episodeId = 1
      ..positionMs = 1800000
      ..durationMs = 1800000
      ..completedAt = DateTime(2026, 3, 20),
  );

  final testInProgressProgress = EpisodeWithProgress(
    episode: Episode()
      ..id = 1
      ..podcastId = 100
      ..guid = 'test-guid-123'
      ..title = 'Test Episode Title'
      ..audioUrl = testAudioUrl
      ..durationMs = 1800000,
    history: PlaybackHistory()
      ..id = 1
      ..episodeId = 1
      ..positionMs = 600000
      ..durationMs = 1800000,
  );

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget buildTestWidget({
    PodcastItem? episode,
    EpisodeWithProgress? progress,
    String? itunesId,
    int? stationId,
    StationRepository? stations,
    bool loaded = false,
    QueueService? queue,
  }) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        if (queue != null) queueServiceProvider.overrideWithValue(queue),
        if (stations != null)
          stationRepositoryProvider.overrideWithValue(stations),
        audioPlayerControllerProvider.overrideWith(
          () => loaded
              ? _LoadedAudioPlayerController()
              : _FakeAudioPlayerController(),
        ),
        episodeProgressProvider.overrideWith((ref, url) async => progress),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: EpisodeDetailScreen(
          episode: episode ?? testEpisode,
          podcastTitle: testPodcastTitle,
          progress: progress,
          itunesId: itunesId,
          stationId: stationId,
        ),
      ),
    );
  }

  group('EpisodeDetailScreen', () {
    testWidgets('cancelling the queue replacement records no station play', (
      tester,
    ) async {
      final stations = _RecordingStationRepository();
      await tester.pumpWidget(
        buildTestWidget(
          progress: testEpisodeWithProgress,
          stationId: 3,
          stations: stations,
          queue: _ConfirmingQueueService(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      check(stations.played).isEmpty();
    });

    testWidgets('playing an episode opened from a station records it', (
      tester,
    ) async {
      final stations = _RecordingStationRepository();
      await tester.pumpWidget(
        // Already loaded: a tap resumes, without the fresh-play timers.
        buildTestWidget(stationId: 3, stations: stations, loaded: true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pumpAndSettle();

      check(stations.played).deepEquals([3]);
    });

    testWidgets('renders the full title once, selectable', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final titles = tester
          .widgetList<SelectableText>(find.byType(SelectableText))
          .where((w) => w.data == 'Test Episode Title');
      check(titles.length).equals(1);
    });

    testWidgets('renders the podcast name and metadata line', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      check(find.text(testPodcastTitle).evaluate()).length.equals(1);
      check(find.text('Mar 15, 2026 · 30m').evaluate()).length.equals(1);
    });

    testWidgets('floating navigation carries share and more', (tester) async {
      await tester.pumpWidget(buildTestWidget(itunesId: '12345'));
      await tester.pumpAndSettle();

      check(find.byTooltip(l10n.shareEpisode).evaluate()).length.equals(1);
      check(
        find.byTooltip(l10n.episodeMoreActions).evaluate(),
      ).length.equals(1);
    });

    testWidgets('hides share when nothing can be shared', (tester) async {
      final unshareable = PodcastItem(
        parsedAt: DateTime(2026),
        sourceUrl: 'https://example.com/feed.xml',
        title: 'Test Episode Title',
        description: 'Test description',
        enclosureUrl: testAudioUrl,
      );
      await tester.pumpWidget(buildTestWidget(episode: unshareable));
      await tester.pumpAndSettle();

      check(find.byTooltip(l10n.shareEpisode).evaluate()).isEmpty();
    });
  });

  group('EpisodeDetailScreen primary pill', () {
    testWidgets('unplayed reads play with the duration', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(progress: testEpisodeWithProgress),
      );
      await tester.pumpAndSettle();

      check(find.text('Play · 30m').evaluate()).length.equals(1);
    });

    testWidgets('in progress reads resume', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(progress: testInProgressProgress),
      );
      await tester.pumpAndSettle();

      check(find.text(l10n.episodeDetailResume).evaluate()).length.equals(1);
    });

    testWidgets('played reads play again', (tester) async {
      await tester.pumpWidget(buildTestWidget(progress: testCompletedProgress));
      await tester.pumpAndSettle();

      check(find.text(l10n.episodeDetailPlayAgain).evaluate()).length.equals(1);
    });
  });

  group('EpisodeDetailScreen progress line', () {
    testWidgets('shows the played mark when completed', (tester) async {
      await tester.pumpWidget(buildTestWidget(progress: testCompletedProgress));
      await tester.pumpAndSettle();

      check(find.byType(EpisodeProgressStatus).evaluate()).length.equals(1);
      check(find.text(l10n.episodePillCompleted).evaluate()).length.equals(1);
    });

    testWidgets('shows the remaining time when in progress', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(progress: testInProgressProgress),
      );
      await tester.pumpAndSettle();

      check(find.byType(EpisodeProgressStatus).evaluate()).length.equals(1);
      check(find.text('20m left').evaluate()).length.equals(1);
    });

    testWidgets('is hidden while unplayed', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(progress: testEpisodeWithProgress),
      );
      await tester.pumpAndSettle();

      check(find.byType(EpisodeProgressStatus).evaluate()).isEmpty();
    });
  });

  group('EpisodeDetailScreen action row', () {
    testWidgets('shows queue and download buttons for a saved episode', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(progress: testEpisodeWithProgress),
      );
      await tester.pumpAndSettle();

      check(find.byTooltip(l10n.addToQueue).evaluate()).length.equals(1);
      check(find.byTooltip(l10n.downloadEpisode).evaluate()).length.equals(1);
      check(find.byTooltip(l10n.playNext).evaluate()).isEmpty();
    });

    testWidgets('the queue button offers play next or add to end', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(progress: testEpisodeWithProgress),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip(l10n.addToQueue));
      await tester.pumpAndSettle();

      check(find.text(l10n.playNext).evaluate()).length.equals(1);
      check(find.text(l10n.episodeDetailAddToEnd).evaluate()).length.equals(1);
    });

    testWidgets('leaves only the play pill for an unsaved episode', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      check(find.byType(EpisodeActionCircle).evaluate()).isEmpty();
      check(find.byType(EpisodePrimaryPill).evaluate()).length.equals(1);
    });
  });

  group('EpisodeDetailScreen more menu', () {
    Future<void> openMenu(
      WidgetTester tester,
      EpisodeWithProgress progress,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(progress: progress, itunesId: '12345'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(l10n.episodeMoreActions));
      await tester.pumpAndSettle();
    }

    testWidgets('offers mark as played and open podcast', (tester) async {
      await openMenu(tester, testEpisodeWithProgress);

      check(find.byType(ActionMenu).evaluate()).length.equals(1);
      check(find.text(l10n.markAsPlayed).evaluate()).length.equals(1);
      check(
        find.text(l10n.episodeDetailOpenPodcast).evaluate(),
      ).length.equals(1);
    });

    testWidgets('offers mark as unplayed for a played episode', (tester) async {
      await openMenu(tester, testCompletedProgress);

      check(find.text(l10n.markAsUnplayed).evaluate()).length.equals(1);
    });

    testWidgets('does not repeat the on-screen actions', (tester) async {
      await openMenu(tester, testEpisodeWithProgress);

      final menu = find.byType(ActionMenu);
      for (final label in [
        l10n.playNext,
        l10n.addToQueue,
        l10n.downloadEpisode,
        l10n.shareEpisode,
        l10n.removeDownload,
      ]) {
        check(
          find.descendant(of: menu, matching: find.text(label)).evaluate(),
        ).isEmpty();
      }
    });
  });

  group('EpisodeDetailScreen sections', () {
    testWidgets('shows the show notes card', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      check(find.byType(EpisodeDescriptionCard).evaluate()).length.equals(1);
      check(find.text(l10n.episodeDetailAbout).evaluate()).length.equals(1);
    });

    testWidgets('playback record shows placeholders before a play', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(progress: testEpisodeWithProgress),
      );
      await tester.pumpAndSettle();

      check(
        find.text(l10n.episodeDetailPlaybackRecord).evaluate(),
      ).length.equals(1);
      check(
        find.text(EpisodePlaybackRecord.noValue).evaluate(),
      ).length.equals(4);
      check(find.text(l10n.statsNever).evaluate()).length.equals(2);
    });

    testWidgets('playback record shows the history values', (tester) async {
      await tester.pumpWidget(buildTestWidget(progress: testCompletedProgress));
      await tester.pumpAndSettle();

      check(find.text(EpisodePlaybackRecord.noValue).evaluate()).isEmpty();
      // completedCount and playCount both default to 0.
      check(find.text('0 times').evaluate()).length.equals(2);
    });
  });
}

/// Minimal fake for AudioPlayerController that returns idle state.
class _FakeAudioPlayerController extends AudioPlayerController {
  @override
  PlaybackState build() => const PlaybackState.idle();

  @override
  Future<void> play(
    String url, {
    NowPlayingInfo? metadata,
    Duration? startAt,
  }) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<void> stop() async {}

  @override
  bool isLoaded(String url) => false;
}

class _RecordingStationRepository extends Fake implements StationRepository {
  final played = <int>[];

  @override
  Future<void> markPlayed(int id, {required DateTime at}) async =>
      played.add(id);
}

class _LoadedAudioPlayerController extends _FakeAudioPlayerController {
  @override
  bool isLoaded(String url) => true;
}

/// Asks to confirm replacing the queue, so the test can cancel.
class _ConfirmingQueueService extends Fake implements QueueService {
  @override
  Future<bool> shouldConfirmAdhocReplace() async => true;
}
