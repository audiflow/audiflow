import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DownloadStatus', () {
    group('construction', () {
      test('creates all variants', () {
        expect(const DownloadStatus.pending(), isA<DownloadStatusPending>());
        expect(
          const DownloadStatus.downloading(),
          isA<DownloadStatusDownloading>(),
        );
        expect(const DownloadStatus.paused(), isA<DownloadStatusPaused>());
        expect(
          const DownloadStatus.completed(),
          isA<DownloadStatusCompleted>(),
        );
        expect(const DownloadStatus.failed(), isA<DownloadStatusFailed>());
        expect(
          const DownloadStatus.cancelled(),
          isA<DownloadStatusCancelled>(),
        );
      });
    });

    group('equality', () {
      test('same variants are equal', () {
        expect(
          const DownloadStatus.pending(),
          equals(const DownloadStatus.pending()),
        );
        expect(
          const DownloadStatus.downloading(),
          equals(const DownloadStatus.downloading()),
        );
        expect(
          const DownloadStatus.completed(),
          equals(const DownloadStatus.completed()),
        );
      });

      test('different variants are not equal', () {
        expect(
          const DownloadStatus.pending(),
          isNot(equals(const DownloadStatus.downloading())),
        );
        expect(
          const DownloadStatus.completed(),
          isNot(equals(const DownloadStatus.failed())),
        );
      });
    });

    group('toDbValue', () {
      test('pending maps to 0', () {
        expect(const DownloadStatus.pending().toDbValue(), 0);
      });

      test('downloading maps to 1', () {
        expect(const DownloadStatus.downloading().toDbValue(), 1);
      });

      test('paused maps to 2', () {
        expect(const DownloadStatus.paused().toDbValue(), 2);
      });

      test('completed maps to 3', () {
        expect(const DownloadStatus.completed().toDbValue(), 3);
      });

      test('failed maps to 4', () {
        expect(const DownloadStatus.failed().toDbValue(), 4);
      });

      test('cancelled maps to 5', () {
        expect(const DownloadStatus.cancelled().toDbValue(), 5);
      });
    });

    group('fromDbValue', () {
      test('0 maps to pending', () {
        expect(
          DownloadStatus.fromDbValue(0),
          equals(const DownloadStatus.pending()),
        );
      });

      test('1 maps to downloading', () {
        expect(
          DownloadStatus.fromDbValue(1),
          equals(const DownloadStatus.downloading()),
        );
      });

      test('2 maps to paused', () {
        expect(
          DownloadStatus.fromDbValue(2),
          equals(const DownloadStatus.paused()),
        );
      });

      test('3 maps to completed', () {
        expect(
          DownloadStatus.fromDbValue(3),
          equals(const DownloadStatus.completed()),
        );
      });

      test('4 maps to failed', () {
        expect(
          DownloadStatus.fromDbValue(4),
          equals(const DownloadStatus.failed()),
        );
      });

      test('5 maps to cancelled', () {
        expect(
          DownloadStatus.fromDbValue(5),
          equals(const DownloadStatus.cancelled()),
        );
      });

      test('unknown value defaults to pending', () {
        expect(
          DownloadStatus.fromDbValue(99),
          equals(const DownloadStatus.pending()),
        );
      });

      test('negative value defaults to pending', () {
        expect(
          DownloadStatus.fromDbValue(-1),
          equals(const DownloadStatus.pending()),
        );
      });
    });

    group('round-trip db conversion', () {
      test('all statuses survive round-trip', () {
        const statuses = [
          DownloadStatus.pending(),
          DownloadStatus.downloading(),
          DownloadStatus.paused(),
          DownloadStatus.completed(),
          DownloadStatus.failed(),
          DownloadStatus.cancelled(),
        ];

        for (final status in statuses) {
          final dbValue = status.toDbValue();
          final restored = DownloadStatus.fromDbValue(dbValue);
          expect(restored, equals(status));
        }
      });
    });

    group('isActive', () {
      test('pending is active', () {
        expect(const DownloadStatus.pending().isActive, isTrue);
      });

      test('downloading is active', () {
        expect(const DownloadStatus.downloading().isActive, isTrue);
      });

      test('paused is active', () {
        expect(const DownloadStatus.paused().isActive, isTrue);
      });

      test('completed is not active', () {
        expect(const DownloadStatus.completed().isActive, isFalse);
      });

      test('failed is not active', () {
        expect(const DownloadStatus.failed().isActive, isFalse);
      });

      test('cancelled is not active', () {
        expect(const DownloadStatus.cancelled().isActive, isFalse);
      });
    });

    group('needsAttention', () {
      test('failed needs attention', () {
        expect(const DownloadStatus.failed().needsAttention, isTrue);
      });

      test('pending does not need attention', () {
        expect(const DownloadStatus.pending().needsAttention, isFalse);
      });

      test('downloading does not need attention', () {
        expect(const DownloadStatus.downloading().needsAttention, isFalse);
      });

      test('completed does not need attention', () {
        expect(const DownloadStatus.completed().needsAttention, isFalse);
      });

      test('cancelled does not need attention', () {
        expect(const DownloadStatus.cancelled().needsAttention, isFalse);
      });

      test('paused does not need attention', () {
        expect(const DownloadStatus.paused().needsAttention, isFalse);
      });
    });

    group('pattern matching', () {
      test('exhaustive switch covers all variants', () {
        const statuses = <DownloadStatus>[
          DownloadStatus.pending(),
          DownloadStatus.downloading(),
          DownloadStatus.paused(),
          DownloadStatus.completed(),
          DownloadStatus.failed(),
          DownloadStatus.cancelled(),
        ];

        final results = statuses.map((status) {
          return switch (status) {
            DownloadStatusPending() => 'pending',
            DownloadStatusDownloading() => 'downloading',
            DownloadStatusPaused() => 'paused',
            DownloadStatusCompleted() => 'completed',
            DownloadStatusFailed() => 'failed',
            DownloadStatusCancelled() => 'cancelled',
          };
        }).toList();

        expect(results, [
          'pending',
          'downloading',
          'paused',
          'completed',
          'failed',
          'cancelled',
        ]);
      });
    });
  });
}
