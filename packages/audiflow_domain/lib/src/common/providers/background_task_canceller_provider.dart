import 'package:riverpod/riverpod.dart';

/// Cancels every scheduled background task (feed refresh and download).
typedef BackgroundTaskCanceller = Future<void> Function();

/// Provider for cancelling scheduled background tasks.
///
/// "Reset All Data" awaits this before clearing storage so a Workmanager
/// isolate cannot write feed data or a download back afterwards.
/// Workmanager lives in the app package, so the app overrides this at
/// startup; the default is a no-op for hosts without background tasks.
final backgroundTaskCancellerProvider = Provider<BackgroundTaskCanceller>(
  (ref) => () async {},
);
