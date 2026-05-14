import '../../../common/datasources/shared_preferences_datasource.dart';
import '../models/review_prompt_stats.dart';
import 'review_prompt_repository.dart';

/// SharedPreferences-backed implementation of [ReviewPromptRepository].
///
/// Keeps the live snapshot in memory so reads stay synchronous, and
/// persists each mutation to disk.
class ReviewPromptRepositoryImpl implements ReviewPromptRepository {
  ReviewPromptRepositoryImpl(this._prefs) {
    _snapshot = _load();
  }

  final SharedPreferencesDataSource _prefs;
  late ReviewPromptStats _snapshot;

  static const _totalListenedKey = 'review_prompt.total_listened_ms';
  static const _thresholdKey = 'review_prompt.next_threshold_ms';
  static const _optedOutKey = 'review_prompt.user_opted_out';
  static const _ratedKey = 'review_prompt.user_tapped_rate_now';
  static const _lastPromptedAtKey = 'review_prompt.last_prompted_at';

  ReviewPromptStats _load() {
    final lastPromptedMs = _prefs.getInt(_lastPromptedAtKey);
    return ReviewPromptStats(
      totalListenedMs: _prefs.getInt(_totalListenedKey) ?? 0,
      nextPromptThresholdMs:
          _prefs.getInt(_thresholdKey) ?? ReviewPromptStats.initialThresholdMs,
      userOptedOut: _prefs.getBool(_optedOutKey) ?? false,
      userTappedRateNow: _prefs.getBool(_ratedKey) ?? false,
      lastPromptedAt: lastPromptedMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastPromptedMs),
    );
  }

  @override
  ReviewPromptStats getStats() => _snapshot;

  @override
  Future<void> addListenedMs(int deltaMs) async {
    if (deltaMs <= 0) return;
    final next = _snapshot.totalListenedMs + deltaMs;
    _snapshot = _snapshot.copyWith(totalListenedMs: next);
    await _prefs.setInt(_totalListenedKey, next);
  }

  @override
  Future<void> recordPromptShown(DateTime shownAt) async {
    final newThreshold =
        _snapshot.nextPromptThresholdMs + ReviewPromptStats.promptIntervalMs;
    _snapshot = _snapshot.copyWith(
      nextPromptThresholdMs: newThreshold,
      lastPromptedAt: shownAt,
    );
    await _prefs.setInt(_thresholdKey, newThreshold);
    await _prefs.setInt(_lastPromptedAtKey, shownAt.millisecondsSinceEpoch);
  }

  @override
  Future<void> markOptedOut() async {
    _snapshot = _snapshot.copyWith(userOptedOut: true);
    await _prefs.setBool(_optedOutKey, true);
  }

  @override
  Future<void> markUserRated() async {
    _snapshot = _snapshot.copyWith(userTappedRateNow: true);
    await _prefs.setBool(_ratedKey, true);
  }

  @override
  Future<void> reset() async {
    _snapshot = const ReviewPromptStats();
    await _prefs.remove(_totalListenedKey);
    await _prefs.remove(_thresholdKey);
    await _prefs.remove(_optedOutKey);
    await _prefs.remove(_ratedKey);
    await _prefs.remove(_lastPromptedAtKey);
  }
}
