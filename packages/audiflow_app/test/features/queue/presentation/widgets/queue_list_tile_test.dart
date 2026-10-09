import 'package:audiflow_app/features/queue/presentation/widgets/queue_list_tile.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

const _titles = ['Queued Episode', 'Next Episode'];

/// The [index]th up-next row: queue item 5 + index for episode 9 + index.
QueueItemWithEpisode _item([int index = 0]) => QueueItemWithEpisode(
  queueItem: QueueItem()
    ..id = 5 + index
    ..episodeId = 9 + index
    ..position = index
    ..addedAt = DateTime(2026),
  episode: Episode()
    ..id = 9 + index
    ..podcastId = 1
    ..guid = 'g${9 + index}'
    ..title = _titles[index]
    ..audioUrl = 'https://example.com/9.mp3'
    ..durationMs = 45 * 60 * 1000,
  itunesId: '123',
);

DownloadTask _task(int status) => DownloadTask()
  ..episodeId = 9
  ..audioUrl = 'https://example.com/9.mp3'
  ..status = status
  ..createdAt = DateTime(2026);

DownloadTask _completed() => _task(3);

/// The drag proxy once fully lifted.
final _lifted = find.byWidgetPredicate(
  (widget) =>
      widget is DecoratedBox &&
      widget.decoration is BoxDecoration &&
      listEquals(
        (widget.decoration as BoxDecoration).boxShadow,
        AppShadows.floating,
      ),
);

DownloadTask _autoCompleted() => _completed()
  ..id = 4
  ..origin = DownloadOrigin.auto.dbValue;

class _RecordingHapticPlayer implements HapticPlayer {
  final played = <HapticToken>[];

  @override
  void play(HapticToken token) => played.add(token);

  @override
  void prepare(HapticToken token) {}
}

void main() {
  Future<void> pump(
    WidgetTester tester, {
    DownloadTask? task,
    VoidCallback? onRemove,
    ValueChanged<int>? onReorderStart,
    void Function(int from, int to)? onReorderItem,
    int itemCount = 1,
    bool downloadCreates = true,
    _FakeDownloadService? service,
    HapticPlayer haptics = const NoopHapticPlayer(),
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        // Fresh scope per pump: overrides are fixed once a scope exists.
        key: UniqueKey(),
        overrides: [
          episodeDownloadProvider(9).overrideWith((ref) => Stream.value(task)),
          episodeDownloadProvider(10).overrideWith((ref) => Stream.value(null)),
          downloadServiceProvider.overrideWithValue(
            service ?? _FakeDownloadService(creates: downloadCreates),
          ),
        ],
        child: HapticsScope(
          player: haptics,
          child: MaterialApp(
            theme: AppTheme.light(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverReorderableList(
                    itemCount: itemCount,
                    onReorderItem: onReorderItem ?? (_, _) {},
                    onReorderStart: onReorderStart,
                    proxyDecorator: QueueListTile.liftWhileDragging,
                    itemBuilder: (_, index) => QueueListTile(
                      key: ValueKey(5 + index),
                      item: _item(index),
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

  testWidgets('a download swipe plays the threshold haptic once', (
    tester,
  ) async {
    final haptics = _RecordingHapticPlayer();
    await pump(tester, haptics: haptics);
    await tester.drag(find.text('Queued Episode'), const Offset(600, 0));
    await tester.pumpAndSettle();
    // The row springs back after starting the download; that return trip
    // is not a cancel, so no release token follows.
    check(haptics.played).deepEquals([HapticToken.thresholdCross]);
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

  testWidgets('long press offers the download step and share', (tester) async {
    await pump(tester, task: _completed());
    await tester.longPress(find.text('Queued Episode'));
    await tester.pumpAndSettle();
    check(find.text('Delete download').evaluate()).length.equals(1);
    check(find.text('Share episode').evaluate()).length.equals(1);
  });

  testWidgets('holding the drag handle never opens the menu', (tester) async {
    await pump(tester, task: _completed());
    final gesture = await tester.startGesture(
      tester.getCenter(find.byIcon(Symbols.drag_handle)),
    );
    // Well past the long-press timeout without moving, as a listener
    // pausing before the drag would.
    await tester.pump(kLongPressTimeout * 2);
    await gesture.up();
    await tester.pumpAndSettle();
    check(find.text('Delete download').evaluate()).isEmpty();
  });

  testWidgets('pausing on the handle edge, then moving, starts a reorder', (
    tester,
  ) async {
    final started = <int>[];
    await pump(tester, task: _completed(), onReorderStart: started.add);
    // Inside the touch target but off the glyph.
    final target = tester.getRect(find.byType(ReorderableDragStartListener));
    final gesture = await tester.startGesture(
      target.topLeft + const Offset(2, 2),
    );
    await tester.pump(kLongPressTimeout * 2);
    await gesture.moveBy(const Offset(0, 40));
    await tester.pump();
    check(started).deepEquals([0]);
    check(find.text('Delete download').evaluate()).isEmpty();
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('holding the handle still lifts the row before it moves', (
    tester,
  ) async {
    final started = <int>[];
    await pump(tester, onReorderStart: started.add);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byIcon(Symbols.drag_handle)),
    );
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
    check(started).deepEquals([0]);
    check(_lifted.evaluate()).length.equals(1);
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('holding the handle, then dragging past a row, reorders', (
    tester,
  ) async {
    final moves = <(int, int)>[];
    await pump(
      tester,
      itemCount: 2,
      onReorderItem: (from, to) => moves.add((from, to)),
    );
    final below = tester.getRect(find.text('Next Episode'));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byIcon(Symbols.drag_handle).first),
    );
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    // Past the second row's midpoint, in steps so the list follows.
    for (var step = 0; step < 4; step++) {
      await gesture.moveBy(Offset(0, below.height / 2));
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();
    check(moves).deepEquals([(0, 1)]);
  });

  testWidgets('the dragged row lifts with the floating shadow', (tester) async {
    await pump(tester);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byIcon(Symbols.drag_handle)),
    );
    // Moving at once, without the hold, still starts the drag.
    await gesture.moveBy(const Offset(0, 40));
    await tester.pumpAndSettle();
    check(_lifted.evaluate()).length.equals(1);
    await gesture.up();
    await tester.pumpAndSettle();
    check(_lifted.evaluate()).isEmpty();
  });

  testWidgets('long press just above the handle opens the menu', (
    tester,
  ) async {
    await pump(tester, task: _completed());
    final target = tester.getRect(find.byType(ReorderableDragStartListener));
    final row = tester.getRect(find.byType(InkWell));
    // The row's long press still covers the handle's column outside the
    // handle itself.
    await tester.longPressAt(
      Offset(target.center.dx, (row.top + target.top) / 2),
    );
    await tester.pumpAndSettle();
    check(find.text('Delete download').evaluate()).length.equals(1);
  });

  testWidgets('long press keeps an auto download and says so', (tester) async {
    final service = _FakeDownloadService();
    await pump(tester, task: _autoCompleted(), service: service);
    await tester.longPress(find.text('Queued Episode'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep download'));
    await tester.pumpAndSettle();
    check(service.keptIds).deepEquals([4]);
    check(
      find.text("Download kept. It won't be removed automatically.").evaluate(),
    ).length.equals(1);
  });

  testWidgets('long press does not offer keep for a manual download', (
    tester,
  ) async {
    await pump(tester, task: _completed());
    await tester.longPress(find.text('Queued Episode'));
    await tester.pumpAndSettle();
    check(find.text('Keep download').evaluate()).isEmpty();
  });

  testWidgets('long press offers download before one exists', (tester) async {
    await pump(tester);
    await tester.longPress(find.text('Queued Episode'));
    await tester.pumpAndSettle();
    check(find.text('Download').evaluate()).length.equals(1);
  });

  testWidgets('no success message when no download was created', (
    tester,
  ) async {
    await pump(tester, downloadCreates: false);
    await tester.drag(find.text('Queued Episode'), const Offset(600, 0));
    await tester.pumpAndSettle();
    check(find.text('Download started').evaluate()).isEmpty();
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
  _FakeDownloadService({this.creates = true});

  /// False mimics a task that already exists: nothing new is created.
  final bool creates;

  final List<int> keptIds = [];

  @override
  Future<bool> keep(int taskId) async {
    keptIds.add(taskId);
    return true;
  }

  @override
  Future<DownloadTask?> downloadEpisode(
    int episodeId, {
    bool? wifiOnly,
  }) async => creates ? _task(0) : null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
