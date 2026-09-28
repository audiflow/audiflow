import 'dart:async';

import 'package:audiflow_app/features/podcast_detail/presentation/controllers/podcast_detail_controller.dart';
import 'package:audiflow_app/features/podcast_detail/presentation/widgets/smart_playlist_episode_list_tile.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

void main() {
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
}
