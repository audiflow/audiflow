/// Builds universal link URLs for sharing podcasts and episodes.
abstract class ShareLinkBuilder {
  /// Returns a shareable URL for the podcast identified by [itunesId].
  Future<String?> buildPodcastLink({required String itunesId});

  /// Returns a shareable URL for an episode identified by [itunesId]
  /// and [episodeGuid].
  ///
  /// When [startAt] is non-null and strictly positive, the URL includes
  /// a `?t=<seconds>` query parameter so receivers can seek on open.
  Future<String?> buildEpisodeLink({
    required String itunesId,
    required String episodeGuid,
    Duration? startAt,
  });
}
