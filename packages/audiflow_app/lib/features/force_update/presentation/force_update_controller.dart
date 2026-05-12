import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'force_update_reporter.dart';

part 'force_update_controller.g.dart';

/// Running app's semver, derived from [PackageInfo.version].
///
/// `package_info_plus` returns the manifest version (e.g. `2.0.0`).
/// We trim any trailing `+build` qualifier some platforms include.
@Riverpod(keepAlive: true)
Future<Version> currentAppVersion(Ref ref) async {
  final info = await PackageInfo.fromPlatform();
  final raw = info.version.split('+').first;
  return Version.parse(raw);
}

/// AsyncNotifier exposing the current [UpdateDecision].
///
/// Cold-start strategy:
/// 1. Read the cached config synchronously; emit a decision derived
///    from it (or [NoUpdate] when no cache exists yet) so the gate
///    can render without a network round-trip.
/// 2. Kick off a background refresh; once it completes the notifier
///    re-emits with the fresh decision.
///
/// [refresh] re-runs the network fetch on demand (used by the gate's
/// lifecycle observer and the maintenance retry button). Failures keep
/// the existing decision via the repository's fail-open contract.
@Riverpod(keepAlive: true)
class ForceUpdateController extends _$ForceUpdateController {
  bool _refreshInFlight = false;

  @override
  Future<UpdateDecision> build() async {
    final repo = ref.watch(forceUpdateRepositoryProvider);
    final version = await ref.watch(currentAppVersionProvider.future);

    final cached = await repo.readCachedOnly();
    final initial = _decideOrNoUpdate(cached, version);

    // Background refresh: do not await; the notifier re-emits when done.
    // Wrap in microtask so the initial AsyncData lands first. Errors are
    // swallowed and logged here because callers ignore this future; an
    // uncaught throw would otherwise escape into the zone unobserved.
    Future.microtask(() => _safeRefresh(repo, version));

    return initial;
  }

  /// Forces a fresh fetch, regardless of cache age.
  ///
  /// Resolves normally even when the underlying refresh fails: the
  /// repository's fail-open contract keeps state unchanged, and errors
  /// are reported via the logger so fire-and-forget callers (lifecycle
  /// observer, retry button) cannot crash the zone.
  Future<void> refresh() async {
    final repo = ref.read(forceUpdateRepositoryProvider);
    final version = await ref.read(currentAppVersionProvider.future);
    await _safeRefresh(repo, version);
  }

  /// Re-fetches only when the cache is older than
  /// [forceUpdateRefreshInterval]. No-op if a fetch is already running.
  Future<void> refreshIfStale() async {
    final repo = ref.read(forceUpdateRepositoryProvider);
    final last = repo.lastFetchAt();
    if (last != null) {
      final age = DateTime.now().toUtc().difference(last);
      if (age < forceUpdateRefreshInterval) return;
    }
    await refresh();
  }

  Future<void> _safeRefresh(ForceUpdateRepository repo, Version version) async {
    if (_refreshInFlight) return;
    _refreshInFlight = true;
    try {
      final fresh = await repo.refresh();
      final next = _decideOrNoUpdate(fresh, version);
      // Only emit if the decision actually changed; avoids redundant
      // rebuilds while keeping the AsyncData path stable.
      final current = state.value;
      if (current == null || current != next) {
        _recordTransition(current, next);
        state = AsyncData(next);
      }
    } catch (e, stack) {
      // Fail-open: keep current state, surface the error to the logger
      // so transient remote failures do not vanish silently. Also send
      // a Sentry capture via the reporter seam so controller-level
      // refresh throws (a rare path the repo's fail-open hides) remain
      // visible in monitoring.
      ref
          .read(namedLoggerProvider('ForceUpdate'))
          .w('Force-update refresh failed', error: e, stackTrace: stack);
      await ref
          .read(forceUpdateReporterProvider)
          .captureException(
            e,
            stackTrace: stack,
            message: 'ForceUpdate refresh threw',
          );
    } finally {
      _refreshInFlight = false;
    }
  }

  /// Annotates each decision transition as a Sentry breadcrumb.
  ///
  /// Breadcrumbs are cheap and provide context if a later capture lands
  /// in the same session; they intentionally do not capture exceptions.
  void _recordTransition(UpdateDecision? from, UpdateDecision to) {
    final reporter = ref.read(forceUpdateReporterProvider);
    reporter.addBreadcrumb(
      message: 'decision ${_label(from)} -> ${_label(to)}',
      level: _severityFor(to),
      data: {'from': _label(from), 'to': _label(to)},
    );
  }

  String _label(UpdateDecision? decision) => switch (decision) {
    null => 'none',
    NoUpdate() => 'NoUpdate',
    SoftUpdate() => 'SoftUpdate',
    HardUpdate() => 'HardUpdate',
    Maintenance() => 'Maintenance',
  };

  ForceUpdateLogLevel _severityFor(UpdateDecision decision) =>
      switch (decision) {
        HardUpdate() || Maintenance() => ForceUpdateLogLevel.warning,
        _ => ForceUpdateLogLevel.info,
      };

  UpdateDecision _decideOrNoUpdate(ForceUpdateConfig? config, Version version) {
    if (config == null) return const NoUpdate();
    if (!configIsValid(config)) return const NoUpdate();
    return evaluate(config: config, currentVersion: version);
  }
}

/// Lightweight lifecycle hook used by the gate widget: wire
/// [WidgetsBindingObserver.didChangeAppLifecycleState] to call
/// [ForceUpdateController.refreshIfStale] on [AppLifecycleState.resumed].
///
/// Kept here (next to the controller) so the gate stays slim.
class ForceUpdateLifecycleObserver with WidgetsBindingObserver {
  ForceUpdateLifecycleObserver(this._onResumed);

  final Future<void> Function() _onResumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Fire and forget; the controller serializes its own work.
      _onResumed();
    }
  }
}
