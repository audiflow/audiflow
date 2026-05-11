import 'package:audiflow_domain/audiflow_domain.dart'
    show subscriptionByFeedUrlProvider, subscriptionRepositoryProvider;
import 'package:audiflow_search/audiflow_search.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';

Future<void> showPodcastSettingsSheet({
  required BuildContext context,
  required Podcast podcast,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    builder: (sheetContext) => _PodcastSettingsSheet(podcast: podcast),
  );
}

class _PodcastSettingsSheet extends ConsumerWidget {
  const _PodcastSettingsSheet({required this.podcast});

  final Podcast podcast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final feedUrl = podcast.feedUrl;

    return FractionallySizedBox(
      heightFactor: 1,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            podcast.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            children: [
              if (feedUrl != null) _AutoDownloadTile(feedUrl: feedUrl),
            ],
          ),
        ),
      ),
    );
  }
}

class _AutoDownloadTile extends ConsumerWidget {
  const _AutoDownloadTile({required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(subscriptionByFeedUrlProvider(feedUrl));
    final subscription = subscriptionAsync.value;

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
