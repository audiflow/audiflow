import 'package:audiflow_domain/audiflow_domain.dart'
    show subscriptionByFeedUrlProvider, subscriptionRepositoryProvider;
import 'package:audiflow_search/audiflow_search.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../share/presentation/helpers/share_helper.dart';
import '../../../subscription/presentation/controllers/subscription_controller.dart';

/// Displays podcast artwork, metadata, and subscribe button.
class PodcastDetailHeader extends ConsumerWidget {
  const PodcastDetailHeader({super.key, required this.podcast});

  final Podcast podcast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _PodcastArtwork(artworkUrl: podcast.artworkUrl),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(child: _PodcastMetadata(podcast: podcast)),
            ],
          ),
          const SizedBox(height: Spacing.md),
          _SubscribeButtonRow(podcast: podcast),
          if (podcast.feedUrl != null)
            _AutoDownloadToggle(feedUrl: podcast.feedUrl!),
        ],
      ),
    );
  }
}

class _PodcastMetadata extends StatelessWidget {
  const _PodcastMetadata({required this.podcast});

  final Podcast podcast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          podcast.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          podcast.artistName,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (podcast.genres.isNotEmpty) ...[
          const SizedBox(height: Spacing.xs),
          Text(
            podcast.genres.join(', '),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _PodcastArtwork extends StatelessWidget {
  const _PodcastArtwork({this.artworkUrl});

  final String? artworkUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (artworkUrl == null) {
      return Container(
        width: 100,
        height: 100,
        alignment: Alignment.center,
        color: colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.podcasts,
          size: 48,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Image.network(
      artworkUrl!,
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: 100,
          height: 100,
          color: colorScheme.surfaceContainerHighest,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        width: 100,
        height: 100,
        alignment: Alignment.center,
        color: colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.broken_image,
          size: 48,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SubscribeButtonRow extends ConsumerWidget {
  const _SubscribeButtonRow({required this.podcast});

  final Podcast podcast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final subscriptionState = ref.watch(
      subscriptionControllerProvider(podcast.id),
    );

    return subscriptionState.when(
      data: (isSubscribed) {
        final l10n = AppLocalizations.of(context);
        if (isSubscribed) {
          final subscriptionId = podcast.feedUrl != null
              ? ref
                    .watch(subscriptionByFeedUrlProvider(podcast.feedUrl!))
                    .value
                    ?.id
              : null;
          return Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _toggleSubscription(ref),
                icon: const Icon(Icons.check),
                label: Text(l10n.podcastDetailSubscribed),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.primary),
                ),
              ),
              if (subscriptionId != null) ...[
                const SizedBox(width: Spacing.sm),
                IconButton(
                  onPressed: () =>
                      sharePodcast(ref: ref, subscriptionId: subscriptionId),
                  icon: const Icon(Icons.share_outlined),
                  tooltip: l10n.sharePodcast,
                ),
              ],
            ],
          );
        }

        return FilledButton.icon(
          onPressed: podcast.feedUrl != null
              ? () => _toggleSubscription(ref)
              : null,
          icon: const Icon(Icons.add),
          label: Text(l10n.podcastDetailSubscribe),
        );
      },
      loading: () => FilledButton.icon(
        onPressed: null,
        icon: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        label: Text(AppLocalizations.of(context).commonLoading),
      ),
      error: (error, stack) => FilledButton.icon(
        onPressed: () =>
            ref.invalidate(subscriptionControllerProvider(podcast.id)),
        icon: const Icon(Icons.refresh),
        label: Text(AppLocalizations.of(context).commonRetry),
      ),
    );
  }

  void _toggleSubscription(WidgetRef ref) {
    ref
        .read(subscriptionControllerProvider(podcast.id).notifier)
        .toggleSubscription(podcast);
  }
}

/// Shows an auto-download toggle for subscribed podcasts only.
class _AutoDownloadToggle extends ConsumerWidget {
  const _AutoDownloadToggle({required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(subscriptionByFeedUrlProvider(feedUrl));
    final subscription = subscriptionAsync.value;

    // Only show for real subscriptions (not cached/non-subscribed)
    if (subscription == null || subscription.isCached) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(l10n.podcastAutoDownloadTitle),
      subtitle: Text(l10n.podcastAutoDownloadSubtitle),
      value: subscription.autoDownload,
      onChanged: (value) async {
        await ref
            .read(subscriptionRepositoryProvider)
            .updateAutoDownload(subscription.id, autoDownload: value);
        ref.invalidate(subscriptionByFeedUrlProvider(feedUrl));
      },
    );
  }
}
