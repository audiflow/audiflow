import 'dart:async';

import 'package:audiflow_app/features/player/presentation/screens/player_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
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

Future<ProviderContainer> _container({
  NowPlayingInfo nowPlaying = _firstEpisode,
  List<Override> extra = const [],
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
      nowPlayingControllerProvider.overrideWith(
        () => StubNowPlayingController(nowPlaying),
      ),
      audioPlayerControllerProvider.overrideWith(_pausedPlayer),
      appSettingsRepositoryProvider.overrideWithValue(
        StubAppSettingsRepository(),
      ),
      playbackProgressProvider.overrideWith((ref) => null),
      ...extra,
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

  group('PlayerScreen overflow menu', () {
    Future<void> openMenu(WidgetTester tester) async {
      await tester.tap(find.byTooltip('More'));
      await tester.pumpAndSettle();
    }

    testWidgets('opens just below the button, like the floating bars', (
      tester,
    ) async {
      final container = await _container();
      await tester.pumpWidget(_buildHost(container));
      await _openPlayerSheet(tester);
      final button = tester.getRect(find.byTooltip('More'));

      await openMenu(tester);

      final menu = tester.getRect(find.byKey(ActionMenu.surfaceKey));
      check(
        menu.top,
      ).equals(button.center.dy + FloatingNavigationBar.barHeight / 2);
      check(button.bottom <= menu.top).isTrue();
    });

    testWidgets('offers sharing when the episode has a deep link', (
      tester,
    ) async {
      final container = await _container(
        nowPlaying: _firstEpisode.copyWith(
          itunesId: '123',
          episodeGuid: 'guid-1',
        ),
      );
      await tester.pumpWidget(_buildHost(container));
      await _openPlayerSheet(tester);

      await openMenu(tester);

      check(find.text('Share episode').evaluate().length).equals(1);
    });

    testWidgets('offers sharing through the episode link alone', (
      tester,
    ) async {
      final episode = Episode()
        ..podcastId = 1
        ..guid = 'guid-1'
        ..title = 'First Episode'
        ..audioUrl = 'https://example.com/first.mp3'
        ..link = 'https://example.com/episodes/1';
      final container = await _container(
        nowPlaying: _firstEpisode.copyWith(episode: episode),
      );
      await tester.pumpWidget(_buildHost(container));
      await _openPlayerSheet(tester);

      await openMenu(tester);

      check(find.text('Share episode').evaluate().length).equals(1);
    });

    /// Records what reaches the share plugin, so the sheet's payload can be
    /// checked without a platform.
    List<Map<Object?, Object?>> captureShares() {
      const channel = MethodChannel('dev.fluttercommunity.plus/share');
      final shares = <Map<Object?, Object?>>[];
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (call) async {
        shares.add(call.arguments as Map<Object?, Object?>);
        return '';
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      return shares;
    }

    Future<Map<Object?, Object?>> shareFromMenu(
      WidgetTester tester,
      List<Map<Object?, Object?>> shares,
    ) async {
      await openMenu(tester);
      await tester.tap(find.text('Share episode'));
      await tester.pumpAndSettle();
      check(shares.length).equals(1);
      return shares.single;
    }

    void checkAnchoredOnButton(Map<Object?, Object?> share, Rect button) {
      check(share['originX']).equals(button.left);
      check(share['originY']).equals(button.top);
      check(share['originWidth']).equals(button.width);
      check(share['originHeight']).equals(button.height);
    }

    testWidgets('shares the deep link, anchored on the button', (tester) async {
      final shares = captureShares();
      final container = await _container(
        nowPlaying: _firstEpisode.copyWith(
          itunesId: '123',
          episodeGuid: 'guid-1',
        ),
      );
      await tester.pumpWidget(_buildHost(container));
      await _openPlayerSheet(tester);
      final button = tester.getRect(
        find.ancestor(
          of: find.byTooltip('More'),
          matching: find.byType(IconButton),
        ),
      );

      final share = await shareFromMenu(tester, shares);

      check(
        share['uri'],
      ).isA<String>().startsWith('https://audiflow.reedom.com/p/123/e/');
      checkAnchoredOnButton(share, button);
    });

    testWidgets('falls back to the episode link without a deep link', (
      tester,
    ) async {
      final shares = captureShares();
      final episode = Episode()
        ..podcastId = 1
        ..guid = 'guid-1'
        ..title = 'First Episode'
        ..audioUrl = 'https://example.com/first.mp3'
        ..link = 'https://example.com/episodes/1';
      final container = await _container(
        nowPlaying: _firstEpisode.copyWith(episode: episode),
      );
      await tester.pumpWidget(_buildHost(container));
      await _openPlayerSheet(tester);
      final button = tester.getRect(
        find.ancestor(
          of: find.byTooltip('More'),
          matching: find.byType(IconButton),
        ),
      );

      final share = await shareFromMenu(tester, shares);

      check(share['uri']).equals('https://example.com/episodes/1');
      checkAnchoredOnButton(share, button);
    });

    testWidgets('hides sharing when there is nothing to link to', (
      tester,
    ) async {
      final container = await _container();
      await tester.pumpWidget(_buildHost(container));
      await _openPlayerSheet(tester);

      await openMenu(tester);

      check(find.text('Share episode').evaluate()).isEmpty();
    });
  });

  group('PlayerScreen transcript page', () {
    final episode = Episode()
      ..id = 7
      ..podcastId = 1
      ..guid = 'guid-7'
      ..title = 'Transcribed Episode'
      ..audioUrl = 'https://example.com/first.mp3';

    // Unless told otherwise the feed declares a VTT file, so the page can
    // only be gated on what loads, never on the declaration alone.
    Future<ProviderContainer> containerWith(
      Future<int?> transcript, {
      bool declared = true,
    }) => _container(
      nowPlaying: _firstEpisode.copyWith(episode: episode),
      extra: [
        episodeTranscriptMetasProvider.overrideWith(
          (ref, _) async => [
            if (declared)
              EpisodeTranscript()
                ..episodeId = 7
                ..url = 'https://example.com/7.vtt'
                ..type = 'text/vtt',
          ],
        ),
        transcriptServiceProvider.overrideWithValue(
          StubTranscriptService(transcript),
        ),
        transcriptSegmentsProvider.overrideWith((ref, _) async => []),
        episodeChaptersProvider.overrideWith((ref, _) async => []),
      ],
    );

    Future<void> openMenu(WidgetTester tester) async {
      await tester.tap(find.byTooltip('More'));
      await tester.pumpAndSettle();
    }

    testWidgets('adds the page and menu entry once the transcript loads', (
      tester,
    ) async {
      // Availability is async: the first frame builds one page, then the
      // controller is rebuilt with two. Recreating it must not exceed the
      // State's ticker budget.
      final loaded = Completer<int?>();
      final container = await containerWith(loaded.future);
      await tester.pumpWidget(_buildHost(container));
      await _openPlayerSheet(tester);
      check(find.byType(TabBarView).evaluate()).isEmpty();

      loaded.complete(3);
      await tester.pumpAndSettle();

      check(tester.takeException()).isNull();
      check(find.byType(TabBarView).evaluate().length).equals(1);

      await openMenu(tester);
      await tester.tap(find.text('Transcript'));
      await tester.pumpAndSettle();
      check(
        tester.widget<TabBarView>(find.byType(TabBarView)).controller!.index,
      ).equals(1);
    });

    testWidgets('offers no page or menu entry while the transcript loads', (
      tester,
    ) async {
      final container = await containerWith(Completer<int?>().future);
      await tester.pumpWidget(_buildHost(container));
      await _openPlayerSheet(tester);

      check(find.byType(TabBarView).evaluate()).isEmpty();
      await openMenu(tester);
      check(find.text('Transcript').evaluate()).isEmpty();
    });

    testWidgets('offers no page or menu entry without a transcript', (
      tester,
    ) async {
      final container = await containerWith(Future.value(), declared: false);
      await tester.pumpWidget(_buildHost(container));
      await _openPlayerSheet(tester);

      check(find.byType(TabBarView).evaluate()).isEmpty();
      await openMenu(tester);
      check(find.text('Transcript').evaluate()).isEmpty();
      check(find.text('Episode details').evaluate()).isNotEmpty();
    });

    testWidgets('a declared transcript that fails to load counts as none', (
      tester,
    ) async {
      // The service answers null when the file is unreachable, empty, or
      // holds no cues.
      final container = await containerWith(Future.value());
      await tester.pumpWidget(_buildHost(container));
      await _openPlayerSheet(tester);

      check(find.byType(TabBarView).evaluate()).isEmpty();
      await openMenu(tester);
      check(find.text('Transcript').evaluate()).isEmpty();
      // The episode rows' CC badge follows the player's answer.
      check(
        await container.read(episodeHasTranscriptProvider(7).future),
      ).isFalse();
    });
  });
}
