import 'package:audiflow_app/features/podcast_detail/presentation/widgets/podcast_detail_header.dart'
    show togglePodcastSubscription;
import 'package:audiflow_app/features/subscription/presentation/controllers/subscription_controller.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _podcast = Podcast(
  id: '42',
  name: 'Show',
  artistName: 'Host',
  feedUrl: 'https://example.com/feed.xml',
);

class _RecordingHapticPlayer implements HapticPlayer {
  final played = <HapticToken>[];

  @override
  void play(HapticToken token) => played.add(token);

  @override
  void prepare(HapticToken token) {}
}

enum _Outcome { flips, fails, denied }

/// Starts in [_initial] and resolves a toggle as [_outcome] says.
class _ScriptedController extends SubscriptionController {
  _ScriptedController(this._initial, this._outcome);

  final bool _initial;
  final _Outcome _outcome;

  @override
  Future<bool> build(String itunesId) async => _initial;

  @override
  Future<bool> toggleSubscription(
    BuildContext context,
    Podcast podcast, {
    SubscribeSource source = SubscribeSource.discovery,
  }) async {
    switch (_outcome) {
      case _Outcome.flips:
        state = AsyncData(!_initial);
        return true;
      case _Outcome.fails:
        state = AsyncError(Exception('toggle failed'), StackTrace.empty);
        return true;
      case _Outcome.denied:
        return false;
    }
  }
}

void main() {
  Future<List<HapticToken>> toggle(
    WidgetTester tester, {
    required bool subscribed,
    required _Outcome outcome,
  }) async {
    final player = _RecordingHapticPlayer();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          subscriptionControllerProvider(
            '42',
          ).overrideWith(() => _ScriptedController(subscribed, outcome)),
        ],
        child: HapticsScope(
          player: player,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  // Watched like the podcast header does, so the state is loaded.
                  ref.watch(subscriptionControllerProvider('42'));
                  return TextButton(
                    onPressed: () => togglePodcastSubscription(
                      context: context,
                      ref: ref,
                      podcast: _podcast,
                      source: SubscribeSource.discovery,
                      expectSubscribed: subscribed,
                    ),
                    child: const Text('toggle'),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('toggle'));
    await tester.pumpAndSettle();
    return player.played;
  }

  testWidgets('subscribing plays success', (tester) async {
    check(
      await toggle(tester, subscribed: false, outcome: _Outcome.flips),
    ).deepEquals([HapticToken.success]);
  });

  testWidgets('unsubscribing plays tap', (tester) async {
    check(
      await toggle(tester, subscribed: true, outcome: _Outcome.flips),
    ).deepEquals([HapticToken.tap]);
  });

  testWidgets('a failed toggle plays error', (tester) async {
    check(
      await toggle(tester, subscribed: false, outcome: _Outcome.fails),
    ).deepEquals([HapticToken.error]);
  });

  testWidgets('a toggle refused by the PIN gate plays nothing', (tester) async {
    check(
      await toggle(tester, subscribed: false, outcome: _Outcome.denied),
    ).isEmpty();
  });
}
