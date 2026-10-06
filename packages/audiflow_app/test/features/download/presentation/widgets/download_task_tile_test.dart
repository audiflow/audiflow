import 'package:audiflow_app/features/download/presentation/widgets/download_task_tile.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

DownloadTask _task(DownloadStatus status) {
  return DownloadTask()
    ..id = 1
    ..episodeId = 1
    ..audioUrl = 'https://example.com/1.mp3'
    ..status = status.toDbValue()
    ..createdAt = DateTime(2026);
}

void main() {
  Future<int> pumpTileAndTapDelete(
    WidgetTester tester,
    DownloadStatus status,
  ) async {
    var deleteTaps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DownloadTaskTile(
            task: _task(status),
            episodeTitle: 'Episode',
            onDelete: () => deleteTaps++,
          ),
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
}
