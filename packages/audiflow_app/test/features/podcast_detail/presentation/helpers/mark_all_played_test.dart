import 'package:audiflow_app/features/podcast_detail/presentation/helpers/mark_all_played.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

class _FakeHistoryService extends Fake implements PlaybackHistoryService {
  _FakeHistoryService({this.failAfter});

  /// Throws after this many episodes, like a write failing partway.
  final int? failAfter;
  final completed = <int>[];

  @override
  Future<int> markAllCompleted(Iterable<int> episodeIds) async {
    for (final id in episodeIds) {
      if (completed.length == failAfter) throw StateError('disk full');
      completed.add(id);
    }
    return episodeIds.length;
  }
}

void main() {
  late _FakeHistoryService history;

  Future<void> open(WidgetTester tester, {int? failAfter}) async {
    history = _FakeHistoryService(failAfter: failAfter);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playbackHistoryServiceProvider.overrideWithValue(history),
          namedLoggerProvider.overrideWith(
            (ref, name) => Logger(level: Level.off),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => confirmAndMarkAllPlayed(
                  context: context,
                  episodeIds: const [1, 2],
                  played: true,
                  confirmText: 'Mark both?',
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('cancel leaves every episode alone', (tester) async {
    await open(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    check(history.completed).isEmpty();
  });

  testWidgets('confirm marks them and reports the count', (tester) async {
    await open(tester);
    check(find.text('Mark both?').evaluate()).length.equals(1);
    await tester.tap(find.text('Mark as played'));
    await tester.pumpAndSettle();
    check(history.completed).deepEquals([1, 2]);
    check(find.text('Marked 2 episodes as played').evaluate()).length.equals(1);
  });

  testWidgets('a failure partway is reported, not swallowed', (tester) async {
    await open(tester, failAfter: 1);
    await tester.tap(find.text('Mark as played'));
    await tester.pumpAndSettle();
    check(history.completed).deepEquals([1]);
    check(
      find.text("Some episodes couldn't be updated").evaluate(),
    ).length.equals(1);
  });
}
