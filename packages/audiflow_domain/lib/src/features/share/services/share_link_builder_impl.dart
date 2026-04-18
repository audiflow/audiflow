import 'dart:convert';

import 'share_link_builder.dart';

/// Builds universal link URLs for the audiflow.reedom.com domain.
///
/// Episode GUIDs are encoded as base64url without padding so the URL is
/// safe for all HTTP clients without additional percent-encoding.
class ShareLinkBuilderImpl implements ShareLinkBuilder {
  static const _baseUrl = 'https://audiflow.reedom.com';

  @override
  Future<String?> buildPodcastLink({required String itunesId}) async {
    return '$_baseUrl/p/$itunesId';
  }

  @override
  Future<String?> buildEpisodeLink({
    required String itunesId,
    required String episodeGuid,
    Duration? startAt,
  }) async {
    final encodedGuid = base64Url
        .encode(utf8.encode(episodeGuid))
        .replaceAll('=', '');
    final base = '$_baseUrl/p/$itunesId/e/$encodedGuid';
    final seconds = startAt?.inSeconds ?? 0;
    if (seconds <= 0) return base;
    return '$base?t=$seconds';
  }
}
