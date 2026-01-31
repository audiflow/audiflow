/// Result of syncing all subscribed podcast feeds.
class FeedSyncResult {
  const FeedSyncResult({
    required this.totalCount,
    required this.successCount,
    required this.skipCount,
    required this.errorCount,
  });

  final int totalCount;
  final int successCount;
  final int skipCount;
  final int errorCount;

  @override
  String toString() =>
      'FeedSyncResult(total: $totalCount, success: $successCount, '
      'skip: $skipCount, error: $errorCount)';
}

/// Result of syncing a single podcast feed.
class SingleFeedSyncResult {
  const SingleFeedSyncResult({
    required this.podcastId,
    required this.success,
    required this.skipped,
    this.newEpisodeCount,
    this.errorMessage,
  });

  final int podcastId;
  final bool success;
  final bool skipped;
  final int? newEpisodeCount;
  final String? errorMessage;

  @override
  String toString() =>
      'SingleFeedSyncResult(podcastId: $podcastId, '
      'success: $success, skipped: $skipped, '
      'newEpisodes: $newEpisodeCount)';
}
