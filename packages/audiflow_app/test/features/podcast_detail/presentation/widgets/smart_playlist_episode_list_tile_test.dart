import 'dart:async';

import 'package:audiflow_app/features/podcast_detail/presentation/controllers/podcast_detail_controller.dart';
import 'package:audiflow_app/features/podcast_detail/presentation/widgets/smart_playlist_episode_list_tile.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

const _audioUrl = 'https://example.com/episode.mp3';

class _FakeEpisodeRepository extends Fake implements EpisodeRepository {
  _FakeEpisodeRepository(this.episode);

  final Episode episode;

  @override
  Future<Episode?> getByAudioUrl(String audioUrl) async => episode;
}

/// Holds [markCompleted] open so the test can unmount the tile mid-save.
class _GatedHistoryService extends Fake implements PlaybackHistoryService {
  final gate = Completer<void>();
  final completed = <int>[];

  @override
  Future<void> markCompleted(int episodeId) async {
    await gate.future;
    completed.add(episodeId);
  }
}

class _KeepRecordingDownloadService extends Fake implements DownloadService {
  final keptIds = <int>[];

  @override
  Future<bool> keep(int taskId) async {
    keptIds.add(taskId);
    return true;
  }
}

void main() {
  group('row menu keep download', () {
    final episode = Episode()
      ..id = 7
      ..podcastId = 1
      ..guid = 'guid-7'
      ..title = 'Episode 7'
      ..audioUrl = _audioUrl;

    Future<_KeepRecordingDownloadService> openMenu(
      WidgetTester tester,
      DownloadOrigin origin,
    ) async {
      final downloads = _KeepRecordingDownloadService();
      final task = DownloadTask()
        ..id = 3
        ..episodeId = 7
        ..audioUrl = _audioUrl
        ..status = const DownloadStatus.completed().toDbValue()
        ..origin = origin.dbValue
        ..createdAt = DateTime(2026);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            downloadServiceProvider.overrideWithValue(downloads),
            currentPlayingEpisodeUrlProvider.overrideWithValue(null),
            isEpisodePlayingProvider.overrideWith((ref, _) => false),
            isEpisodeLoadingProvider.overrideWith((ref, _) => false),
            episodeDownloadProvider.overrideWith(
              (ref, _) => Stream.value(task),
            ),
            episodeHasTranscriptProvider.overrideWith((ref, _) async => false),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SmartPlaylistEpisodeListTile(
                episode: episode,
                podcastTitle: 'Podcast',
                showThumbnail: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.longPress(find.text('Episode 7'));
      await tester.pumpAndSettle();
      return downloads;
    }

    testWidgets('keeps an auto download and says so', (tester) async {
      final downloads = await openMenu(tester, DownloadOrigin.auto);

      await tester.tap(find.text('Keep download'));
      await tester.pumpAndSettle();

      check(downloads.keptIds).deepEquals([3]);
      check(
        find
            .text("Download kept. It won't be removed automatically.")
            .evaluate(),
      ).length.equals(1);
    });

    testWidgets('is not offered for a manual download', (tester) async {
      await openMenu(tester, DownloadOrigin.manual);

      check(find.text('Keep download').evaluate()).isEmpty();
      check(find.text('Remove download').evaluate()).length.equals(1);
    });
  });

  testWidgets('mark as played completes after the tile is unmounted mid-save', (
    tester,
  ) async {
    final episode = Episode()
      ..id = 7
      ..podcastId = 1
      ..guid = 'guid-7'
      ..title = 'Episode 7'
      ..audioUrl = _audioUrl;
    final historyService = _GatedHistoryService();
    final showTile = ValueNotifier(true);
    addTearDown(showTile.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          episodeRepositoryProvider.overrideWithValue(
            _FakeEpisodeRepository(episode),
          ),
          playbackHistoryServiceProvider.overrideWithValue(historyService),
          currentPlayingEpisodeUrlProvider.overrideWithValue(null),
          isEpisodePlayingProvider.overrideWith((ref, _) => false),
          isEpisodeLoadingProvider.overrideWith((ref, _) => false),
          episodeDownloadProvider.overrideWith((ref, _) => Stream.value(null)),
          episodeHasTranscriptProvider.overrideWith((ref, _) async => false),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ValueListenableBuilder<bool>(
              valueListenable: showTile,
              builder: (context, show, _) => show
                  ? SmartPlaylistEpisodeListTile(
                      episode: episode,
                      podcastTitle: 'Podcast',
                      showThumbnail: false,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Episode 7'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark as played'));
    await tester.pumpAndSettle();

    // Played episodes can leave the list while the save is in flight.
    showTile.value = false;
    await tester.pumpAndSettle();
    check(find.byType(SmartPlaylistEpisodeListTile).evaluate()).isEmpty();

    historyService.gate.complete();
    await tester.pumpAndSettle();

    check(historyService.completed).deepEquals([7]);
    check(tester.takeException()).isNull();
  });

  testWidgets('a replay of a played episode shows its position and stays '
      'played', (tester) async {
    final episode = Episode()
      ..id = 7
      ..podcastId = 1
      ..guid = 'guid-7'
      ..title = 'Episode 7'
      ..audioUrl = _audioUrl
      ..durationMs = const Duration(minutes: 30).inMilliseconds;
    final history = PlaybackHistory()
      ..episodeId = 7
      ..positionMs = const Duration(minutes: 5).inMilliseconds
      ..durationMs = const Duration(minutes: 30).inMilliseconds
      ..completedAt = DateTime(2026, 10, 1)
      ..isReplaying = true;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentPlayingEpisodeUrlProvider.overrideWithValue(null),
          isEpisodePlayingProvider.overrideWith((ref, _) => false),
          isEpisodeLoadingProvider.overrideWith((ref, _) => false),
          episodeDownloadProvider.overrideWith((ref, _) => Stream.value(null)),
          episodeHasTranscriptProvider.overrideWith((ref, _) async => false),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SmartPlaylistEpisodeListTile(
              episode: episode,
              podcastTitle: 'Podcast',
              showThumbnail: false,
              progress: EpisodeWithProgress(episode: episode, history: history),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    check(find.text('25m left').evaluate()).isNotEmpty();
    check(find.text('Completed').evaluate()).isEmpty();

    await tester.longPress(find.text('Episode 7'));
    await tester.pumpAndSettle();

    check(find.text('Mark as unplayed').evaluate()).isNotEmpty();
    check(find.text('Mark as played').evaluate()).isEmpty();
  });

  testWidgets('resuming from a station records the station play', (
    tester,
  ) async {
    final episode = Episode()
      ..id = 7
      ..podcastId = 1
      ..guid = 'guid-7'
      ..title = 'Episode 7'
      ..audioUrl = _audioUrl;
    final player = _LoadedAudioPlayerController();
    final stations = _RecordingStationRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioPlayerControllerProvider.overrideWith(() => player),
          stationRepositoryProvider.overrideWithValue(stations),
          currentPlayingEpisodeUrlProvider.overrideWithValue(_audioUrl),
          isEpisodePlayingProvider.overrideWith((ref, _) => false),
          isEpisodeLoadingProvider.overrideWith((ref, _) => false),
          episodeDownloadProvider.overrideWith((ref, _) => Stream.value(null)),
          episodeHasTranscriptProvider.overrideWith((ref, _) async => false),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SmartPlaylistEpisodeListTile(
              episode: episode,
              podcastTitle: 'Podcast',
              showThumbnail: false,
              stationName: 'Morning',
              stationId: 3,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(EpisodePlayPill));
    await tester.pumpAndSettle();

    check(player.resumed).isTrue();
    check(stations.played).deepEquals([3]);
  });

  group('transcript badge', () {
    final episode = Episode()
      ..id = 7
      ..podcastId = 1
      ..guid = 'guid-7'
      ..title = 'Episode 7'
      ..audioUrl = _audioUrl;

    Future<ProviderContainer> pumpTile(
      WidgetTester tester, {
      required bool declared,
    }) async {
      final container = ProviderContainer(
        overrides: [
          episodeRepositoryProvider.overrideWithValue(
            _FakeEpisodeRepository(episode),
          ),
          currentPlayingEpisodeUrlProvider.overrideWithValue(null),
          isEpisodePlayingProvider.overrideWith((ref, _) => false),
          isEpisodeLoadingProvider.overrideWith((ref, _) => false),
          episodeDownloadProvider.overrideWith((ref, _) => Stream.value(null)),
          episodeTranscriptMetasProvider.overrideWith(
            (ref, _) async => [
              if (declared)
                EpisodeTranscript()
                  ..episodeId = 7
                  ..url = 'https://example.com/7.vtt'
                  ..type = 'text/vtt',
            ],
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SmartPlaylistEpisodeListTile(
                episode: episode,
                podcastTitle: 'Podcast',
                showThumbnail: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return container;
    }

    Finder badge() => find.byIcon(Symbols.closed_caption);

    testWidgets('is hidden without a declared transcript', (tester) async {
      await pumpTile(tester, declared: false);
      check(badge().evaluate()).isEmpty();
    });

    testWidgets('shows for a declared transcript not yet fetched', (
      tester,
    ) async {
      await pumpTile(tester, declared: true);
      check(badge().evaluate().length).equals(1);
    });

    testWidgets('stays for a declared transcript that loaded', (tester) async {
      final container = await pumpTile(tester, declared: true);

      container
          .read(transcriptFetchOutcomesProvider.notifier)
          .record(7, usable: true);
      await tester.pumpAndSettle();

      check(badge().evaluate().length).equals(1);
    });

    testWidgets('drops once a fetch finds the declared transcript unusable', (
      tester,
    ) async {
      final container = await pumpTile(tester, declared: true);

      container
          .read(transcriptFetchOutcomesProvider.notifier)
          .record(7, usable: false);
      await tester.pumpAndSettle();

      check(badge().evaluate()).isEmpty();
    });
  });
}

/// Reports [_audioUrl] as already loaded, so a play tap resumes it.
class _LoadedAudioPlayerController extends AudioPlayerController {
  bool resumed = false;

  @override
  PlaybackState build() => const PlaybackState.paused(episodeUrl: _audioUrl);

  @override
  bool isLoaded(String url) => url == _audioUrl;

  @override
  Future<void> resume() async => resumed = true;
}

class _RecordingStationRepository extends Fake implements StationRepository {
  final played = <int>[];

  @override
  Future<void> markPlayed(int id, {required DateTime at}) async =>
      played.add(id);
}
