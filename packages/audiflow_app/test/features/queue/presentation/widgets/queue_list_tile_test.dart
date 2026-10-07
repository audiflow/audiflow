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

DownloadTask _completed() => DownloadTask()
  ..episodeId = 9
  ..audioUrl = 'https://example.com/9.mp3'
  ..status = 3
  ..createdAt = DateTime(2026);

void main() {
  Future<void> pump(
    WidgetTester tester, {
    DownloadTask? task,
    VoidCallback? onRemove,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          episodeDownloadProvider(9).overrideWith((ref) => Stream.value(task)),
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
