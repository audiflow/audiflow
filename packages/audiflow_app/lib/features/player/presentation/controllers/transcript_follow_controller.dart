import 'dart:async';

import 'package:flutter/foundation.dart';

/// Tracks whether the transcript view should auto-follow playback.
///
/// A user drag stops following. Once the user has stopped scrolling for
/// [resumeDelay], following resumes and [onAutoResume] fires so the view
/// can scroll back to the active segment. Programmatic scrolls must not be
/// reported here, otherwise the view's own auto-scroll would cancel itself.
class TranscriptFollowController extends ChangeNotifier {
  TranscriptFollowController({
    required this.onAutoResume,
    this.resumeDelay = const Duration(seconds: 5),
  });

  final Duration resumeDelay;
  final VoidCallback onAutoResume;

  Timer? _resumeTimer;
  bool _isFollowing = true;

  bool get isFollowing => _isFollowing;

  /// Called when the user starts dragging the list.
  void handleUserScrollStart() {
    _resumeTimer?.cancel();
    _resumeTimer = null;
    _setFollowing(false);
  }

  /// Called when any scroll settles; arms the resume countdown only when
  /// following was interrupted by the user.
  void handleScrollEnd() {
    if (_isFollowing) return;
    _resumeTimer?.cancel();
    _resumeTimer = Timer(resumeDelay, _autoResume);
  }

  /// Resumes following immediately, e.g. from the jump-to-current button.
  void resumeNow() {
    _resumeTimer?.cancel();
    _resumeTimer = null;
    _setFollowing(true);
  }

  void _autoResume() {
    _resumeTimer = null;
    _setFollowing(true);
    onAutoResume();
  }

  void _setFollowing(bool value) {
    if (_isFollowing == value) return;
    _isFollowing = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _resumeTimer?.cancel();
    _resumeTimer = null;
    super.dispose();
  }
}
