import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../../../parental_control/domain/gate_guard.dart';
import '../../../parental_control/providers/gate_guard_provider.dart';

class DeepLinkScreen extends ConsumerStatefulWidget {
  const DeepLinkScreen({super.key, required this.uri});

  final Uri uri;

  @override
  ConsumerState<DeepLinkScreen> createState() => _DeepLinkScreenState();
}

class _DeepLinkScreenState extends ConsumerState<DeepLinkScreen> {
  // The resolver only accepts fully qualified audiflow.reedom.com URLs.
  // In-app navigation via GoRouter.push produces a relative `state.uri`
  // with no scheme/host, so normalize it before handing it to the
  // resolver. External universal links already carry scheme + host.
  static const _canonicalScheme = 'https';
  static const _canonicalHost = 'audiflow.reedom.com';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
  }

  Uri _canonicalizedUri() {
    final uri = widget.uri;
    if (uri.hasScheme && uri.host.isNotEmpty) return uri;
    return uri.replace(scheme: _canonicalScheme, host: _canonicalHost);
  }

  Future<void> _resolve() async {
    final l10n = AppLocalizations.of(context);
    try {
      final target = await ref
          .read(deepLinkResolverProvider)
          .resolve(_canonicalizedUri());
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
          // Gate deep-link navigation to non-subscribed podcasts when
          // Restricted Mode is on and the gate is locked.
          final isSubscribed = await ref
              .read(subscriptionRepositoryProvider)
              .isSubscribed(itunesId);
          if (!mounted) return;
          if (!isSubscribed) {
            final allowed = await ref
                .read(gateGuardProvider)
                .requireUnlock(context, reason: GateReason.deepLink);
            if (!mounted) return;
            if (!allowed) {
              context.go(AppRoutes.library);
              return;
            }
          }
          final podcast = Podcast(
            id: itunesId,
            name: title,
            artistName: '',
            feedUrl: feedUrl,
            artworkUrl: artworkUrl,
          );
          // Pass `subscribeSource` via the extra map so the subscribe
          // button on the detail screen reports `deeplink` despite the
          // route prefix being `/search/...`.
          context.go(
            '${AppRoutes.search}/podcast/$itunesId',
            extra: <String, dynamic>{
              'podcast': podcast,
              'subscribeSource': SubscribeSource.deeplink,
            },
          );
          return;

        case EpisodeDeepLinkTarget(
          :final episode,
          :final feedUrl,
          :final podcastTitle,
          :final artworkUrl,
          :final progress,
          :final startAt,
        ):
          // Gate deep-link navigation to non-subscribed podcasts.
          final isSubscribed = await ref
              .read(subscriptionRepositoryProvider)
              .isSubscribed(target.itunesId);
          if (!mounted) return;
          if (!isSubscribed) {
            final allowed = await ref
                .read(gateGuardProvider)
                .requireUnlock(context, reason: GateReason.deepLink);
            if (!mounted) return;
            if (!allowed) {
              context.go(AppRoutes.library);
              return;
            }
          }
          final router = GoRouter.of(context);
          final podcast = Podcast(
            id: target.itunesId,
            name: podcastTitle,
            artistName: '',
            feedUrl: feedUrl,
            artworkUrl: artworkUrl,
          );
          router.go(
            '${AppRoutes.search}/podcast/${target.itunesId}',
            extra: podcast,
          );
          final episodePath =
              '${AppRoutes.search}/podcast/${target.itunesId}/${AppRoutes.episodeDetail}'
                  .replaceAll(
                    ':episodeGuid',
                    Uri.encodeComponent(episode.guid ?? ''),
                  );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            router.push(
              episodePath,
              extra: <String, dynamic>{
                'episode': episode,
                'podcastTitle': podcastTitle,
                'artworkUrl': artworkUrl,
                'itunesId': target.itunesId,
                'progress': progress,
                'startAt': startAt,
              },
            );
          });
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
