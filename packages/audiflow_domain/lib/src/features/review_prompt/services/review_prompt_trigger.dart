import 'dart:async';

import '../repositories/review_prompt_repository.dart';
import 'review_prompt_evaluator.dart';

/// Orchestrates the "show prompt 2 seconds after playback start" rule.
///
/// Each call to [armForPlayback] starts a fresh timer; the previous one
/// is cancelled. If the user pauses or stops before the timer fires we
/// call [cancel] to avoid bothering them.
///
/// When the timer fires and the evaluator returns true, an event is
/// pushed onto [events]. The presentation layer subscribes to this
/// stream and decides whether the app is currently in the foreground.
class ReviewPromptTrigger {
  ReviewPromptTrigger({
    required ReviewPromptRepository repository,
    Duration delay = const Duration(seconds: 2),
  }) : _repository = repository,
       _delay = delay;

  final ReviewPromptRepository _repository;
  final Duration _delay;
  final StreamController<void> _controller = StreamController<void>.broadcast();

  Timer? _timer;

  /// Emits each time the trigger conditions are met after a playback
  /// session has been running for [_delay].
  Stream<void> get events => _controller.stream;

  /// Called when a new episode begins playing. Re-arms the timer.
  void armForPlayback() {
    _timer?.cancel();
    _timer = Timer(_delay, _onElapsed);
  }

  /// Cancels any pending trigger. Call this on pause/stop so we don't
  /// surprise the user mid-action.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void _onElapsed() {
    _timer = null;
    final stats = _repository.getStats();
    if (shouldShowReviewPrompt(stats)) {
      _controller.add(null);
    }
  }

  /// Releases the broadcast stream. Tests should call this in tearDown.
  Future<void> dispose() async {
    _timer?.cancel();
    await _controller.close();
  }
}
