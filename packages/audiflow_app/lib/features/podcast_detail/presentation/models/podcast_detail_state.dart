import 'package:audiflow_domain/audiflow_domain.dart';

/// State for the podcast detail screen.
///
/// Contains the parsed feed data and refresh progress information.
class PodcastDetailState {
  const PodcastDetailState.loaded({
    required this.feed,
    this.isRefreshing = false,
    this.refreshProgress,
    this.refreshError,
  });

  /// The parsed podcast feed data.
  final ParsedFeed feed;

  /// Whether a background refresh is in progress.
  final bool isRefreshing;

  /// Number of episodes parsed so far during refresh.
  final int? refreshProgress;

  /// Error message if refresh failed.
  final String? refreshError;

  /// Creates a copy with updated fields.
  PodcastDetailState copyWith({
    ParsedFeed? feed,
    bool? isRefreshing,
    int? refreshProgress,
    String? refreshError,
  }) {
    return PodcastDetailState.loaded(
      feed: feed ?? this.feed,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      refreshProgress: refreshProgress,
      refreshError: refreshError,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PodcastDetailState &&
          runtimeType == other.runtimeType &&
          feed == other.feed &&
          isRefreshing == other.isRefreshing &&
          refreshProgress == other.refreshProgress &&
          refreshError == other.refreshError;

  @override
  int get hashCode =>
      feed.hashCode ^
      isRefreshing.hashCode ^
      refreshProgress.hashCode ^
      refreshError.hashCode;
}
