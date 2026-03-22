import 'dart:convert';

import '../../subscription/repositories/subscription_repository.dart';
import 'share_link_builder.dart';

/// Builds universal link URLs for the audiflow.reedom.com domain.
///
/// Episode GUIDs are encoded as base64url without padding so the URL is
/// safe for all HTTP clients without additional percent-encoding.
class ShareLinkBuilderImpl implements ShareLinkBuilder {
  ShareLinkBuilderImpl({required SubscriptionRepository subscriptionRepository})
    : _subscriptionRepository = subscriptionRepository;

  final SubscriptionRepository _subscriptionRepository;

  static const _baseUrl = 'https://audiflow.reedom.com';

  @override
  Future<String?> buildPodcastLink({required int subscriptionId}) async {
    final subscription = await _subscriptionRepository.getById(subscriptionId);
    if (subscription == null) return null;
    return '$_baseUrl/p/${subscription.itunesId}';
  }

  @override
  Future<String?> buildEpisodeLink({
    required int subscriptionId,
    required String episodeGuid,
  }) async {
    final subscription = await _subscriptionRepository.getById(subscriptionId);
    if (subscription == null) return null;
    final encodedGuid = base64Url
        .encode(utf8.encode(episodeGuid))
        .replaceAll('=', '');
    return '$_baseUrl/p/${subscription.itunesId}/e/$encodedGuid';
  }
}
