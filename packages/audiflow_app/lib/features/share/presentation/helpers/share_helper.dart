import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

Future<String?> buildEpisodeShareUrl({
  required ShareLinkBuilder shareLinkBuilder,
  required String? itunesId,
  required String? episodeGuid,
  required String? fallbackLink,
}) async {
  if (itunesId != null && episodeGuid != null) {
    final url = await shareLinkBuilder.buildEpisodeLink(
      itunesId: itunesId,
      episodeGuid: episodeGuid,
    );
    if (url != null) return url;
  }
  return fallbackLink;
}

Future<void> shareEpisode({
  required WidgetRef ref,
  required String? itunesId,
  required String? episodeGuid,
  required String? fallbackLink,
}) async {
  final url = await buildEpisodeShareUrl(
    shareLinkBuilder: ref.read(shareLinkBuilderProvider),
    itunesId: itunesId,
    episodeGuid: episodeGuid,
    fallbackLink: fallbackLink,
  );
  if (url == null) return;
  await SharePlus.instance.share(ShareParams(uri: Uri.parse(url)));
}

Future<void> sharePodcast({
  required WidgetRef ref,
  required String? itunesId,
}) async {
  if (itunesId == null) return;
  final url = await ref
      .read(shareLinkBuilderProvider)
      .buildPodcastLink(itunesId: itunesId);
  if (url == null) return;
  await SharePlus.instance.share(ShareParams(uri: Uri.parse(url)));
}
