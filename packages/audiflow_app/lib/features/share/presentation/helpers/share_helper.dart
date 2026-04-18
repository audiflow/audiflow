import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

Future<String?> buildEpisodeShareUrl({
  required ShareLinkBuilder shareLinkBuilder,
  required String? itunesId,
  required String? episodeGuid,
  required String? fallbackLink,
  Duration? startAt,
}) async {
  if (itunesId != null && episodeGuid != null) {
    final url = await shareLinkBuilder.buildEpisodeLink(
      itunesId: itunesId,
      episodeGuid: episodeGuid,
      startAt: startAt,
    );
    if (url != null) return url;
  }
  return fallbackLink;
}

Rect? _shareOriginFrom(BuildContext context) {
  final renderObject = context.findRenderObject();
  if (renderObject is! RenderBox) return null;
  final origin = renderObject.localToGlobal(Offset.zero);
  return origin & renderObject.size;
}

Future<void> shareEpisode({
  required BuildContext context,
  required WidgetRef ref,
  required String? itunesId,
  required String? episodeGuid,
  required String? fallbackLink,
  Duration? startAt,
}) async {
  final origin = _shareOriginFrom(context);
  final url = await buildEpisodeShareUrl(
    shareLinkBuilder: ref.read(shareLinkBuilderProvider),
    itunesId: itunesId,
    episodeGuid: episodeGuid,
    fallbackLink: fallbackLink,
    startAt: startAt,
  );
  if (url == null) return;
  await SharePlus.instance.share(
    ShareParams(uri: Uri.parse(url), sharePositionOrigin: origin),
  );
}

Future<void> sharePodcast({
  required BuildContext context,
  required WidgetRef ref,
  required String? itunesId,
}) async {
  if (itunesId == null) return;
  final origin = _shareOriginFrom(context);
  final url = await ref
      .read(shareLinkBuilderProvider)
      .buildPodcastLink(itunesId: itunesId);
  if (url == null) return;
  await SharePlus.instance.share(
    ShareParams(uri: Uri.parse(url), sharePositionOrigin: origin),
  );
}
