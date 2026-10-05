import '../../transcript/models/episode_chapter.dart';
import '../models/current_chapter.dart';
import 'sleep_timer_service.dart';

/// Turns current-chapter changes into the sleep timer's chapter events.
///
/// A chapter change counts as a natural crossing only when playback moves
/// forward into a later chapter of the same chapter list. Everything else
/// re-baselines silently: chapters loading or being replaced under the
/// listener, an episode switch, or an untagged backward jump.
///
/// Seeks are tagged by the player ([seekStarted] / [seekCompleted]) rather
/// than guessed from position jumps. A seek that leaves the baseline chapter
/// yields [SeekedPastChapterEvent] and moves the baseline to the target
/// chapter, which is how the end-of-chapter timer retargets.
///
/// Pure state machine: the caller supplies the clock.
class ChapterCrossingTracker {
  /// How long chapter changes after a seek starts are attributed to it.
  ///
  /// The player reports every committed seek, which ends the window first.
  /// The bound only matters when that report never comes (a failed seek),
  /// so a lost completion cannot suppress chapter crossings for good.
  /// Position updates read before the jump can arrive while a remote source
  /// buffers, which is why the window is several seconds rather than one
  /// tick.
  static const seekSettleWindow = Duration(seconds: 5);

  List<EpisodeChapter>? _chapters;
  int? _index;

  /// Settle deadline of each seek announced but not yet reported, by seek
  /// id. Each seek has its own window, so a late report for an expired
  /// seek cannot close a newer one.
  final Map<int, DateTime> _pendingSeeks = {};

  /// Feeds the current chapter list and the chapter at the position.
  ///
  /// [chapters] is compared by identity: the chapter provider emits a new
  /// list whenever the store changes, so a different list means the
  /// chapters loaded or changed rather than the position moving.
  SleepTimerPlayerEvent? observe({
    required List<EpisodeChapter>? chapters,
    required CurrentChapter? current,
    required DateTime now,
  }) {
    final index = current?.index;
    if (!identical(chapters, _chapters)) {
      _chapters = chapters;
      _index = index;
      return null;
    }
    if (index == _index) return null;
    // Positions read before or during the jump; the seek set the baseline.
    if (_isSettling(now)) return null;
    final previous = _index;
    _index = index;
    // A lead-in before the first chapter is not a chapter, so entering
    // chapter one from it is not the end of a chapter.
    if (previous == null || index == null) return null;
    return previous < index ? const ChapterChangedEvent() : null;
  }

  /// Marks a seek to [target] that is about to move the position.
  ///
  /// The window opens even when the target is in the baseline chapter: the
  /// live position can still differ from the baseline (a resume reads zero
  /// right after the source loads, while the baseline came from the saved
  /// position).
  SleepTimerPlayerEvent? seekStarted(
    int seekId,
    Duration target, {
    required DateTime now,
  }) {
    final chapters = _chapters;
    if (chapters == null || chapters.isEmpty) return null;
    _pendingSeeks[seekId] = now.add(seekSettleWindow);
    final targetIndex = chapterIndexAt(chapters, target);
    if (targetIndex == _index) return null;
    _index = targetIndex;
    return const SeekedPastChapterEvent();
  }

  /// Marks a seek as committed by the player; once no other seek is
  /// pending, later changes are playback.
  void seekCompleted(int seekId) => _pendingSeeks.remove(seekId);

  /// Marks a seek as rejected while the player stays at [position].
  ///
  /// The baseline moves to the chapter at [position] in the current list,
  /// not back to a saved index that a reloaded list or an overlapping seek
  /// may have made stale. A seek still pending already set the baseline to
  /// its own target, so it is left alone. The retarget already sent stays
  /// harmless: the timer still waits for the end of the playing chapter.
  void seekFailed(int seekId, Duration position, {required DateTime now}) {
    _pendingSeeks.remove(seekId);
    if (_isSettling(now)) return;
    final chapters = _chapters;
    if (chapters == null || chapters.isEmpty) return;
    _index = chapterIndexAt(chapters, position);
  }

  bool _isSettling(DateTime now) {
    // A lost report must not hold its window open past the bound.
    _pendingSeeks.removeWhere((_, until) => !now.isBefore(until));
    return _pendingSeeks.isNotEmpty;
  }
}
