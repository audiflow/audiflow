import 'package:audiflow_app/features/download/presentation/widgets/download_task_tile.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

DownloadTask _task(
  DownloadStatus status, {
  DownloadOrigin origin = DownloadOrigin.manual,
}) {
  return DownloadTask()
    ..id = 1
    ..episodeId = 1
    ..audioUrl = 'https://example.com/1.mp3'
    ..status = status.toDbValue()
    ..origin = origin.dbValue
    ..createdAt = DateTime(2026);
}

Widget _app(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  Future<int> pumpTileAndTapDelete(
    WidgetTester tester,
    DownloadStatus status,
  ) async {
    var deleteTaps = 0;
    await tester.pumpWidget(
      _app(
        DownloadTaskTile(
          task: _task(status),
          episodeTitle: 'Episode',
          onDelete: () => deleteTaps++,
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.delete_outline));
    return deleteTaps;
  }

  for (final status in const [
    DownloadStatus.pending(),
    DownloadStatus.paused(),
  ]) {
    testWidgets('offers delete for $status', (tester) async {
      check(await pumpTileAndTapDelete(tester, status)).equals(1);
    });
  }

  group('auto downloads', () {
    testWidgets('are labeled and offer keep', (tester) async {
      var keepTaps = 0;
      await tester.pumpWidget(
        _app(
          DownloadTaskTile(
            task: _task(
              const DownloadStatus.completed(),
              origin: DownloadOrigin.auto,
            ),
            episodeTitle: 'Episode',
            onKeep: () => keepTaps++,
          ),
        ),
      );

      check(
        find.text('Completed · Auto-downloaded').evaluate(),
      ).length.equals(1);
      await tester.tap(find.byTooltip('Keep download'));
      check(keepTaps).equals(1);
    });

    testWidgets('that failed carry no label or keep', (tester) async {
      await tester.pumpWidget(
        _app(
          DownloadTaskTile(
            task: _task(
              const DownloadStatus.failed(),
              origin: DownloadOrigin.auto,
            ),
            episodeTitle: 'Episode',
            onKeep: () {},
          ),
        ),
      );

      check(find.textContaining('Auto-downloaded').evaluate()).isEmpty();
      check(find.byTooltip('Keep download').evaluate()).isEmpty();
    });
  });

  testWidgets('kept downloads carry no label or keep', (tester) async {
    await tester.pumpWidget(
      _app(
        DownloadTaskTile(
          task: _task(const DownloadStatus.completed()),
          episodeTitle: 'Episode',
          onKeep: () {},
        ),
      ),
    );

    check(find.text('Completed').evaluate()).length.equals(1);
    check(find.byTooltip('Keep download').evaluate()).isEmpty();
  });
}
