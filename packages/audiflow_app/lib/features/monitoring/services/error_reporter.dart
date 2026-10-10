import 'package:sentry_flutter/sentry_flutter.dart';

import 'failure_classification.dart';

/// Where a failure surfaced before reaching error monitoring.
enum ErrorSource {
  /// An error-level log entry carrying an error object.
  logger,

  /// A Riverpod provider that ended in an error state.
  provider,
}

/// One failure handed to an [ErrorReporter].
class ErrorReport {
  const ErrorReport({
    required this.error,
    required this.source,
    this.stackTrace,
    this.origin,
    this.message,
  });

  final Object error;
  final StackTrace? stackTrace;
  final ErrorSource source;

  /// Logger name or provider name; never a family argument, which can be a
  /// feed URL or other user-specific value.
  final String? origin;

  /// Log message with URLs reduced to scheme and host.
  final String? message;
}

/// Seam between error monitoring and Sentry, so tests can record reports
/// without the SDK.
abstract interface class ErrorReporter {
  /// Sends [report] as an error event with its stack trace.
  Future<void> captureException(ErrorReport report);

  /// Records [report] as a breadcrumb that only rides along with a later
  /// real error event.
  void addBreadcrumb(ErrorReport report);
}

class SentryErrorReporter implements ErrorReporter {
  const SentryErrorReporter();

  @override
  Future<void> captureException(ErrorReport report) async {
    // A failing Sentry call must never escape into the code that failed.
    await Sentry.captureException(
      report.error,
      stackTrace: report.stackTrace,
      withScope: (scope) => _describe(scope, report),
    ).catchError((Object _, StackTrace _) => const SentryId.empty());
  }

  @override
  void addBreadcrumb(ErrorReport report) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: errorCategory(report.error),
        category: 'error.expected',
        level: SentryLevel.info,
        data: {'source': report.source.name, 'origin': ?report.origin},
      ),
    );
  }

  Future<void> _describe(Scope scope, ErrorReport report) async {
    await scope.setTag('error_source', report.source.name);
    // Keyed by source so Sentry can filter by `logger:X` or `provider:Y`.
    final origin = report.origin;
    if (origin != null) await scope.setTag(report.source.name, origin);
    final message = report.message;
    if (message != null) await scope.setContexts('log', {'message': message});
  }
}
