import 'package:logger/logger.dart';

import '../../../common/datasources/shared_preferences_datasource.dart';
import '../models/review_prompt_stats.dart';
import 'review_prompt_repository.dart';

/// SharedPreferences-backed [ReviewPromptRepository].
///
/// Writes hit disk first; the in-memory snapshot is updated only on
/// success, so a failed write never causes memory and disk to diverge.
/// All write failures are logged via the injected [Logger] (best-effort
/// per-key); no exception propagates to the caller, because the
/// review-prompt feature is peripheral and must not corrupt the
/// playback critical path.
class ReviewPromptRepositoryImpl implements ReviewPromptRepository {
  ReviewPromptRepositoryImpl(
    this._prefs, {
    this._logger,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    _snapshot = _safeLoad();
  }

  final SharedPreferencesDataSource _prefs;
  final Logger? _logger;
  final DateTime Function() _clock;
  late ReviewPromptStats _snapshot;

  static const _totalListenedKey = 'review_prompt.total_listened_ms';
  static const _thresholdKey = 'review_prompt.next_threshold_ms';
  static const _statusKey = 'review_prompt.status';
  static const _lastPromptedAtKey = 'review_prompt.last_prompted_at';

  ReviewPromptStats _safeLoad() {
    try {
      return _load();
    } catch (e, st) {
      _logger?.w(
        '[ReviewPromptRepository] Failed to load; using defaults.',
        error: e,
        stackTrace: st,
      );
      return const ReviewPromptStats();
    }
  }

  ReviewPromptStats _load() {
    final totalMs = _prefs.getInt(_totalListenedKey) ?? 0;
    final thresholdMs =
        _prefs.getInt(_thresholdKey) ??
        reviewPromptInitialThreshold.inMilliseconds;
    final statusStr = _prefs.getString(_statusKey);
    final lastPromptedMs = _prefs.getInt(_lastPromptedAtKey);

    final status = _parseStatus(statusStr);
    final clampedTotal = totalMs < 0 ? 0 : totalMs;
    final clampedThreshold = thresholdMs <= 0
        ? reviewPromptInitialThreshold.inMilliseconds
        : thresholdMs;

    return ReviewPromptStats(
      totalListened: Duration(milliseconds: clampedTotal),
      nextPromptThreshold: Duration(milliseconds: clampedThreshold),
      status: status,
      lastPromptedAt: lastPromptedMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastPromptedMs),
    );
  }

  ReviewPromptStatus _parseStatus(String? raw) {
    switch (raw) {
      case 'optedOut':
        return ReviewPromptStatus.optedOut;
      case 'rated':
        return ReviewPromptStatus.rated;
      default:
        return ReviewPromptStatus.accumulating;
    }
  }

  String _statusToString(ReviewPromptStatus status) {
    switch (status) {
      case ReviewPromptStatus.accumulating:
        return 'accumulating';
      case ReviewPromptStatus.optedOut:
        return 'optedOut';
      case ReviewPromptStatus.rated:
        return 'rated';
    }
  }

  @override
  ReviewPromptStats getStats() => _snapshot;

  @override
  Future<void> addListened(Duration delta) async {
    if (delta.inMilliseconds <= 0) return;
    final next = _snapshot.totalListened + delta;
    final ok = await _safeWriteInt(_totalListenedKey, next.inMilliseconds);
    if (ok) {
      _snapshot = _snapshot.copyWith(totalListened: next);
    }
  }

  @override
  Future<void> recordPromptShown() async {
    if (_snapshot.status != ReviewPromptStatus.accumulating) return;
    final newThreshold = _snapshot.nextPromptThreshold + reviewPromptInterval;
    final shownAt = _clock();
    final okThreshold = await _safeWriteInt(
      _thresholdKey,
      newThreshold.inMilliseconds,
    );
    final okTimestamp = await _safeWriteInt(
      _lastPromptedAtKey,
      shownAt.millisecondsSinceEpoch,
    );
    if (okThreshold && okTimestamp) {
      _snapshot = _snapshot.copyWith(
        nextPromptThreshold: newThreshold,
        lastPromptedAt: shownAt,
      );
    }
  }

  @override
  Future<void> markOptedOut() => _transitionTo(ReviewPromptStatus.optedOut);

  @override
  Future<void> markRated() => _transitionTo(ReviewPromptStatus.rated);

  Future<void> _transitionTo(ReviewPromptStatus status) async {
    final ok = await _safeWriteString(_statusKey, _statusToString(status));
    if (ok) {
      _snapshot = _snapshot.copyWith(status: status);
    }
  }

  @override
  Future<void> reset() async {
    final ok = await _safeRemoveAll([
      _totalListenedKey,
      _thresholdKey,
      _statusKey,
      _lastPromptedAtKey,
    ]);
    if (ok) {
      _snapshot = const ReviewPromptStats();
    }
  }

  Future<bool> _safeWriteInt(String key, int value) async {
    try {
      await _prefs.setInt(key, value);
      return true;
    } catch (e, st) {
      _logger?.w(
        '[ReviewPromptRepository] setInt($key) failed.',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  Future<bool> _safeWriteString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
      return true;
    } catch (e, st) {
      _logger?.w(
        '[ReviewPromptRepository] setString($key) failed.',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  Future<bool> _safeRemoveAll(List<String> keys) async {
    try {
      for (final key in keys) {
        await _prefs.remove(key);
      }
      return true;
    } catch (e, st) {
      _logger?.w(
        '[ReviewPromptRepository] remove failed.',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }
}
