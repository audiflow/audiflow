import 'package:audiflow_app/features/podcast_detail/presentation/controllers/podcast_detail_controller.dart';
import 'package:audiflow_app/features/podcast_detail/presentation/screens/episode_detail_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_app/l10n/app_localizations_en.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

  Widget buildTestWidget({
    PodcastItem? episode,
    EpisodeWithProgress? progress,
    String? itunesId,
  }) {
    return ProviderScope(
      overrides: [
        audioPlayerControllerProvider.overrideWith(
          () => _FakeAudioPlayerController(),
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
        ),
      ),
    );
  }

  group('EpisodeDetailScreen', () {
    testWidgets('renders episode title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Title appears in header and stats table
      expect(find.text('Test Episode Title'), findsNWidgets(2));
    });

    testWidgets('renders podcast title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Podcast name appears in header and stats table
      expect(find.text(testPodcastTitle), findsNWidgets(2));
    });

    testWidgets('renders play button when not playing', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    testWidgets('renders more actions button in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('does not render share button in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Share should only be in context menu, not app bar
      expect(
        find.descendant(
          of: find.byType(SliverAppBar),
          matching: find.byIcon(Icons.share),
        ),
        findsNothing,
      );
    });

    testWidgets('episode title is selectable', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final selectableTexts = tester.widgetList<SelectableText>(
        find.byType(SelectableText),
      );
      final titleWidget = selectableTexts.where(
        (w) => w.data == 'Test Episode Title',
      );
      check(titleWidget.length).equals(1);
    });
  });

  group('EpisodeDetailScreen progress indicator', () {
    testWidgets('shows Played indicator when completed', (tester) async {
      await tester.pumpWidget(buildTestWidget(progress: testCompletedProgress));
      await tester.pumpAndSettle();

      expect(find.byType(EpisodeProgressIndicator), findsOneWidget);
      expect(find.text('Played'), findsOneWidget);
    });

    testWidgets('shows remaining time when in progress', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(progress: testInProgressProgress),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EpisodeProgressIndicator), findsOneWidget);
      expect(find.text('20 min left'), findsOneWidget);
    });

    testWidgets('hides progress indicator when unplayed', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(progress: testEpisodeWithProgress),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EpisodeProgressIndicator), findsNothing);
    });
  });

  group('EpisodeDetailScreen context menu', () {
    testWidgets('opens bottom sheet on more button tap', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(progress: testEpisodeWithProgress, itunesId: '12345'),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    });

    testWidgets('context menu shows episode title', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(progress: testEpisodeWithProgress, itunesId: '12345'),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Title appears in the screen header, stats table, and bottom sheet
      expect(find.text('Test Episode Title'), findsNWidgets(3));
    });

    testWidgets('context menu shows Play next option', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(progress: testEpisodeWithProgress, itunesId: '12345'),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text(l10n.playNext), findsOneWidget);
    });

    testWidgets('context menu shows Add to queue option', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(progress: testEpisodeWithProgress, itunesId: '12345'),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text(l10n.addToQueue), findsOneWidget);
    });

    testWidgets('context menu shows Mark as played for unplayed episode', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(progress: testEpisodeWithProgress, itunesId: '12345'),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text(l10n.markAsPlayed), findsOneWidget);
    });

    testWidgets('context menu shows Mark as unplayed for completed episode', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(progress: testCompletedProgress, itunesId: '12345'),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text(l10n.markAsUnplayed), findsOneWidget);
    });

    testWidgets('context menu shows Share option when shareable', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildTestWidget(progress: testEpisodeWithProgress, itunesId: '12345'),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text(l10n.shareEpisode), findsOneWidget);
    });

    testWidgets('context menu shows Download option', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildTestWidget(progress: testEpisodeWithProgress, itunesId: '12345'),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text(l10n.downloadEpisode), findsOneWidget);
    });
  });

  group('EpisodeDetailScreen action bar', () {
    testWidgets('shows download icon when episode has id', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(progress: testEpisodeWithProgress),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DownloadStatusIcon), findsOneWidget);
    });

    testWidgets('shows queue button when episode has id', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(progress: testEpisodeWithProgress),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.playlist_add), findsOneWidget);
    });

    testWidgets('does not show played status chip', (tester) async {
      await tester.pumpWidget(buildTestWidget(progress: testCompletedProgress));
      await tester.pumpAndSettle();

      // ActionChip should not exist in the action bar
      expect(find.byType(ActionChip), findsNothing);
    });
  });
}

/// Minimal fake for AudioPlayerController that returns idle state.
class _FakeAudioPlayerController extends AudioPlayerController {
  @override
  PlaybackState build() => const PlaybackState.idle();

  @override
  Future<void> play(String url, {NowPlayingInfo? metadata}) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<void> stop() async {}

  @override
  bool isLoaded(String url) => false;
}
