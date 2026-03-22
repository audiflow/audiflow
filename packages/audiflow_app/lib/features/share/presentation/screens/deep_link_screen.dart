import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';

class DeepLinkScreen extends ConsumerStatefulWidget {
  const DeepLinkScreen({super.key, required this.uri});

  final Uri uri;

  @override
  ConsumerState<DeepLinkScreen> createState() => _DeepLinkScreenState();
}

class _DeepLinkScreenState extends ConsumerState<DeepLinkScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
  }

  Future<void> _resolve() async {
    final l10n = AppLocalizations.of(context);
    try {
      final target = await ref
          .read(deepLinkResolverProvider)
          .resolve(widget.uri);
      if (!mounted) return;

      if (target == null) {
        _showErrorAndGoHome(l10n.deepLinkPodcastNotFound);
        return;
      }

      switch (target) {
        case PodcastDeepLinkTarget(
          :final itunesId,
          :final feedUrl,
          :final title,
          :final artworkUrl,
        ):
          final podcast = Podcast(
            id: itunesId,
            name: title,
            artistName: '',
            feedUrl: feedUrl,
            artworkUrl: artworkUrl,
          );
          context.go('${AppRoutes.search}/podcast/$itunesId', extra: podcast);
          return;

        case EpisodeDeepLinkTarget(
          :final episode,
          :final feedUrl,
          :final podcastTitle,
          :final artworkUrl,
          :final progress,
        ):
          context.go(
            '${AppRoutes.search}/podcast/${target.itunesId}',
            extra: Podcast(
              id: target.itunesId,
              name: podcastTitle,
              artistName: '',
              feedUrl: feedUrl,
              artworkUrl: artworkUrl,
            ),
          );
          context.push(
            '${AppRoutes.search}/podcast/${target.itunesId}/${AppRoutes.episodeDetail}'
                .replaceAll(
                  ':episodeGuid',
                  Uri.encodeComponent(episode.guid ?? ''),
                ),
            extra: <String, dynamic>{
              'episode': episode,
              'podcastTitle': podcastTitle,
              'artworkUrl': artworkUrl,
              'itunesId': target.itunesId,
              'progress': progress,
            },
          );
          return;
      }
    } on Exception catch (_) {
      if (!mounted) return;
      _showErrorAndGoHome(l10n.deepLinkNetworkError);
    }
  }

  void _showErrorAndGoHome(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    context.go(AppRoutes.search);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: Spacing.md),
            Text(l10n.deepLinkLoading),
          ],
        ),
      ),
    );
  }
}
