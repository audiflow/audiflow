/// Builds universal link URLs for sharing podcasts and episodes.
abstract class ShareLinkBuilder {
  /// Returns a shareable URL for the podcast identified by [subscriptionId].
  ///
  /// Returns null if the subscription does not exist.
  Future<String?> buildPodcastLink({required int subscriptionId});

  /// Returns a shareable URL for an episode identified by [subscriptionId]
  /// and [episodeGuid].
  ///
  /// Returns null if the subscription does not exist.
  Future<String?> buildEpisodeLink({
    required int subscriptionId,
    required String episodeGuid,
  });
}
