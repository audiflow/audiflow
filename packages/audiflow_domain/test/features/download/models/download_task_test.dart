import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

DownloadTask _task(DownloadOrigin origin, DownloadStatus status) {
  return DownloadTask()
    ..episodeId = 1
    ..audioUrl = 'https://example.com/1.mp3'
    ..origin = origin.dbValue
    ..status = status.toDbValue()
    ..createdAt = DateTime(2026);
}

void main() {
  group('isRemovableByRetention', () {
    const holdingFile = <DownloadStatus>[
      DownloadStatus.pending(),
      DownloadStatus.downloading(),
      DownloadStatus.paused(),
      DownloadStatus.completed(),
    ];

    for (final status in holdingFile) {
      test('is true for an auto download that is $status', () {
        check(
          _task(DownloadOrigin.auto, status).isRemovableByRetention,
        ).isTrue();
      });
    }

    const noFile = <DownloadStatus>[
      DownloadStatus.failed(),
      DownloadStatus.cancelled(),
    ];

    for (final status in noFile) {
      test('is false for an auto download that is $status', () {
        check(
          _task(DownloadOrigin.auto, status).isRemovableByRetention,
        ).isFalse();
      });
    }

    test('is false for a manual download', () {
      check(
        _task(
          DownloadOrigin.manual,
          const DownloadStatus.completed(),
        ).isRemovableByRetention,
      ).isFalse();
    });
  });
}
