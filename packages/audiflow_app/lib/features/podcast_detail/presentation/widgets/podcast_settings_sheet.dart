import 'package:audiflow_domain/audiflow_domain.dart'
    show
        appSettingsRepositoryProvider,
        hideExplicitForPodcastProvider,
        isRestrictedModeOnProvider,
        isUnlockedProvider,
        namedLoggerProvider,
        parentalControlRepositoryProvider,
        subscriptionByFeedUrlProvider,
        subscriptionRepositoryProvider;
import 'package:audiflow_search/audiflow_search.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../download/presentation/controllers/auto_download_keep_count_controller.dart';
import '../../../download/presentation/widgets/keep_count_dropdown.dart';

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
              if (feedUrl != null) _AutoDownloadPausedTile(feedUrl: feedUrl),
              if (feedUrl != null) _KeepCountTile(feedUrl: feedUrl),
              if (feedUrl != null) _HideExplicitTile(feedUrl: feedUrl),
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

class _AutoDownloadPausedTile extends ConsumerWidget {
  const _AutoDownloadPausedTile({required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref
        .watch(subscriptionByFeedUrlProvider(feedUrl))
        .value;
    if (subscription == null ||
        subscription.isCached ||
        !subscription.autoDownload ||
        subscription.autoDownloadPausedAt == null) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.pause_circle_outline),
      title: Text(l10n.podcastAutoDownloadPausedTitle),
      subtitle: Text(l10n.podcastAutoDownloadPausedSubtitle),
      trailing: OutlinedButton(
        onPressed: () async {
          await ref
              .read(subscriptionRepositoryProvider)
              .resetAutoDownloadActivity(subscription.id);
          ref.invalidate(subscriptionByFeedUrlProvider(feedUrl));
        },
        child: Text(l10n.podcastAutoDownloadResume),
      ),
    );
  }
}

class _KeepCountTile extends ConsumerWidget {
  const _KeepCountTile({required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref
        .watch(subscriptionByFeedUrlProvider(feedUrl))
        .value;
    if (subscription == null ||
        subscription.isCached ||
        !subscription.autoDownload) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(l10n.downloadsKeepCountTitle),
      trailing: KeepCountDropdown(
        value: subscription.autoDownloadKeepCount,
        globalKeepCount: ref
            .watch(appSettingsRepositoryProvider)
            .getAutoDownloadKeepCount(),
        onChanged: (count) async {
          await ref
              .read(autoDownloadKeepCountControllerProvider.notifier)
              .setForPodcast(subscription.id, count);
          // The sheet may have closed while the trim ran.
          if (!context.mounted) return;
          ref.invalidate(subscriptionByFeedUrlProvider(feedUrl));
        },
      ),
    );
  }
}

class _HideExplicitTile extends ConsumerWidget {
  const _HideExplicitTile({required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(subscriptionByFeedUrlProvider(feedUrl));
    final subscription = subscriptionAsync.value;

    if (subscription == null || subscription.isCached) {
      return const SizedBox.shrink();
    }

    // Hide when restricted+locked: the toggle is only operable while unlocked.
    final restricted = ref.watch(isRestrictedModeOnProvider);
    final unlocked = ref.watch(isUnlockedProvider);
    if (restricted && !unlocked) return const SizedBox.shrink();

    final hideAsync = ref.watch(
      hideExplicitForPodcastProvider(subscription.id),
    );
    final hideExplicit = hideAsync.value ?? false;

    final l10n = AppLocalizations.of(context);
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(l10n.parentalControlHideExplicitToggle),
      value: hideExplicit,
      onChanged: (value) async {
        try {
          await ref
              .read(parentalControlRepositoryProvider)
              .setHideExplicit(subscription.id, value);
        } catch (e, st) {
          ref
              .read(namedLoggerProvider('ParentalControl'))
              .e('setHideExplicit failed', error: e, stackTrace: st);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.parentalControlToggleFailed)),
            );
          }
        }
      },
    );
  }
}
