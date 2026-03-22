import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

Future<String?> buildEpisodeShareUrl({
  required ShareLinkBuilder shareLinkBuilder,
  required int? subscriptionId,
  required String? episodeGuid,
  required String? fallbackLink,
}) async {
  if (subscriptionId != null && episodeGuid != null) {
    final url = await shareLinkBuilder.buildEpisodeLink(
      subscriptionId: subscriptionId,
      episodeGuid: episodeGuid,
    );
    if (url != null) return url;
  }
  return fallbackLink;
}

Future<void> shareEpisode({
  required WidgetRef ref,
  required int? subscriptionId,
  required String? episodeGuid,
  required String? fallbackLink,
}) async {
  final url = await buildEpisodeShareUrl(
    shareLinkBuilder: ref.read(shareLinkBuilderProvider),
    subscriptionId: subscriptionId,
    episodeGuid: episodeGuid,
    fallbackLink: fallbackLink,
  );
  if (url == null) return;
  await SharePlus.instance.share(ShareParams(uri: Uri.parse(url)));
}

Future<void> sharePodcast({
  required WidgetRef ref,
  required int? subscriptionId,
}) async {
  if (subscriptionId == null) return;
  final url = await ref
      .read(shareLinkBuilderProvider)
      .buildPodcastLink(subscriptionId: subscriptionId);
  if (url == null) return;
  await SharePlus.instance.share(ShareParams(uri: Uri.parse(url)));
}
