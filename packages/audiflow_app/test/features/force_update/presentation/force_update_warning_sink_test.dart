import 'package:audiflow_app/features/force_update/force_update.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

class _RecordingReporter implements ForceUpdateReporter {
  final captured = <({Object error, String? message})>[];

  @override
  void addBreadcrumb({
    required String message,
    required ForceUpdateLogLevel level,
    Map<String, Object?>? data,
  }) {}

  @override
  Future<void> captureException(
    Object error, {
    StackTrace? stackTrace,
    String? message,
  }) async {
    captured.add((error: error, message: message));
  }
}

DioException _dioError(DioExceptionType type) => DioException(
  requestOptions: RequestOptions(path: '/config.json'),
  type: type,
);

void main() {
  late _RecordingReporter reporter;
  late ForceUpdateWarningSink sink;

  setUp(() {
    reporter = _RecordingReporter();
    sink = buildForceUpdateWarningSink(
      logger: Logger(level: Level.off),
      reporter: reporter,
    );
  });

  group('buildForceUpdateWarningSink', () {
    test('does not capture connectivity failures', () {
      sink(
        'Force-update fetch failed',
        error: _dioError(DioExceptionType.connectionError),
      );

      check(reporter.captured).isEmpty();
    });

    test('captures HTTP status failures', () {
      final error = _dioError(DioExceptionType.badResponse);

      sink('Force-update fetch failed', error: error);

      check(reporter.captured).single
        ..has((c) => c.error, 'error').identicalTo(error)
        ..has((c) => c.message, 'message').equals('Force-update fetch failed');
    });

    test('captures payload failures', () {
      sink('Force-update fetch failed', error: const FormatException('bad'));

      check(reporter.captured).length.equals(1);
    });

    test('does not capture warnings without an error', () {
      sink('Force-update config rejected: schemaVersion');

      check(reporter.captured).isEmpty();
    });
  });
}
