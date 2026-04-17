import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feed_sync_diagnostic.g.dart';

/// Callback invoked by feed-sync code paths to emit structured diagnostic
/// events. Kept as a plain function type so `audiflow_domain` does not
/// depend on any telemetry SDK; the app layer wires it to Sentry (or any
/// other transport) via an override of [feedSyncDiagnosticSinkProvider].
///
/// [event] — stable identifier (e.g. `feed-sync:parse-complete`).
/// [data] — structured payload; values must be JSON-friendly
/// (String, num, bool, Map, List, or null).
typedef FeedSyncDiagnosticSink =
    void Function(String event, Map<String, Object?> data);

/// No-op diagnostic sink. Default so domain code can always call
/// the sink without a null-check.
void noopFeedSyncDiagnosticSink(String event, Map<String, Object?> data) {}

/// Riverpod-scoped diagnostic sink for [FeedSyncService]. Override in
/// `audiflow_app` to emit Sentry breadcrumbs / messages.
@Riverpod(keepAlive: true)
FeedSyncDiagnosticSink feedSyncDiagnosticSink(Ref ref) =>
    noopFeedSyncDiagnosticSink;
