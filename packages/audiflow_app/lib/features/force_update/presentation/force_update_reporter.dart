import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'force_update_reporter.g.dart';

/// Severity hint surfaced by the controller without leaking
/// `package:sentry_flutter` types beyond this seam.
enum ForceUpdateLogLevel { info, warning }

/// Thin Sentry seam for the force-update feature.
///
/// Wrapping Sentry behind an interface keeps the controller free of a
/// direct Sentry import and lets tests record breadcrumbs without
/// running the real SDK. The default implementation forwards to
/// `Sentry.addBreadcrumb` / `Sentry.captureException`.
abstract class ForceUpdateReporter {
  void addBreadcrumb({
    required String message,
    required ForceUpdateLogLevel level,
    Map<String, Object?>? data,
  });

  Future<void> captureException(
    Object error, {
    StackTrace? stackTrace,
    String? message,
  });
}

class SentryForceUpdateReporter implements ForceUpdateReporter {
  const SentryForceUpdateReporter();

  static const _category = 'force-update';

  @override
  void addBreadcrumb({
    required String message,
    required ForceUpdateLogLevel level,
    Map<String, Object?>? data,
  }) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: _category,
        level: _toSentryLevel(level),
        data: data,
      ),
    );
  }

  @override
  Future<void> captureException(
    Object error, {
    StackTrace? stackTrace,
    String? message,
  }) async {
    // Swallow transport failures: a failing Sentry call must never
    // escape the zone or cancel callers (lifecycle observers, retry
    // taps). The `message` is forwarded as a context tag so the event
    // retains the call site label.
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: message == null
          ? null
          : (scope) => scope.setContexts('force_update', {'message': message}),
    ).catchError((Object _, StackTrace _) {
      return const SentryId.empty();
    });
  }

  SentryLevel _toSentryLevel(ForceUpdateLogLevel level) => switch (level) {
    ForceUpdateLogLevel.info => SentryLevel.info,
    ForceUpdateLogLevel.warning => SentryLevel.warning,
  };
}

/// Injection seam: the controller reads this provider so tests can
/// swap in a recording fake. Defaults to the real Sentry implementation.
@Riverpod(keepAlive: true)
ForceUpdateReporter forceUpdateReporter(Ref ref) =>
    const SentryForceUpdateReporter();
