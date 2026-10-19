import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/feed_link_controller.dart';

/// Shown in place of search results while the search field holds a feed
/// URL or podcast link: offers to open it, and reports why it failed.
class FeedLinkPanel extends StatelessWidget {
  const FeedLinkPanel({
    super.key,
    required this.url,
    required this.state,
    required this.onOpen,
  });

  /// The link as the user entered it.
  final String url;

  final FeedLinkState state;

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final state = this.state;

    return Center(
      key: const Key('feed_link_panel'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.rss_feed_rounded, size: 48, color: colors.accent),
            const SizedBox(height: Spacing.md),
            Text(
              l10n.feedLinkPanelTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              url,
              style: AppTextStyles.body.copyWith(color: colors.inkSecondary),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (state is FeedLinkFailed) ...[
              const SizedBox(height: Spacing.md),
              Text(
                feedLinkErrorMessage(l10n, state.error),
                key: const Key('feed_link_error'),
                style: AppTextStyles.body.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: Spacing.lg),
            if (state is FeedLinkResolving)
              const CircularProgressIndicator()
            else
              FilledButton(
                onPressed: onOpen,
                child: Text(
                  state is FeedLinkFailed
                      ? l10n.commonRetry
                      : l10n.feedLinkOpen,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Localized message for a failed feed link; [error] is null when the
/// failure was unexpected.
String feedLinkErrorMessage(AppLocalizations l10n, FeedLinkException? error) {
  if (error == null) return l10n.errorGeneric;
  return switch (error.failure) {
    FeedLinkFailure.unsupportedLink => l10n.feedLinkErrorUnsupported(
      error.platformName ?? '',
    ),
    FeedLinkFailure.notFound => l10n.feedLinkErrorNotFound,
    FeedLinkFailure.network => l10n.errorNetwork,
    FeedLinkFailure.feedUnavailable => l10n.errorFeedUnavailable,
    FeedLinkFailure.serverError => l10n.feedLinkErrorServer,
    FeedLinkFailure.notPodcastFeed => l10n.feedLinkErrorNotFeed,
  };
}
