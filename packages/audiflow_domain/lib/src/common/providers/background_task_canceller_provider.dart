import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'background_task_canceller_provider.g.dart';

/// Cancels a writer's in-flight work and completes once it has settled.
typedef WriterCanceller = Future<void> Function();

/// Provides the canceller for scheduled background tasks (feed refresh and
/// download).
///
/// "Reset All Data" awaits it before clearing storage so a Workmanager
/// task cannot start after the clear. Workmanager lives in the app package,
/// so the app overrides this at startup; the default is a no-op for hosts
/// without background tasks.
@Riverpod(keepAlive: true)
WriterCanceller backgroundTaskCanceller(Ref ref) => () async {};
