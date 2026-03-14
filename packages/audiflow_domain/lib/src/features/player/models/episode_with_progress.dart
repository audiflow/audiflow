import 'package:freezed_annotation/freezed_annotation.dart';

import '../../feed/models/episode.dart';
import '../models/playback_history.dart';

part 'episode_with_progress.freezed.dart';

/// Episode combined with its playback progress.
///
/// Used for displaying episodes with progress indicators.
@freezed
sealed class EpisodeWithProgress with _$EpisodeWithProgress {
  const EpisodeWithProgress._();

  const factory EpisodeWithProgress({
    required Episode episode,
    PlaybackHistory? history,
  }) = _EpisodeWithProgress;

  /// Returns true if episode has been completed.
  bool get isCompleted => history?.completedAt != null;

  /// Returns true if episode is in progress (started but not completed).
  bool get isInProgress =>
      history != null &&
      0 < history!.positionMs &&
      history!.completedAt == null;

  /// Returns the progress percentage (0.0 to 1.0).
  double? get progressPercent {
    if (history == null) return null;
    final duration = history!.durationMs;
    if (duration == null || duration == 0) return null;
    return history!.positionMs / duration;
  }

  /// Returns the remaining duration in milliseconds.
  int? get remainingMs {
    if (history == null) return null;
    final duration = history!.durationMs;
    if (duration == null) return null;
    return duration - history!.positionMs;
  }

  /// Returns formatted remaining time (e.g., "18 min left").
  String? get remainingTimeFormatted {
    final remaining = remainingMs;
    if (remaining == null) return null;

    final minutes = (remaining / 60000).round();
    if (60 <= minutes) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return mins == 0 ? '$hours hr left' : '$hours hr $mins min left';
    }
    return '$minutes min left';
  }
}
