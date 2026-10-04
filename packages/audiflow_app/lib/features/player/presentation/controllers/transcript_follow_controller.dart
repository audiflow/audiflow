import 'dart:async';

import 'package:flutter/foundation.dart';

/// Tracks whether the transcript view should auto-follow playback.
///
/// A user drag stops following. Once the user has stopped scrolling and
/// lifted every finger for [resumeDelay], following resumes and
/// [onAutoResume] fires so the view can scroll back to the active segment.
/// Programmatic scrolls must not be reported here, otherwise the view's own
/// auto-scroll would cancel itself.
class TranscriptFollowController extends ChangeNotifier {
  TranscriptFollowController({
    required this.onAutoResume,
    this.resumeDelay = const Duration(seconds: 5),
  });

  final Duration resumeDelay;
  final VoidCallback onAutoResume;

  Timer? _resumeTimer;
  bool _isFollowing = true;
  int _pointersDown = 0;

  bool get isFollowing => _isFollowing;

  /// Called when the user starts dragging the list.
  void handleUserScrollStart() {
    _cancelTimer();
    _setFollowing(false);
  }

  /// Called when any scroll settles.
  void handleScrollEnd() => _armTimerIfIdle();

  /// Called when a finger touches the list. A resting finger (e.g. one
  /// that stopped a fling) means the user is still reading, so the
  /// countdown is held until it lifts.
  void handlePointerDown() {
    _pointersDown++;
    _cancelTimer();
  }

  /// Called when a finger lifts from or is cancelled on the list.
  void handlePointerUp() {
    if (0 < _pointersDown) _pointersDown--;
    _armTimerIfIdle();
  }

  /// Resumes following immediately, e.g. from the jump-to-current button.
  void resumeNow() {
    _cancelTimer();
    _setFollowing(true);
  }

  void _armTimerIfIdle() {
    if (_isFollowing || 0 < _pointersDown) return;
    _cancelTimer();
    _resumeTimer = Timer(resumeDelay, _autoResume);
  }

  void _autoResume() {
    _resumeTimer = null;
    _setFollowing(true);
    onAutoResume();
  }

  void _cancelTimer() {
    _resumeTimer?.cancel();
    _resumeTimer = null;
  }

  void _setFollowing(bool value) {
    if (_isFollowing == value) return;
    _isFollowing = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}
