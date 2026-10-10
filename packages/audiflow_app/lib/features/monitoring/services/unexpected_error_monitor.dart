import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:logger/logger.dart';

import 'error_report_deduplicator.dart';
import 'error_reporter.dart';
import 'failure_classification.dart';

/// Forwards unexpected errors to an [ErrorReporter] from the two places
/// they surface: error-level log entries carrying an error object, and
/// failed Riverpod providers (whose `AsyncValue.error` renders as error UI).
///
/// Expected failures (offline, user cancellation) become breadcrumbs. Each
/// failure is reported once, however many sources see it; see
/// [ErrorReportDeduplicator].
class UnexpectedErrorMonitor {
  UnexpectedErrorMonitor({
    required this._reporter,
    ErrorReportDeduplicator? deduplicator,
  }) : _deduplicator = deduplicator ?? ErrorReportDeduplicator();

  final ErrorReporter _reporter;
  final ErrorReportDeduplicator _deduplicator;

  /// Observer to register on the root [ProviderContainer].
  late final ProviderObserver providerObserver = _ReportingProviderObserver(
    this,
  );

  /// Listener to register with [Logger.addLogListener]; it sees entries of
  /// every logger regardless of each logger's own level filter.
  void onLogEvent(LogEvent event) {
    final error = event.error;
    if (error == null || event.level < Level.error) return;
    final message = event.message;
    _handle(
      ErrorReport(
        error: error,
        stackTrace: event.stackTrace,
        source: ErrorSource.logger,
        origin: NamedLogger.dispatchingName,
        message: message is String ? redactUrls(message) : null,
      ),
    );
  }

  void _onProviderFailed(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
  ) {
    // A provider that reads a failed provider fails with a ProviderException
    // wrapping the original; unwrap so both resolve to one failure.
    final (rootError, rootStack) = _unwrap(error, stackTrace);
    _handle(
      ErrorReport(
        error: rootError,
        stackTrace: rootStack,
        source: ErrorSource.provider,
        origin: provider.name ?? provider.runtimeType.toString(),
      ),
    );
  }

  void _handle(ErrorReport report) {
    final scope = '${report.source.name}:${report.origin}';
    if (!_deduplicator.isFirstSighting(report.error, scope: scope)) return;
    if (isExpectedFailure(report.error)) {
      _reporter.addBreadcrumb(report);
      return;
    }
    unawaited(_reporter.captureException(report));
  }

  (Object, StackTrace) _unwrap(Object error, StackTrace stackTrace) {
    var currentError = error;
    var currentStack = stackTrace;
    while (currentError is ProviderException) {
      currentStack = currentError.stackTrace;
      currentError = currentError.exception;
    }
    return (currentError, currentStack);
  }
}

final class _ReportingProviderObserver extends ProviderObserver {
  _ReportingProviderObserver(this._monitor);

  final UnexpectedErrorMonitor _monitor;

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    _monitor._onProviderFailed(context.provider, error, stackTrace);
  }
}

final _urlPattern = RegExp(r'[a-zA-Z][a-zA-Z0-9+.-]*://[^\s\x27"<>]+');

/// [text] with every URL reduced to scheme and host.
///
/// Feed and media URLs can carry credentials or tokens in their user info,
/// path or query (private feeds, signed CDN links).
String redactUrls(String text) => text.replaceAllMapped(_urlPattern, (match) {
  final uri = Uri.tryParse(match[0]!);
  if (uri == null || uri.host.isEmpty) return '<url>';
  return Uri(scheme: uri.scheme, host: uri.host).toString();
});
