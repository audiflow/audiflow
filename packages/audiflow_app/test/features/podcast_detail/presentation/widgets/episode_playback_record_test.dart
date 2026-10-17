import 'dart:async';

import 'package:audiflow_app/features/podcast_detail/presentation/widgets/episode_playback_record.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_app/l10n/app_localizations_en.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

const _episodeId = 7;

PlaybackHistory _history({
  int playCount = 1,
  int completedCount = 0,
  int totalListenedMs = 0,
  int totalRealtimeMs = 0,
  DateTime? lastPlayedAt,
}) => PlaybackHistory()
  ..episodeId = _episodeId
  ..playCount = playCount
  ..completedCount = completedCount
  ..totalListenedMs = totalListenedMs
  ..totalRealtimeMs = totalRealtimeMs
  ..firstPlayedAt = DateTime(2026, 3, 1, 9)
  ..lastPlayedAt = lastPlayedAt ?? DateTime(2026, 3, 1, 9);

void main() {
  final l10n = AppLocalizationsEn();
  late StreamController<PlaybackHistory?> histories;
  late int recordBuilds;

  setUp(() {
    histories = StreamController<PlaybackHistory?>.broadcast();
    addTearDown(histories.close);
    recordBuilds = 0;
    debugOnRebuildDirtyWidget = (element, _) {
      if (element.widget is EpisodePlaybackRecord) recordBuilds++;
    };
    addTearDown(() => debugOnRebuildDirtyWidget = null);
  });

  Future<void> pump(
    WidgetTester tester, {
    int? episodeId = _episodeId,
    PlaybackHistory? snapshot,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          episodePlaybackHistoryProvider.overrideWith(
            (ref, id) => histories.stream,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: EpisodePlaybackRecord(
                episodeId: episodeId,
                history: snapshot,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> write(WidgetTester tester, PlaybackHistory? history) async {
    histories.add(history);
    // The event, then Riverpod's notification, each land a frame later.
    await tester.pumpAndSettle();
  }

  bool shows(String text) => find.text(text).evaluate().isNotEmpty;

  group('EpisodePlaybackRecord', () {
    testWidgets('shows the snapshot until the live history arrives', (
      tester,
    ) async {
      await pump(tester, snapshot: _history(playCount: 3));

      check(shows(l10n.episodeDetailTimes(3))).isTrue();
    });

    testWidgets('shows placeholders for an episode never played', (
      tester,
    ) async {
      await pump(tester);
      await write(tester, null);

      check(
        find.text(EpisodePlaybackRecord.noValue).evaluate(),
      ).length.equals(4);
      check(find.text(l10n.statsNever).evaluate()).length.equals(2);
    });

    testWidgets('keeps the snapshot for an episode not saved yet', (
      tester,
    ) async {
      await pump(tester, episodeId: null, snapshot: _history(playCount: 2));

      check(shows(l10n.episodeDetailTimes(2))).isTrue();
    });

    testWidgets('updates total listened when its minute label changes', (
      tester,
    ) async {
      await pump(tester);
      await write(tester, _history(totalListenedMs: 59000));
      check(shows(l10n.groupDurationMinutes(0))).isTrue();

      await write(tester, _history(totalListenedMs: 61000));

      check(shows(l10n.groupDurationMinutes(1))).isTrue();
    });

    testWidgets('updates times completed and last played on completion', (
      tester,
    ) async {
      await pump(tester);
      await write(tester, _history());

      await write(
        tester,
        _history(completedCount: 1, lastPlayedAt: DateTime(2026, 3, 4, 21)),
      );

      check(find.text(l10n.episodeDetailTimes(1)).evaluate()).length.equals(2);
      // Formatted after pumping, once the app has loaded locale data.
      final day = DateFormat.yMMMd('en').format(DateTime(2026, 3, 4));
      check(shows(day)).isTrue();
    });

    testWidgets('does not rebuild for a write that changes no label', (
      tester,
    ) async {
      await pump(tester);
      await write(
        tester,
        _history(totalListenedMs: 60000, totalRealtimeMs: 60000),
      );
      final builds = recordBuilds;

      // Progress saves add a few hundred ms and move lastPlayedAt within
      // the same day; neither changes a displayed value.
      await write(
        tester,
        _history(
          totalListenedMs: 60200,
          totalRealtimeMs: 60200,
          lastPlayedAt: DateTime(2026, 3, 1, 9, 0, 5),
        ),
      );

      check(recordBuilds).equals(builds);
    });

    testWidgets('rebuilds once for a write that changes a label', (
      tester,
    ) async {
      await pump(tester);
      await write(tester, _history(totalListenedMs: 60000));
      final builds = recordBuilds;

      await write(tester, _history(totalListenedMs: 120000));

      check(recordBuilds).equals(builds + 1);
    });
  });
}
