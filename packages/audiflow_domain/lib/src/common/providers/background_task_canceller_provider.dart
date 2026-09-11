import 'package:riverpod/riverpod.dart';

/// Cancels a writer's in-flight work and completes once it has settled.
typedef WriterCanceller = Future<void> Function();

/// Provider for cancelling scheduled background tasks (feed refresh and
/// download).
///
/// "Reset All Data" awaits this before clearing storage so a Workmanager
/// task cannot start after the clear. Workmanager lives in the app package,
/// so the app overrides this at startup; the default is a no-op for hosts
/// without background tasks.
final backgroundTaskCancellerProvider = Provider<WriterCanceller>(
  (ref) => () async {},
);
