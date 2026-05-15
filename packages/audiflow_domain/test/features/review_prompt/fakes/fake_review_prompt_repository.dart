import 'package:audiflow_domain/audiflow_domain.dart';

/// In-memory fake for [ReviewPromptRepository]. Records mutation counts
/// so tests can assert what was called.
class FakeReviewPromptRepository implements ReviewPromptRepository {
  FakeReviewPromptRepository({
    ReviewPromptStats initial = const ReviewPromptStats(),
    DateTime Function()? clock,
  }) : _stats = initial,
       _clock = clock ?? (() => DateTime.utc(2026, 5, 15));

  ReviewPromptStats _stats;
  final DateTime Function() _clock;

  int addListenedCalls = 0;
  int recordPromptShownCalls = 0;
  int markOptedOutCalls = 0;
  int markRatedCalls = 0;
  int resetCalls = 0;

  @override
  ReviewPromptStats getStats() => _stats;

  @override
  Future<void> addListened(Duration delta) async {
    addListenedCalls++;
    if (delta.inMilliseconds <= 0) return;
    _stats = _stats.copyWith(totalListened: _stats.totalListened + delta);
  }

  @override
  Future<void> recordPromptShown() async {
    recordPromptShownCalls++;
    if (_stats.status != ReviewPromptStatus.accumulating) return;
    _stats = _stats.copyWith(
      nextPromptThreshold: _stats.nextPromptThreshold + reviewPromptInterval,
      lastPromptedAt: _clock(),
    );
  }

  @override
  Future<void> markOptedOut() async {
    markOptedOutCalls++;
    _stats = _stats.copyWith(status: ReviewPromptStatus.optedOut);
  }

  @override
  Future<void> markRated() async {
    markRatedCalls++;
    _stats = _stats.copyWith(status: ReviewPromptStatus.rated);
  }

  @override
  Future<void> reset() async {
    resetCalls++;
    _stats = const ReviewPromptStats();
  }
}
