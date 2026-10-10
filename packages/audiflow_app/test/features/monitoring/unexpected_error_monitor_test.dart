import 'package:audiflow_app/features/monitoring/services/error_reporter.dart';
import 'package:audiflow_app/features/monitoring/services/unexpected_error_monitor.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

class _RecordingReporter implements ErrorReporter {
  final captured = <ErrorReport>[];
  final breadcrumbs = <ErrorReport>[];

  @override
  Future<void> captureException(ErrorReport report) async {
    captured.add(report);
  }

  @override
  void addBreadcrumb(ErrorReport report) => breadcrumbs.add(report);
}

DioException _offline() => DioException(
  requestOptions: RequestOptions(path: 'https://feeds.example.com/rss'),
  type: DioExceptionType.connectionError,
);

// Never retry in tests; one retry scenario opts in explicitly.
Duration? _noRetry(int retryCount, Object error) => null;

void main() {
  late _RecordingReporter reporter;
  late UnexpectedErrorMonitor monitor;

  setUp(() {
    reporter = _RecordingReporter();
    monitor = UnexpectedErrorMonitor(reporter: reporter);
    Logger.addLogListener(monitor.onLogEvent);
  });

  tearDown(() => Logger.removeLogListener(monitor.onLogEvent));

  ProviderContainer containerWith({
    Duration? Function(int, Object) retry = _noRetry,
  }) {
    final container = ProviderContainer(
      observers: [monitor.providerObserver],
      retry: retry,
    );
    addTearDown(container.dispose);
    return container;
  }

  group('log events', () {
    test('reports an error-level entry with its error and stack', () {
      final error = StateError('Unique index violated.');
      final stack = StackTrace.current;
      NamedLogger('PodcastDetail').e('boom', error: error, stackTrace: stack);

      check(reporter.captured).has((it) => it.length, 'length').equals(1);
      final report = reporter.captured.single;
      check(report.error).identicalTo(error);
      check(report.stackTrace).identicalTo(stack);
      check(report.source).equals(ErrorSource.logger);
      check(report.origin).equals('PodcastDetail');
    });

    test('reports even when the logger filters the entry out', () {
      // Release builds drop log output; reporting must not depend on it.
      Logger(level: Level.off).e('boom', error: StateError('x'));

      check(reporter.captured).has((it) => it.length, 'length').equals(1);
    });

    test('ignores entries below error level', () {
      Logger(level: Level.off).w('slow', error: StateError('x'));

      check(reporter.captured).isEmpty();
      check(reporter.breadcrumbs).isEmpty();
    });

    test('ignores error entries without an error object', () {
      Logger(level: Level.off).e('Failed to parse feed');

      check(reporter.captured).isEmpty();
    });

    test('records expected failures as breadcrumbs only', () {
      Logger(level: Level.off).e('fetch failed', error: _offline());

      check(reporter.captured).isEmpty();
      check(reporter.breadcrumbs).has((it) => it.length, 'length').equals(1);
    });

    test('redacts URLs in the attached message', () {
      Logger(level: Level.off).e(
        'Failed: https://u:p@feeds.example.com/private/rss?token=abc',
        error: StateError('x'),
      );

      check(
        reporter.captured.single.message,
      ).equals('Failed: https://feeds.example.com');
    });
  });

  group('provider failures', () {
    test('reports a failing provider once with its name', () async {
      final error = StateError('Unique index violated.');
      final failing = FutureProvider<int>(
        (ref) async => throw error,
        name: 'podcastEpisodesProvider',
      );
      final container = containerWith();

      await check(container.read(failing.future)).throws<StateError>();

      check(reporter.captured).has((it) => it.length, 'length').equals(1);
      final report = reporter.captured.single;
      check(report.error).identicalTo(error);
      check(report.source).equals(ErrorSource.provider);
      check(report.origin).equals('podcastEpisodesProvider');
    });

    test(
      'reports once when a logged error is rethrown by a provider',
      () async {
        final logger = NamedLogger('PodcastDetail');
        final failing = FutureProvider<int>((ref) async {
          try {
            throw StateError('Unique index violated.');
          } catch (e, stack) {
            logger.e('fetch failed', error: e, stackTrace: stack);
            rethrow;
          }
        });
        final container = containerWith();

        await check(container.read(failing.future)).throws<StateError>();

        check(reporter.captured).has((it) => it.length, 'length').equals(1);
        check(reporter.captured.single.origin).equals('PodcastDetail');
      },
    );

    test('reports once when dependents fail with the same error', () async {
      final root = Provider<int>((ref) => throw StateError('root'));
      final dependent = Provider<int>((ref) => ref.watch(root) + 1);
      final container = containerWith();

      check(() => container.read(dependent)).throws<Object>();

      check(reporter.captured).has((it) => it.length, 'length').equals(1);
      check(reporter.captured.single.error).isA<StateError>();
    });

    test('reports once across automatic retries', () async {
      var attempts = 0;
      final failing = FutureProvider<int>((ref) async {
        attempts++;
        throw StateError('Unique index violated.');
      });
      final container = containerWith(
        retry: (retryCount, _) => retryCount < 2 ? Duration.zero : null,
      );
      container.listen(failing, (_, _) {});

      await pumpEventQueue();

      check(attempts).equals(3);
      check(reporter.captured).has((it) => it.length, 'length').equals(1);
    });

    test('records expected provider failures as breadcrumbs', () async {
      final failing = FutureProvider<int>((ref) async => throw _offline());
      final container = containerWith();

      await check(container.read(failing.future)).throws<DioException>();

      check(reporter.captured).isEmpty();
      check(reporter.breadcrumbs).has((it) => it.length, 'length').equals(1);
    });
  });

  group('redactUrls', () {
    test('keeps only scheme and host of each URL', () {
      check(
        redactUrls('a http://x.example.com/p?q=1 and https://y.example.org/'),
      ).equals('a http://x.example.com and https://y.example.org');
    });

    test('leaves text without URLs unchanged', () {
      check(
        redactUrls('parse failed at line 3'),
      ).equals('parse failed at line 3');
    });
  });
}
