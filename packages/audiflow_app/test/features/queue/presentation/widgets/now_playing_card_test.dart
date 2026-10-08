import 'package:audiflow_app/features/queue/presentation/widgets/now_playing_card.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/player_stubs.dart';

const _url = 'https://example.com/new.mp3';

const _nowPlaying = NowPlayingInfo(
  episodeUrl: _url,
  episodeTitle: 'New Episode',
  podcastTitle: 'Show',
);

void main() {
  Future<double?> lineFraction(
    WidgetTester tester, {
    required PlaybackState player,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nowPlayingControllerProvider.overrideWith(
            () => StubNowPlayingController(_nowPlaying),
          ),
          audioPlayerControllerProvider.overrideWith(
            () => StubAudioPlayerController(player),
          ),
          playbackProgressProvider.overrideWith(
            (ref) => const PlaybackProgress(
              position: Duration(minutes: 9),
              duration: Duration(minutes: 10),
              bufferedPosition: Duration.zero,
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: NowPlayingCard()),
        ),
      ),
    );
    await tester.pump();
    return tester
        .widget<BottomEdgeProgress>(find.byType(BottomEdgeProgress))
        .fraction;
  }

  testWidgets('shows live progress of its own episode', (tester) async {
    final fraction = await lineFraction(
      tester,
      player: const PlaybackState.playing(episodeUrl: _url),
    );
    check(fraction).isNotNull().isCloseTo(0.9, 0.001);
  });

  testWidgets('ignores the previous audio while a new episode loads', (
    tester,
  ) async {
    final fraction = await lineFraction(
      tester,
      player: const PlaybackState.playing(
        episodeUrl: 'https://example.com/old.mp3',
      ),
    );
    check(fraction).isNull();
  });

  testWidgets('keeps the line while its own episode buffers', (tester) async {
    final player = _SwitchablePlayer(
      const PlaybackState.playing(episodeUrl: _url),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nowPlayingControllerProvider.overrideWith(
            () => StubNowPlayingController(_nowPlaying),
          ),
          audioPlayerControllerProvider.overrideWith(() => player),
          playbackProgressProvider.overrideWith(
            (ref) => const PlaybackProgress(
              position: Duration(minutes: 9),
              duration: Duration(minutes: 10),
              bufferedPosition: Duration.zero,
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: NowPlayingCard()),
        ),
      ),
    );
    await tester.pump();

    player.set(const PlaybackState.loading(episodeUrl: _url));
    await tester.pump();

    final fraction = tester
        .widget<BottomEdgeProgress>(find.byType(BottomEdgeProgress))
        .fraction;
    check(fraction).isNotNull().isCloseTo(0.9, 0.001);
  });
}

class _SwitchablePlayer extends StubAudioPlayerController {
  _SwitchablePlayer(super.initial);

  void set(PlaybackState next) => state = next;
}
