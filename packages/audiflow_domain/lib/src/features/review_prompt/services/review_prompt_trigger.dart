import 'dart:async';

import 'package:logger/logger.dart';

import '../repositories/review_prompt_repository.dart';
import 'review_prompt_evaluator.dart';

/// Schedules a one-shot check after [delay] each time playback begins.
///
/// Pause or stop cancels the pending check. When the check fires and
/// the evaluator returns true an event is pushed onto [events]; the
/// presentation layer decides whether to actually surface the dialog.
class ReviewPromptTrigger {
  ReviewPromptTrigger({
    required this._repository,
    this._logger,
    this._delay = const Duration(seconds: 2),
  });

  final ReviewPromptRepository _repository;
  final Logger? _logger;
  final Duration _delay;
  final StreamController<void> _controller = StreamController<void>.broadcast();

  Timer? _timer;
  bool _disposed = false;

  Stream<void> get events => _controller.stream;

  void armForPlayback() {
    if (_disposed) return;
    _timer?.cancel();
    _timer = Timer(_delay, _onElapsed);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void _onElapsed() {
    _timer = null;
    if (_disposed || _controller.isClosed) return;
    try {
      final stats = _repository.getStats();
      if (shouldShowReviewPrompt(stats)) {
        _controller.add(null);
      }
    } catch (e, st) {
      _logger?.w(
        '[ReviewPromptTrigger] elapsed check failed.',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    if (!_controller.isClosed) {
      await _controller.close();
    }
  }
}
