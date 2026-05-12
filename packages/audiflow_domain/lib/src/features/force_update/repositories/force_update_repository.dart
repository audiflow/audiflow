import '../models/force_update_config.dart';

/// Optional sink for non-fatal warnings (failed fetch, invalid payload).
///
/// Lives on the repository interface so callers can construct sinks
/// without importing the implementation. Wire through to logger /
/// Sentry at the composition root.
typedef ForceUpdateWarningSink =
    void Function(String message, {Object? error, StackTrace? stackTrace});

/// Coordinates the remote fetch and the local cache for the
/// force-update config.
///
/// Implementations MUST honor "fail-open" semantics: if the remote is
/// unreachable or returns an invalid payload, return the previously
/// cached config (if still valid) or null. They must never throw.
abstract class ForceUpdateRepository {
  /// Tries to fetch a fresh config and persist it on success.
  /// Falls back to the cached config on any failure, then null.
  Future<ForceUpdateConfig?> refresh();

  /// Returns the cached config without touching the network.
  /// Honors offline blocks (e.g. a previously cached hard-update).
  Future<ForceUpdateConfig?> readCachedOnly();

  /// Timestamp of the last successful fetch, or null if none recorded.
  DateTime? lastFetchAt();
}
