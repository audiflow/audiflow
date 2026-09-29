import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:logger/logger.dart';

import 'force_update_reporter.dart';

/// Builds the production [ForceUpdateWarningSink]: every warning is logged,
/// and warnings carrying an error are captured through [reporter].
///
/// Connectivity failures are only logged. Offline launches are expected and
/// the repository already falls back to the cache, so capturing them would
/// bury real config problems (bad status, bad payload) under noise.
ForceUpdateWarningSink buildForceUpdateWarningSink({
  required Logger logger,
  required ForceUpdateReporter reporter,
}) {
  return (String message, {Object? error, StackTrace? stackTrace}) {
    logger.w(message, error: error, stackTrace: stackTrace);
    if (error == null || isConnectivityFailure(error)) return;
    unawaited(
      reporter.captureException(
        error,
        stackTrace: stackTrace,
        message: message,
      ),
    );
  };
}
