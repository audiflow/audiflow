import 'package:audiflow_app/features/download/presentation/widgets/bulk_delete_button.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

DownloadTask _task(int id, DownloadStatus status) {
  return DownloadTask()
    ..id = id
    ..episodeId = id
    ..audioUrl = 'https://example.com/$id.mp3'
    ..status = status.toDbValue()
    ..createdAt = DateTime(2026);
}

void main() {
  final tasks = [
    _task(1, const DownloadStatus.pending()),
    _task(2, const DownloadStatus.paused()),
    _task(3, const DownloadStatus.completed()),
  ];

  late List<({List<int> taskIds, Set<DownloadStatus> statuses})> deleteCalls;

  setUp(() => deleteCalls = []);

  Widget buildTestWidget(List<DownloadTask> tasks) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        appBar: AppBar(
          actions: [
            BulkDeleteButton(
              tasks: tasks,
              onDelete: (taskIds, statuses) async {
                deleteCalls.add((taskIds: taskIds, statuses: statuses));
                return 2;
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.delete_sweep));
    await tester.pumpAndSettle();
  }

  testWidgets('is hidden when there are no downloads', (tester) async {
    await tester.pumpWidget(buildTestWidget(const []));

    expect(find.byIcon(Icons.delete_sweep), findsNothing);
  });

  testWidgets('shows counts and disables empty groups', (tester) async {
    await tester.pumpWidget(buildTestWidget(tasks));
    await openMenu(tester);

    expect(find.text('Delete completed (1)'), findsOneWidget);
    expect(find.text('Delete pending and paused (2)'), findsOneWidget);
    expect(find.text('Delete all (3)'), findsOneWidget);

    await tester.tap(find.text('Delete failed and cancelled (0)'));
    await tester.pumpAndSettle();
    check(find.byType(AlertDialog).evaluate()).isEmpty();
    check(find.byKey(ActionMenu.surfaceKey).evaluate()).length.equals(1);
  });

  testWidgets('deletes pending and paused after confirmation', (tester) async {
    await tester.pumpWidget(buildTestWidget(tasks));
    await openMenu(tester);
    await tester.tap(find.text('Delete pending and paused (2)'));
    await tester.pumpAndSettle();

    expect(
      find.text('2 downloads will be deleted. This cannot be undone.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    check(deleteCalls).length.equals(1);
    check(deleteCalls.single.taskIds).deepEquals([1, 2]);
    check(deleteCalls.single.statuses).unorderedEquals([
      const DownloadStatus.pending(),
      const DownloadStatus.paused(),
    ]);
    expect(find.text('Deleted 2 downloads'), findsOneWidget);
  });

  testWidgets('deletes nothing when the confirmation is cancelled', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget(tasks));
    await openMenu(tester);
    await tester.tap(find.text('Delete completed (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    check(deleteCalls).isEmpty();
  });
}
