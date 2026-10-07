import 'package:audiflow_app/features/queue/presentation/widgets/queue_list_tile.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

QueueItemWithEpisode _item() => QueueItemWithEpisode(
  queueItem: QueueItem()
    ..id = 5
    ..episodeId = 9
    ..position = 0
    ..addedAt = DateTime(2026),
  episode: Episode()
    ..id = 9
    ..podcastId = 1
    ..guid = 'g9'
    ..title = 'Queued Episode'
    ..audioUrl = 'https://example.com/9.mp3'
    ..durationMs = 45 * 60 * 1000,
);

DownloadTask _task(int status) => DownloadTask()
  ..episodeId = 9
  ..audioUrl = 'https://example.com/9.mp3'
  ..status = status
  ..createdAt = DateTime(2026);

DownloadTask _completed() => _task(3);

void main() {
  Future<void> pump(
    WidgetTester tester, {
    DownloadTask? task,
    VoidCallback? onRemove,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        // Fresh scope per pump: overrides are fixed once a scope exists.
        key: UniqueKey(),
        overrides: [
          episodeDownloadProvider(9).overrideWith((ref) => Stream.value(task)),
          downloadServiceProvider.overrideWithValue(_FakeDownloadService()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverReorderableList(
                  itemCount: 1,
                  onReorderItem: (_, _) {},
                  itemBuilder: (_, index) => QueueListTile(
                    key: const ValueKey(5),
                    item: _item(),
                    index: index,
                    onRemove: onRemove ?? () {},
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('drag handle is the only trailing control', (tester) async {
    await pump(tester);
    check(find.byType(IconButton).evaluate()).isEmpty();
    check(
      find.byType(ReorderableDragStartListener).evaluate(),
    ).length.equals(1);
    check(find.text('45m').evaluate()).length.equals(1);
  });

  testWidgets('no downloaded mark before download', (tester) async {
    await pump(tester);
    check(find.byIcon(Symbols.download_done).evaluate()).isEmpty();
  });

  testWidgets('marks downloaded episodes', (tester) async {
    await pump(tester, task: _completed());
    check(find.byIcon(Symbols.download_done).evaluate()).length.equals(1);
  });

  testWidgets('shows download progress while downloading', (tester) async {
    final task = _task(1)
      ..downloadedBytes = 45
      ..totalBytes = 100;
    await pump(tester, task: task);
    final ring = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    check(ring.value).equals(0.45);
    check(find.text('45%').evaluate()).length.equals(1);
  });

  testWidgets('labels a waiting download', (tester) async {
    await pump(tester, task: _task(0));
    check(find.text('Pending').evaluate()).length.equals(1);
  });

  testWidgets('swiping right starts a download and says so', (tester) async {
    await pump(tester);
    await tester.drag(find.text('Queued Episode'), const Offset(600, 0));
    await tester.pumpAndSettle();
    check(find.text('Download started').evaluate()).length.equals(1);
    // The row springs back instead of leaving the list.
    check(find.text('Queued Episode').evaluate()).length.equals(1);
  });

  testWidgets('the swipe action follows the download state', (tester) async {
    Future<String> actionFor(DownloadTask? task) async {
      await pump(tester, task: task);
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Queued Episode')),
      );
      // Past the drag slop first, then far enough to reveal the background.
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump();
      await gesture.moveBy(const Offset(120, 0));
      await tester.pump();
      final labels = [
        'Download',
        'Pause',
        'Resume',
        'Cancel',
        'Retry',
        'Delete',
      ].where((label) => find.text(label).evaluate().isNotEmpty).toList();
      await gesture.up();
      await tester.pumpAndSettle();
      return labels.single;
    }

    check(await actionFor(null)).equals('Download');
    // A known size keeps the ring determinate, so the test can settle.
    final downloading = _task(1)
      ..downloadedBytes = 1
      ..totalBytes = 2;
    check(await actionFor(downloading)).equals('Pause');
    check(await actionFor(_task(2))).equals('Resume');
    check(await actionFor(_task(0))).equals('Cancel');
    check(await actionFor(_task(4))).equals('Retry');
    check(await actionFor(_task(3))).equals('Delete');
  });

  testWidgets('download state sits at the row end', (tester) async {
    await pump(tester, task: _task(0));
    final mark = tester.getRect(find.text('Pending'));
    final handle = tester.getRect(find.byType(ReorderableDragStartListener));
    check(handle.left - mark.right).isLessOrEqual(Spacing.sm);
  });

  testWidgets('swiping left removes the episode', (tester) async {
    var removed = 0;
    await pump(tester, onRemove: () => removed++);
    await tester.drag(find.text('Queued Episode'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    check(removed).equals(1);
  });

  testWidgets('remove is offered as an accessibility action', (tester) async {
    final handle = tester.ensureSemantics();
    var removed = 0;
    await pump(tester, onRemove: () => removed++);
    final node = tester.getSemantics(find.text('Queued Episode'));
    final action = node.getSemanticsData().customSemanticsActionIds!.firstWhere(
      (id) => CustomSemanticsAction.getAction(id)?.label == 'Remove from queue',
    );
    node.owner!.performAction(node.id, SemanticsAction.customAction, action);
    await tester.pump();
    check(removed).equals(1);
    handle.dispose();
  });
}

class _FakeDownloadService implements DownloadService {
  @override
  Future<DownloadTask?> downloadEpisode(
    int episodeId, {
    bool? wifiOnly,
  }) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
