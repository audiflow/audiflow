/// Why a feed link could not be opened, chosen for what the user can do.
enum FeedLinkFailure {
  /// The link names a service whose links carry no RSS feed.
  unsupportedLink,

  /// The podcast directory has no feed for the linked podcast.
  notFound,

  /// The device could not reach the server.
  network,

  /// The server answered with a client error (moved, removed, private).
  feedUnavailable,

  /// The server answered with a server error; retrying later may help.
  serverError,

  /// The URL answered, but not with a podcast RSS feed.
  notPodcastFeed,
}

/// Thrown when a feed link cannot be resolved to a podcast.
class FeedLinkException implements Exception {
  const FeedLinkException(this.failure, {this.platformName, this.cause});

  final FeedLinkFailure failure;

  /// The service named by an [FeedLinkFailure.unsupportedLink] link.
  final String? platformName;

  /// The underlying error, if any; kept for diagnostics only.
  final Object? cause;

  @override
  String toString() => 'FeedLinkException($failure, cause: $cause)';
}
