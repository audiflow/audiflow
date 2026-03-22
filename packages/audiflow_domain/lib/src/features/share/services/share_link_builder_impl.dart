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
  }) async {
    final encodedGuid = base64Url
        .encode(utf8.encode(episodeGuid))
        .replaceAll('=', '');
    return '$_baseUrl/p/$itunesId/e/$encodedGuid';
  }
}
