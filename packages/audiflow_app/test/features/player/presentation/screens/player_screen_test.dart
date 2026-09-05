import 'package:audiflow_app/features/player/presentation/screens/player_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/player_stubs.dart';

const _firstEpisode = NowPlayingInfo(
  episodeUrl: 'https://example.com/first.mp3',
  episodeTitle: 'First Episode',
  podcastTitle: 'Test Podcast',
);

const _secondEpisode = NowPlayingInfo(
  episodeUrl: 'https://example.com/second.mp3',
  episodeTitle: 'Second Episode',
  podcastTitle: 'Test Podcast',
);

const _openSheetKey = Key('open-sheet');
const _openDialogKey = Key('open-dialog');

Future<ProviderContainer> _container() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
      nowPlayingControllerProvider.overrideWith(
        () => StubNowPlayingController(_firstEpisode),
      ),
      audioPlayerControllerProvider.overrideWith(_pausedPlayer),
      appSettingsRepositoryProvider.overrideWithValue(
        StubAppSettingsRepository(),
      ),
      playbackProgressProvider.overrideWith((ref) => null),
      playbackSpeedProvider.overrideWith((ref) => Stream.value(1.0)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

StubAudioPlayerController _pausedPlayer() => StubAudioPlayerController(
  const PlaybackState.paused(episodeUrl: 'https://example.com/first.mp3'),
);

/// Hosts a button that presents [PlayerScreen] as a Cupertino sheet, the
/// same way the navigation shell does from the mini player.
Widget _buildHost(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Builder(builder: _openSheetButton)),
    ),
  );
}

Widget _openSheetButton(BuildContext context) => Center(
  child: ElevatedButton(
    key: _openSheetKey,
    onPressed: () => showCupertinoSheet<void>(
      context: context,
      scrollableBuilder: (context, controller) => const _SheetContent(),
    ),
    child: const Text('Open'),
  ),
);

/// The player plus a button that stacks a dialog above the sheet.
class _SheetContent extends StatelessWidget {
  const _SheetContent();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      TextButton(
        key: _openDialogKey,
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const AlertDialog(title: Text('Above the sheet')),
        ),
        child: const Text('Dialog'),
      ),
      const Expanded(child: PlayerScreen()),
    ],
  );
}

Future<void> _openPlayerSheet(WidgetTester tester) async {
  await tester.tap(find.byKey(_openSheetKey));
  await tester.pumpAndSettle();
  check(find.byType(PlayerScreen).evaluate().length).equals(1);
}

void main() {
  group('PlayerScreen auto-dismiss', () {
    testWidgets('pops the sheet when the queue is exhausted', (tester) async {
      final container = await _container();
      await tester.pumpWidget(_buildHost(container));
      await _openPlayerSheet(tester);

      container.read(nowPlayingControllerProvider.notifier).clear();
      await tester.pumpAndSettle();

      check(find.byType(PlayerScreen).evaluate()).isEmpty();
      check(find.byKey(_openSheetKey).evaluate().length).equals(1);
    });

    testWidgets('keeps drawing the last episode while sliding out', (
      tester,
    ) async {
      final container = await _container();
      await tester.pumpWidget(_buildHost(container));
      await _openPlayerSheet(tester);

      container.read(nowPlayingControllerProvider.notifier).clear();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      check(find.text('First Episode').evaluate()).isNotEmpty();
      check(find.text('No audio playing').evaluate()).isEmpty();
    });

    testWidgets('pops a dialog stacked above the sheet along with it', (
      tester,
    ) async {
      final container = await _container();
      await tester.pumpWidget(_buildHost(container));
      await _openPlayerSheet(tester);
      await tester.tap(find.byKey(_openDialogKey));
      await tester.pumpAndSettle();

      container.read(nowPlayingControllerProvider.notifier).clear();
      await tester.pumpAndSettle();

      check(find.byType(AlertDialog).evaluate()).isEmpty();
      check(find.byType(PlayerScreen).evaluate()).isEmpty();
      check(find.byKey(_openSheetKey).evaluate().length).equals(1);
    });

    testWidgets('stays open when playback advances to the next episode', (
      tester,
    ) async {
      final container = await _container();
      await tester.pumpWidget(_buildHost(container));
      await _openPlayerSheet(tester);

      container
          .read(nowPlayingControllerProvider.notifier)
          .setNowPlaying(_secondEpisode);
      await tester.pumpAndSettle();

      check(find.byType(PlayerScreen).evaluate().length).equals(1);
      check(find.text('Second Episode').evaluate().length).equals(1);
    });
  });
}
